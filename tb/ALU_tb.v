`timescale 1ns / 1ps

module ALU_tb;
    reg [31:0] A;
    reg [31:0] B;
    reg [3:0] ALU_Control;
    
    wire [31:0] Result;
    wire Zero;

    ALU uut (
        .A(A),
        .B(B),
        .ALU_Control(ALU_Control),
        .Result(Result),
        .Zero(Zero)
    );

    initial begin
        A = 32'd10; 
        B = 32'd5; 
        
        ALU_Control = 4'b0000; #10; // ADD (15)
        ALU_Control = 4'b0001; #10; // SUB (5)
        ALU_Control = 4'b0011; #10; // OR
        ALU_Control = 4'b0100; #10; // XOR
        
        A = 32'd5; 
        B = 32'd5;
        ALU_Control = 4'b0001; #10; // SUB (Zero flag triggers)
        
        $finish;
    end
endmodule