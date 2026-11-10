# 32-bit Single-Cycle RISC-V Processor Core (RV32I)

![Verilog](https://img.shields.io/badge/Verilog-HDL-blue.svg)
![FPGA](https://img.shields.io/badge/FPGA-Xilinx_Zynq--7000-orange.svg)
![Vivado](https://img.shields.io/badge/Tool-Vivado_2025.2-green.svg)
![Architecture](https://img.shields.io/badge/Architecture-RISC--V_RV32I-red.svg)

## Overview
A complete, structural 32-bit single-cycle processor core implementing the base **RV32I RISC-V Instruction Set Architecture**. Developed from scratch in Verilog HDL, this processor is fully verified through behavioral simulation and successfully synthesized for the **Xilinx Zynq-7000 (XC7Z020)** SoC, targeted for the PYNQ-Z2 development board.

This repository serves as a VLSI portfolio project demonstrating digital logic design, microarchitecture implementation, and FPGA synthesis flows.

## Key Features
* **Architecture:** 32-bit Single-Cycle Datapath
* **ISA Support:** Subset of the RV32I Base Integer Instruction Set
* **Data Width:** 32-bit instructions, 32-bit data registers (x0-x31)
* **Design Methodology:** Modular, structural Verilog hierarchy (10 core modules)
* **Synthesis:** Fully synthesized using Xilinx Vivado with zero latches and clean timing constraints.

## Supported Instructions
The control unit and ALU currently support the following instruction formats and operations:
* **R-Type:** `ADD`, `SUB`, `OR`, `XOR`, `SLL`, `SRL`, `SLT`
* **I-Type:** `ADDI`, `LW` (Load Word)
* **S-Type:** `SW` (Store Word)
* **B-Type:** `BEQ` (Branch if Equal)
* **J-Type:** `JAL` (Jump and Link)
* **U-Type:** Support integrated in Immediate Generator for future extension.

## Repository Structure
```text
riscv-single-cycle-core/
├── src/                    # Verilog RTL source files
│   ├── RISCV_Core.v        # Top-level integration module
│   ├── ALU.v               # Arithmetic Logic Unit
│   ├── ControlUnit.v       # Main decoder and control logic
│   ├── DataMemory.v        # 256-word byte-addressable memory
│   ├── ImmGen.v            # Immediate generator with sign-extension
│   ├── InstructionMemory.v # Hardcoded instruction ROM
│   ├── Mux2to1.v           # 32-bit Multiplexers
│   ├── PC_Adder.v          # Program Counter incrementer (+4)
│   ├── ProgramCounter.v    # 32-bit PC register
│   └── RegisterFile.v      # 32x32-bit Register File (x0 hardwired to 0)
├── tb/                     # Testbenches for verification
│   ├── RISCV_Core_tb.v     # Master testbench for full program execution
│   └── ...                 # Individual component testbenches
├── constraints/            # FPGA physical and timing constraints
│   └── timing.xdc          # 50MHz virtual clock constraint for synthesis
├── reports/                # Vivado implementation reports & screenshots
│   ├── simulation_waveform.png
│   ├── device_floorplan.png
│   ├── power_report.rpt
│   └── utilization_report.rpt
└── README.md
Simulation & Testing
The core is verified using a hardcoded assembly program loaded into the InstructionMemory. The test program executes the following logic sequence:

1.  Loads immediate values (5 and 10) into registers.

2.  Performs ALU addition (5 + 10 = 15).

3.  Stores the result into Data Memory.

4.  Loads the data back from Memory into a new register.

5.  Executes a conditional branch (BEQ) verifying equality.

6.  Successfully computes the branch target and updates the Program Counter.

Check reports/ for the complete Behavioral Simulation Waveform demonstrating exact cycle-by-cycle register and memory writes.

Synthesis & Implementation
The design was synthesized using Xilinx Vivado for the XC7Z020-clg400-1 part.
To prevent logic trimming during synthesis, a 32-bit debug_out probe (tied to the ALU result) was constrained using a virtual 20ns (50 MHz) clock in timing.xdc.

*   Target Device: Xilinx Zynq-7000 (XC7Z020)

*   Implementation Results: Refer to reports/ for the exact LUT/FF utilization metrics, dynamic/static power estimations, and the physical silicon device floorplan showing the mapped logic.
