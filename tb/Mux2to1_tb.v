`timescale 1ns / 1ps

module Mux2to1_tb;
    reg [31:0] in0;
    reg [31:0] in1;
    reg sel;
    wire [31:0] out;

    Mux2to1 uut (
        .in0(in0),
        .in1(in1),
        .sel(sel),
        .out(out)
    );

    initial begin
        in0 = 32'd10; 
        in1 = 32'd20;
        
        sel = 0; #10;
        sel = 1; #10;
        
        $finish;
    end
endmodule