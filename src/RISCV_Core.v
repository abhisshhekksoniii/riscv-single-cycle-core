`timescale 1ns / 1ps

module RISCV_Core (
    input clk,
    input reset,
    output [31:0] debug_out // 32-bit output for synthesis probing
);
    wire [31:0] pc_next, pc_current, instruction, pc_plus_4;
    wire reg_write, alu_src, memwrite, memread, mem_to_reg;
    wire [3:0] alu_op;
    wire [31:0] read_data1, read_data2, write_back_data;
    wire [31:0] imm_ext, alu_in2, alu_result, mem_read_data;
    wire branch, take_branch;
    wire [31:0] branch_target;

    ProgramCounter PC_Inst (.clk(clk), .reset(reset), .next_PC(pc_next), .current_PC(pc_current));
    PC_Adder Adder_Inst (.pc_in(pc_current), .pc_out(pc_plus_4));
    InstructionMemory IMEM_Inst (.read_address(pc_current), .instruction(instruction));

    ControlUnit CU_Inst (
        .opcode(instruction[6:0]),
        .Branch(branch),
        .RegWrite(reg_write),
        .ALUSrc(alu_src),
        .MemWrite(memwrite),
        .MemRead(memread),
        .MemtoReg(mem_to_reg),
        .ALUOp(alu_op)
    );

    RegisterFile RegFile_Inst (
        .clk(clk),
        .write_enable(reg_write),
        .read_reg1(instruction[19:15]),
        .read_reg2(instruction[24:20]),
        .write_reg(instruction[11:7]),
        .write_data(write_back_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    ImmGen ImmGen_Inst (.instruction(instruction), .imm_out(imm_ext));
    Mux2to1 ALUSrc_Mux (.in0(read_data2), .in1(imm_ext), .sel(alu_src), .out(alu_in2));
    
    ALU ALU_Inst (
        .A(read_data1),
        .B(alu_in2),
        .ALU_Control(alu_op),
        .Result(alu_result),
        .Zero(zero_flag)
    );

    DataMemory DataMem_Inst (
        .clk(clk),
        .memwrite(memwrite),
        .memread(memread),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(mem_read_data)
    );

    Mux2to1 MemToReg_Mux (.in0(alu_result), .in1(mem_read_data), .sel(mem_to_reg), .out(write_back_data));

    // Branching Logic
    assign branch_target = pc_current + imm_ext;
    assign take_branch = branch & zero_flag;
    assign pc_next = take_branch ? branch_target : pc_plus_4;

    assign debug_out = alu_result;
endmodule