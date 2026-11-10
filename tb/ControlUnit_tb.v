`timescale 1ns / 1ps

module ControlUnit_tb;
    reg [6:0] opcode;
    wire Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    wire [3:0] ALUOp;

    ControlUnit uut (
        .opcode(opcode),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );

    initial begin
        opcode = 7'b0000000; #10;
        
        opcode = 7'b0110011; #10; // R-Type
        opcode = 7'b0000011; #10; // LOAD
        opcode = 7'b0100011; #10; // STORE
        opcode = 7'b1100011; #10; // BRANCH
        opcode = 7'b0010011; #10; // I-Type
        opcode = 7'b1111111; #10; // Invalid/Default
        
        $finish;
    end
endmodule