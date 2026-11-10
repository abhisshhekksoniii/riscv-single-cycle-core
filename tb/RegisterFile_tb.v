`timescale 1ns / 1ps

module RegisterFile_tb;
    reg clk;
    reg write_enable;
    reg [4:0] read_reg1, read_reg2, write_reg;
    reg [31:0] write_data;
    
    wire [31:0] read_data1, read_data2;

    RegisterFile uut (
        .clk(clk),
        .write_enable(write_enable),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; write_enable = 0; 
        read_reg1 = 5'd0; read_reg2 = 5'd0; 
        write_reg = 5'd0; write_data = 32'd0; #10;

        write_enable = 1; write_reg = 5'd5; write_data = 32'd99; #10;
        write_enable = 0; read_reg1 = 5'd5; #10;
        
        write_enable = 1; write_reg = 5'd0; write_data = 32'd500; #10;
        write_enable = 0; read_reg2 = 5'd0; #10;

        $finish;
    end
endmodule