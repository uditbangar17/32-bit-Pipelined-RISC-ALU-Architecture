module control_unit(
    input  wire [5:0] opcode,
    output reg        RegDst,
    output reg        ALUSrc,
    output reg        MemToReg,
    output reg        RegWrite,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        Branch,
    output reg [1:0]  ALUOp
);
    always @(*) begin
        // defaults = NOP
        RegDst   = 0; ALUSrc   = 0; MemToReg = 0; RegWrite = 0;
        MemRead  = 0; MemWrite = 0; Branch   = 0; ALUOp    = 2'b00;

        case(opcode)
            6'b000000: begin // R-type
                RegDst   = 1;
                ALUSrc   = 0;
                MemToReg = 0;
                RegWrite = 1;
                MemRead  = 0;
                MemWrite = 0;
                Branch   = 0;
                ALUOp    = 2'b10;
            end

            6'b001000: begin // ADDI
                RegDst   = 0;
                ALUSrc   = 1;
                MemToReg = 0;
                RegWrite = 1;
                ALUOp    = 2'b00; // ADD
            end

            6'b100011: begin // LW
                RegDst   = 0;
                ALUSrc   = 1;
                MemToReg = 1;
                RegWrite = 1;
                MemRead  = 1;
                ALUOp    = 2'b00; // ADD address
            end

            6'b101011: begin // SW
                RegDst   = 0;
                ALUSrc   = 1;
                MemToReg = 0;
                RegWrite = 0;
                MemWrite = 1;
                ALUOp    = 2'b00; // ADD address
            end

            6'b000100: begin // BEQ
                RegDst   = 0;
                ALUSrc   = 0;
                RegWrite = 0;
                Branch   = 1;
                ALUOp    = 2'b01; // SUB compare
            end
        endcase
    end
endmodule