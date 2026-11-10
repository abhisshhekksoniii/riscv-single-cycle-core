`timescale 1ns / 1ps

module DataMemory_tb;
    reg clk;
    reg memwrite;
    reg memread;
    reg [31:0] address;
    reg [31:0] write_data;
    
    wire [31:0] read_data;

    DataMemory uut (
        .clk(clk),
        .memwrite(memwrite),
        .memread(memread),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; memwrite = 0; memread = 0; address = 0; write_data = 0; #10;
        
        memwrite = 1; memread = 0; address = 32'd4; write_data = 32'hAAAA_BBBB; #10;
        memwrite = 0; memread = 1; address = 32'd4; #10;
        
        memwrite = 1; memread = 0; address = 32'd8; write_data = 32'h1111_2222; #10;
        memwrite = 0; memread = 1; address = 32'd8; #10;

        memread = 0; #10;
        $finish;
    end
endmodule