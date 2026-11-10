`timescale 1ns / 1ps

module RISCV_Core_tb;
    reg clk;
    reg reset;
    wire [31:0] debug_out;

    RISCV_Core uut (
        .clk(clk),
        .reset(reset),
        .debug_out(debug_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        #20;
        
        reset = 0;
        #200;

        $finish;
    end
endmodule