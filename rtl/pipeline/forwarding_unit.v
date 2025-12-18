module forwarding_unit(
    input  wire [4:0] id_ex_rs,
    input  wire [4:0] id_ex_rt,
    input  wire       ex_mem_RegWrite,
    input  wire [4:0] ex_mem_rd,
    input  wire       mem_wb_RegWrite,
    input  wire [4:0] mem_wb_rd,
    output reg  [1:0] fwdA,
    output reg  [1:0] fwdB
);
    always @(*) begin
        fwdA = 2'b00;
        fwdB = 2'b00;

        // EX hazard
        if (ex_mem_RegWrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs))
            fwdA = 2'b10;
        if (ex_mem_RegWrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rt))
            fwdB = 2'b10;

        // MEM hazard
        if (mem_wb_RegWrite && (mem_wb_rd != 0) &&
            !(ex_mem_RegWrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs)) &&
            (mem_wb_rd == id_ex_rs))
            fwdA = 2'b01;

        if (mem_wb_RegWrite && (mem_wb_rd != 0) &&
            !(ex_mem_RegWrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rt)) &&
            (mem_wb_rd == id_ex_rt))
            fwdB = 2'b01;
    end
endmodule