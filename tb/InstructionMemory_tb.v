`timescale 1ns / 1ps

module InstructionMemory_tb;
    reg [31:0] read_address;
    wire [31:0] instruction;

    InstructionMemory uut (
        .read_address(read_address),
        .instruction(instruction)
    );

    initial begin
        read_address = 32'd0;  #10;
        read_address = 32'd4;  #10;
        read_address = 32'd8;  #10;
        read_address = 32'd12; #10;
        read_address = 32'd16; #10;
        read_address = 32'd20; #10;
        read_address = 32'd24; #10;
        read_address = 32'd28; #10;
        
        $finish;
    end
endmodule