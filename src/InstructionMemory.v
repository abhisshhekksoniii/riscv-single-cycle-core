`timescale 1ns / 1ps

module InstructionMemory (
    input wire [31:0] read_address,
    output wire [31:0] instruction
);
    reg [31:0] RAM [0:127];
    integer i;

    initial begin
        // Initialize memory with NOPs to prevent unknown states
        for (i = 0; i < 128; i = i + 1) begin
            RAM[i] = 32'h00000013;
        end
        
        // Hardcoded execution sequence
        RAM[0] = 32'h00500093; // ADDI x1, x0, 5
        RAM[1] = 32'h00A00113; // ADDI x2, x0, 10
        RAM[2] = 32'h002081B3; // ADD  x3, x1, x2
        RAM[3] = 32'h00302023; // SW   x3, 0(x0)
        RAM[4] = 32'h00002203; // LW   x4, 0(x0)
        RAM[5] = 32'h00418463; // BEQ  x3, x4, 8
        RAM[6] = 32'h00100293; // ADDI x5, x0, 1
        RAM[7] = 32'hFFFFF36F; // JAL  x6, back
    end

    // Word-aligned addressing
    assign instruction = RAM[read_address[8:2]];
endmodule