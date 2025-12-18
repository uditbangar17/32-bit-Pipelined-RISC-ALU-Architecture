`timescale 1ns/1ps

module alu32_tb;

    reg  [31:0] a, b;
    reg  [3:0]  sel;

    wire [31:0] y_rca, y_cla;
    wire        zero_rca, zero_cla;
    wire        carry_rca, carry_cla;
    wire        ovf_rca, ovf_cla;

    // RCA-based ALU
    alu32 #(.ADDER_TYPE(0)) alu_rca (
        .a(a), .b(b), .sel(sel),
        .y(y_rca), .zero(zero_rca),
        .carry(carry_rca), .overflow(ovf_rca)
    );

    // CLA-based ALU
    alu32 #(.ADDER_TYPE(1)) alu_cla (
        .a(a), .b(b), .sel(sel),
        .y(y_cla), .zero(zero_cla),
        .carry(carry_cla), .overflow(ovf_cla)
    );

    reg [32:0] expected;

    // Test procedure
    task run_test(input [31:0] ta, tb, input [3:0] tsel);
    begin
        a = ta;
        b = tb;
        sel = tsel;
        #2;

        case(tsel)
            4'b0011: expected = ta + tb;     // ADD
            4'b0100: expected = ta - tb;     // SUB
            default: expected = 33'hX;       // not needed
        endcase

        $display("\n--------------------------------------------");
        $display("a=%h  b=%h  sel=%b", ta, tb, tsel);

        // CHECK RCA
        if (tsel==4'b0011 || tsel==4'b0100) begin
            if (y_rca !== expected[31:0])
                $display("❌ RCA FAIL y=%h expected=%h", y_rca, expected);
            else
                $display("✔ RCA PASS y=%h", y_rca);
        end

        // CHECK CLA
        if (tsel==4'b0011 || tsel==4'b0100) begin
            if (y_cla !== expected[31:0])
                $display("❌ CLA FAIL y=%h expected=%h", y_cla, expected);
            else
                $display("✔ CLA PASS y=%h", y_cla);
        end

    end
    endtask

    initial begin
        $dumpfile("alu32_tb.vcd");
        $dumpvars(0, alu32_tb);

        // Directed tests
        run_test(32'h00000005, 32'h00000003, 4'b0011); // ADD
        run_test(32'h00000005, 32'h00000003, 4'b0100); // SUB
        run_test(32'hFFFFFFFF, 32'h1,        4'b0011); // ADD overflow
        run_test(32'h80000000, 32'h1,        4'b0100); // SUB

        // 20 random tests
        repeat(20)
            run_test($random, $random, 4'b0011); // ADD

        $display("\n===== TESTING DONE =====\n");
        $finish;
    end

endmodule