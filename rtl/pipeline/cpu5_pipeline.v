module cpu5_pipeline #(
    parameter ADDER_TYPE = 1,             // 0=RCA ALU, 1=CLA ALU
    parameter IMEM_DEPTH = 256,
    parameter DMEM_DEPTH = 256
)(
    input  wire clk,
    input  wire reset
);

    // ============================================================
    // IF STAGE: PC + Instruction Fetch
    // ============================================================
    reg [31:0] pc;

    // Simple instruction memory (word-addressed)
    reg [31:0] imem [0:IMEM_DEPTH-1];
    wire [31:0] instr = imem[pc[31:2]];   // word aligned

    wire [31:0] pc_plus4 = pc + 32'd4;

    // IF/ID pipeline register
    reg [31:0] if_id_pc4;
    reg [31:0] if_id_instr;

    // Flush/stall controls
    wire stall;
    wire flush_if_id;
    // ============================================================
    // FORWARD DECLARATIONS (signals used before definition)
    // ============================================================

    // EX/MEM stage (used by forwarding logic)
    reg [31:0] ex_mem_alu_y;
    reg        ex_mem_RegWrite;
    reg [4:0]  ex_mem_write_reg;

    // MEM/WB stage (used by regfile + forwarding)
    reg        mem_wb_RegWrite;
    reg [4:0]  mem_wb_write_reg;
    reg        mem_wb_MemToReg;
    reg [31:0] mem_wb_mem_data;
    reg [31:0] mem_wb_alu_y;

    // Writeback mux output
    wire [31:0] wb_write_data;

    // Next PC selection (branch resolved in EX)
    wire        ex_branch_taken;
    wire [31:0] ex_branch_target;

    wire [31:0] pc_next = ex_branch_taken ? ex_branch_target : pc_plus4;

    // PC update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'd0;
        end else if (!stall) begin
            pc <= pc_next;
        end
    end

    // IF/ID update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            if_id_pc4   <= 32'd0;
            if_id_instr <= 32'd0;
        end else if (!stall) begin
            if (flush_if_id) begin
                if_id_pc4   <= 32'd0;
                if_id_instr <= 32'd0; // NOP
            end else begin
                if_id_pc4   <= pc_plus4;
                if_id_instr <= instr;
            end
        end
    end

    // ============================================================
    // ID STAGE: Decode + Register File Read + Control
    // ============================================================
    wire [5:0] opcode = if_id_instr[31:26];
    wire [4:0] rs     = if_id_instr[25:21];
    wire [4:0] rt     = if_id_instr[20:16];
    wire [4:0] rd     = if_id_instr[15:11];
    wire [4:0] shamt  = if_id_instr[10:6];
    wire [5:0] funct  = if_id_instr[5:0];
    wire [15:0] imm16 = if_id_instr[15:0];

    wire [31:0] imm_sext = {{16{imm16[15]}}, imm16};

    // Register file
    wire [31:0] reg_rd1, reg_rd2;
    regfile rf (
        .clk(clk),
        .we (mem_wb_RegWrite),
        .ra1(rs),
        .ra2(rt),
        .wa (mem_wb_write_reg),
        .wd (wb_write_data),
        .rd1(reg_rd1),
        .rd2(reg_rd2)
    );

    // Main control signals from opcode
    wire RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch;
    wire [1:0] ALUOp;

    control_unit CU (
        .opcode(opcode),
        .RegDst(RegDst),
        .ALUSrc(ALUSrc),
        .MemToReg(MemToReg),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );

    // ALU control: maps (ALUOp, funct) -> alu_sel[3:0]
    wire [3:0] alu_sel_id;
    alu_control ALUCTL (
        .ALUOp(ALUOp),
        .funct(funct),
        .alu_sel(alu_sel_id)
    );

    // ============================================================
    // ID/EX pipeline register
    // ============================================================
    reg [31:0] id_ex_pc4;
    reg [31:0] id_ex_rd1, id_ex_rd2;
    reg [31:0] id_ex_imm;
    reg [4:0]  id_ex_rs, id_ex_rt, id_ex_rd;
    reg [4:0]  id_ex_shamt;

    // control bits into EX/MEM/WB
    reg        id_ex_RegDst, id_ex_ALUSrc, id_ex_Branch;
    reg [3:0]  id_ex_alu_sel;
    reg        id_ex_MemRead, id_ex_MemWrite;
    reg        id_ex_MemToReg, id_ex_RegWrite;

    // If we stall, we inject a NOP into ID/EX (classic)
    wire squash_id_ex = stall;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            id_ex_pc4 <= 0; id_ex_rd1 <= 0; id_ex_rd2 <= 0; id_ex_imm <= 0;
            id_ex_rs <= 0; id_ex_rt <= 0; id_ex_rd <= 0; id_ex_shamt <= 0;

            id_ex_RegDst <= 0; id_ex_ALUSrc <= 0; id_ex_Branch <= 0;
            id_ex_alu_sel <= 0;
            id_ex_MemRead <= 0; id_ex_MemWrite <= 0;
            id_ex_MemToReg <= 0; id_ex_RegWrite <= 0;
        end else begin
            id_ex_pc4   <= if_id_pc4;
            id_ex_rd1   <= reg_rd1;
            id_ex_rd2   <= reg_rd2;
            id_ex_imm   <= imm_sext;
            id_ex_rs    <= rs;
            id_ex_rt    <= rt;
            id_ex_rd    <= rd;
            id_ex_shamt <= shamt;

            if (squash_id_ex) begin
                // NOP all controls
                id_ex_RegDst   <= 0;
                id_ex_ALUSrc   <= 0;
                id_ex_Branch   <= 0;
                id_ex_alu_sel  <= 0;
                id_ex_MemRead  <= 0;
                id_ex_MemWrite <= 0;
                id_ex_MemToReg <= 0;
                id_ex_RegWrite <= 0;
            end else begin
                id_ex_RegDst   <= RegDst;
                id_ex_ALUSrc   <= ALUSrc;
                id_ex_Branch   <= Branch;
                id_ex_alu_sel  <= alu_sel_id;
                id_ex_MemRead  <= MemRead;
                id_ex_MemWrite <= MemWrite;
                id_ex_MemToReg <= MemToReg;
                id_ex_RegWrite <= RegWrite;
            end
        end
    end

    // ============================================================
    // EX STAGE: Forwarding + ALU + Branch decision
    // ============================================================
    // Forwarding unit
    wire [1:0] fwdA, fwdB;
    forwarding_unit FWD (
        .id_ex_rs(id_ex_rs),
        .id_ex_rt(id_ex_rt),
        .ex_mem_RegWrite(ex_mem_RegWrite),
        .ex_mem_rd(ex_mem_write_reg),
        .mem_wb_RegWrite(mem_wb_RegWrite),
        .mem_wb_rd(mem_wb_write_reg),
        .fwdA(fwdA),
        .fwdB(fwdB)
    );

    // Choose forwarded sources
    wire [31:0] ex_opA =
        (fwdA == 2'b00) ? id_ex_rd1 :
        (fwdA == 2'b10) ? ex_mem_alu_y :
        (fwdA == 2'b01) ? wb_write_data :
                          id_ex_rd1;

    wire [31:0] ex_regB_fwd =
        (fwdB == 2'b00) ? id_ex_rd2 :
        (fwdB == 2'b10) ? ex_mem_alu_y :
        (fwdB == 2'b01) ? wb_write_data :
                          id_ex_rd2;

    // ALUSrc: select imm or regB
    wire [31:0] ex_opB = id_ex_ALUSrc ? id_ex_imm : ex_regB_fwd;

    // If operation is shift, we shift by shamt (like MIPS)
    // We'll implement shift by forcing B[4:0] = shamt when alu_sel is SLL or SRL.
    wire is_shift = (id_ex_alu_sel == 4'b1000) || (id_ex_alu_sel == 4'b1001);
    wire [31:0] ex_alu_b = is_shift ? {27'd0, id_ex_shamt} : ex_opB;

    wire [31:0] ex_alu_y;
    wire ex_zero, ex_carry, ex_overflow;

    alu32 #(.ADDER_TYPE(ADDER_TYPE)) U_ALU (
        .a(ex_opA),
        .b(ex_alu_b),
        .sel(id_ex_alu_sel),
        .y(ex_alu_y),
        .zero(ex_zero),
        .carry(ex_carry),
        .overflow(ex_overflow)
    );

    // Branch target = id_ex_pc4 + (imm << 2)
    wire [31:0] ex_branch_off = (id_ex_imm << 2);
    assign ex_branch_target   = id_ex_pc4 + ex_branch_off;

    // BEQ uses SUB result == 0 => zero flag true when a==b (after forwarding)
    assign ex_branch_taken = id_ex_Branch & ex_zero;

    // Destination register selection
    wire [4:0] ex_write_reg = id_ex_RegDst ? id_ex_rd : id_ex_rt;

    // ============================================================
    // EX/MEM pipeline register
    // ============================================================
    reg [31:0] ex_mem_store_data;
    reg        ex_mem_zero;

    reg        ex_mem_MemRead, ex_mem_MemWrite;
    reg        ex_mem_MemToReg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_mem_alu_y      <= 0;
            ex_mem_store_data <= 0;
            ex_mem_zero       <= 0;

            ex_mem_MemRead    <= 0;
            ex_mem_MemWrite   <= 0;
            ex_mem_MemToReg   <= 0;
            ex_mem_RegWrite   <= 0;
            ex_mem_write_reg  <= 0;
        end else begin
            ex_mem_alu_y      <= ex_alu_y;
            ex_mem_store_data <= ex_regB_fwd; // store uses forwarded rt value
            ex_mem_zero       <= ex_zero;

            ex_mem_MemRead    <= id_ex_MemRead;
            ex_mem_MemWrite   <= id_ex_MemWrite;
            ex_mem_MemToReg   <= id_ex_MemToReg;
            ex_mem_RegWrite   <= id_ex_RegWrite;
            ex_mem_write_reg  <= ex_write_reg;
        end
    end

    // Flush IF/ID when branch taken (simple control hazard handling)
    assign flush_if_id = ex_branch_taken;

    // ============================================================
    // MEM STAGE: Data Memory
    // ============================================================
    reg [31:0] dmem [0:DMEM_DEPTH-1];
    wire [31:0] mem_read_data = dmem[ex_mem_alu_y[31:2]];

    always @(posedge clk) begin
        if (ex_mem_MemWrite) begin
            dmem[ex_mem_alu_y[31:2]] <= ex_mem_store_data;
        end
    end

    // ============================================================
    // MEM/WB pipeline register
    // ============================================================
    

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_wb_mem_data  <= 0;
            mem_wb_alu_y     <= 0;
            mem_wb_MemToReg  <= 0;
            mem_wb_RegWrite  <= 0;
            mem_wb_write_reg <= 0;
        end else begin
            mem_wb_mem_data  <= mem_read_data;
            mem_wb_alu_y     <= ex_mem_alu_y;
            mem_wb_MemToReg  <= ex_mem_MemToReg;
            mem_wb_RegWrite  <= ex_mem_RegWrite;
            mem_wb_write_reg <= ex_mem_write_reg;
        end
    end

    // ============================================================
    // WB STAGE: Writeback to Register File
    // ============================================================
    assign wb_write_data = mem_wb_MemToReg ? mem_wb_mem_data : mem_wb_alu_y;

    // ============================================================
    // HAZARD DETECTION: load-use stall
    // If ID uses rs/rt that EX is loading (MemRead), stall 1 cycle
    // ============================================================
    hazard_unit HAZ (
        .id_rs(rs),
        .id_rt(rt),
        .id_ex_MemRead(id_ex_MemRead),
        .id_ex_rt(id_ex_rt),
        .stall(stall)
    );

endmodule