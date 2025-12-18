module alu_control(
    input  wire [1:0] ALUOp,
    input  wire [5:0] funct,
    output reg  [3:0] alu_sel
);
    always @(*) begin
        case(ALUOp)
            2'b00: alu_sel = 4'b0011; // ADD (lw/sw/addi)
            2'b01: alu_sel = 4'b0100; // SUB (beq)
            2'b10: begin              // R-type based on funct
                case(funct)
                    6'h20: alu_sel = 4'b0011; // ADD
                    6'h22: alu_sel = 4'b0100; // SUB
                    6'h24: alu_sel = 4'b0000; // AND
                    6'h25: alu_sel = 4'b0001; // OR
                    6'h26: alu_sel = 4'b0010; // XOR
                    6'h2A: alu_sel = 4'b0111; // SLT
                    6'h00: alu_sel = 4'b1000; // SLL (shift by shamt)
                    6'h02: alu_sel = 4'b1001; // SRL (shift by shamt)
                    default: alu_sel = 4'b0011;
                endcase
            end
            default: alu_sel = 4'b0011;
        endcase
    end
endmodule