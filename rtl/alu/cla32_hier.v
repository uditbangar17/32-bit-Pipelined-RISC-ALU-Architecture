// 32-bit hierarchical CLA using eight 4-bit true CLA blocks
module cla32_hier (
    input  [31:0] a,
    input  [31:0] b,
    input         cin,
    output [31:0] sum,
    output        cout
);

    wire [7:0] P;      // block propagate for 8 blocks
    wire [7:0] G;      // block generate for 8 blocks

    wire [8:0] Cb;     // block carries: Cb[0]..Cb[8]
    assign Cb[0] = cin;

    // Each 4-bit CLA block handles 4 bits of the inputs.
    // Block i handles bits [4*i+3 : 4*i].

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : CLA_BLOCKS

            wire [3:0] a_slice = a[4*i + 3 : 4*i];
            wire [3:0] b_slice = b[4*i + 3 : 4*i];

            wire [3:0] sum_slice;
            wire       cout_slice;

            cla4_true u_cla4 (
                .a   (a_slice),
                .b   (b_slice),
                .cin (Cb[i]),
                .sum (sum_slice),
                .cout(cout_slice),
                .P   (P[i]),
                .G   (G[i])
            );

            // Connect this block's sum back into the big 32-bit sum
            assign sum[4*i + 3 : 4*i] = sum_slice;

            // Block-level carry (1-level look-ahead per 4-bit block):
            // Cb[i+1] = G[i] + P[i]*Cb[i]
            assign Cb[i + 1] = G[i] | (P[i] & Cb[i]);

        end
    endgenerate

    // Final 32-bit carry-out
    assign cout = Cb[8];

endmodule