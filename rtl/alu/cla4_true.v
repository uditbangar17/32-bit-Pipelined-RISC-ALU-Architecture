module cla4_true(
    input  [3:0] a, b,
    input        cin,
    output [3:0] sum,
    output       cout,
    output       P,   // block propagate
    output       G    // block generate
);

    wire [3:0] g, p;
    wire C1, C2, C3, C4;

    assign g = a & b;     // bit-generate
    assign p = a ^ b;     // bit-propagate

    // TRUE carry look-ahead equations
    assign C1 = g[0] | (p[0] & cin);

    assign C2 = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin);

    assign C3 = g[2] | (p[2] & g[1]) |
                        (p[2] & p[1] & g[0]) |
                        (p[2] & p[1] & p[0] & cin);

    assign C4 = g[3] | (p[3] & g[2]) |
                        (p[3] & p[2] & g[1]) |
                        (p[3] & p[2] & p[1] & g[0]) |
                        (p[3] & p[2] & p[1] & p[0] & cin);

    // Sum outputs
    assign sum[0] = p[0] ^ cin;
    assign sum[1] = p[1] ^ C1;
    assign sum[2] = p[2] ^ C2;
    assign sum[3] = p[3] ^ C3;

    // Final carry-out
    assign cout = C4;

    // Block propagate and generate
    assign P = p[0] & p[1] & p[2] & p[3];
    assign G = g[3] | (p[3] & g[2]) |
                      (p[3] & p[2] & g[1]) |
                      (p[3] & p[2] & p[1] & g[0]);

endmodule