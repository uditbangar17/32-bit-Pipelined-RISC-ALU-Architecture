module alu32 #(
    parameter ADDER_TYPE = 0   // 0 = RCA, 1 = CLA
)(
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  sel,
    output reg [31:0] y,
    output reg        zero,
    output reg        carry,
    output reg        overflow
);

    wire [31:0] add_out;
    wire        add_cout;

    wire [31:0] sub_out;
    wire        sub_cout;

    // ================================
    // ADDER TYPE SELECTION (RCA or CLA)
    // ================================

    generate
        if (ADDER_TYPE == 0) begin : USE_RCA
            rca32 u_add (
                .a(a),
                .b(b),
                .cin(1'b0),
                .sum(add_out),
                .cout(add_cout)
            );

            rca32 u_sub (
                .a(a),
                .b(~b),
                .cin(1'b1),
                .sum(sub_out),
                .cout(sub_cout)
            );
        end
        else begin : USE_CLA
            cla32_hier u_add (
                .a(a),
                .b(b),
                .cin(1'b0),
                .sum(add_out),
                .cout(add_cout)
            );

            cla32_hier u_sub (
                .a(a),
                .b(~b),
                .cin(1'b1),
                .sum(sub_out),
                .cout(sub_cout)
            );
        end
    endgenerate

    // ================================
    // MAIN ALU FUNCTION
    // ================================

    always @(*) begin
        case(sel)
            4'b0000: y = a & b;                  // AND
            4'b0001: y = a | b;                  // OR
            4'b0010: y = a ^ b;                  // XOR
            4'b0011: y = add_out;                // ADD
            4'b0100: y = sub_out;                // SUB
            4'b0101: y = ~(a & b);               // NAND
            4'b0110: y = ~(a | b);               // NOR
            4'b0111: y = (a < b) ? 32'b1 : 32'b0;// SLT
            4'b1000: y = a << b[4:0];            // Shift left
            4'b1001: y = a >> b[4:0];            // Shift right
            default: y = 32'd0;
        endcase
    end

    // ================================
    // FLAGS
    // ================================

   always @(*) begin
        zero = (y == 32'd0);

        carry = (sel == 4'b0011) ? add_cout :
                (sel == 4'b0100) ? sub_cout : 1'b0;

        if (sel == 4'b0011)        // ADD overflow
            overflow = (a[31] == b[31]) && (y[31] != a[31]);
        else if (sel == 4'b0100)   // SUB overflow
            overflow = (a[31] != b[31]) && (y[31] != a[31]);
        else
            overflow = 1'b0;
   end

endmodule
