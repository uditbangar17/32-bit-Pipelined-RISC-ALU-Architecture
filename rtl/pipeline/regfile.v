module regfile(
    input  wire        clk,
    input  wire        we,
    input  wire [4:0]  ra1,
    input  wire [4:0]  ra2,
    input  wire [4:0]  wa,
    input  wire [31:0] wd,
    output wire [31:0] rd1,
    output wire [31:0] rd2
);
    reg [31:0] regs [0:31];

    // Read (combinational)
    assign rd1 = (ra1 == 0) ? 32'd0 : regs[ra1];
    assign rd2 = (ra2 == 0) ? 32'd0 : regs[ra2];

    // Write (clocked)
    always @(posedge clk) begin
        if (we && (wa != 0))
            regs[wa] <= wd;
    end
endmodule