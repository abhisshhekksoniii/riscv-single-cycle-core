`timescale 1ns / 1ps

module ImmGen_tb;
    reg [31:0] instruction;
    wire [31:0] imm_out;

    ImmGen uut (
        .instruction(instruction),
        .imm_out(imm_out)
    );

    initial begin
        instruction = 32'd0; #10;
        
        instruction = 32'h00500093; #10; // I-Type (Positive)
        instruction = 32'hffb00093; #10; // I-Type (Negative sign-extension)
        instruction = 32'h00102223; #10; // S-Type

        $finish; 
    end
endmodule