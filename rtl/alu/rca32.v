module full_adder(
    input  a, b, cin,
    output sum, cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule


module rca32(
    input  [31:0] a, 
    input  [31:0] b,
    input         cin,
    output [31:0] sum,
    output        cout
);

    wire [31:0] c;

    // First bit full adder
    full_adder fa0 (
        .a  (a[0]), 
        .b  (b[0]), 
        .cin(cin),
        .sum(sum[0]), 
        .cout(c[0])
    );

    // Remaining 31 bits
    genvar i;
    generate
        for (i=1; i<32; i=i+1) begin : FA_CHAIN
            full_adder fa (
                .a  (a[i]), 
                .b  (b[i]), 
                .cin(c[i-1]),
                .sum(sum[i]), 
                .cout(c[i])
            );
        end
    endgenerate

    assign cout = c[31];

endmodule