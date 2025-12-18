`timescale 1ns/1ps

module tb_cpu5_pipeline;

    reg clk;
    reg reset;

    // Instantiate CPU
    cpu5_pipeline #(
        .ADDER_TYPE(1)   // 1 = CLA ALU, change to 0 for RCA
    ) dut (
        .clk(clk),
        .reset(reset)
    );

    // -------------------------
    // CLOCK GENERATION
    // -------------------------
    always #5 clk = ~clk;   // 100 MHz clock (10 ns period)

    initial begin
        clk = 0;
        reset = 1;

        // Load instruction memory
        $readmemh("program.hex", dut.imem);

        // Reset pulse
        #20;
        reset = 0;

        // Run for some cycles
        #500;

        $display("Simulation finished");
        $finish;
    end

endmodule