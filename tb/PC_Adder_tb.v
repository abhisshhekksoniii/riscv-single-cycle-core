`timescale 1ns / 1ps

module PC_Adder_tb;
    reg [31:0] pc_in;
    wire [31:0] pc_out;

    PC_Adder uut (
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    initial begin
        pc_in = 32'd0; #10;
        pc_in = 32'd4; #10;
        pc_in = 32'd8; #10;
        $finish;
    end
endmodule