`timescale 1ns / 1ps

module ProgramCounter (
    input clk,
    input reset,
    input [31:0] next_PC,
    output reg [31:0] current_PC
);
    always @(posedge clk or posedge reset) begin
        if (reset == 1'b1) begin
            current_PC <= 32'd0;
        end else begin
            current_PC <= next_PC;
        end
    end
endmodule