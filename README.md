# 32-bit Single-Cycle RISC-V Processor Core (RV32I)

![Verilog](https://img.shields.io/badge/Verilog-HDL-blue)
![FPGA](https://img.shields.io/badge/FPGA-Xilinx%20Zynq--7000-orange)
![Tool](https://img.shields.io/badge/Tool-Vivado%202025.2-green)
![Architecture](https://img.shields.io/badge/Architecture-RISC--V%20RV32I-red)

A structural **32-bit single-cycle RISC-V (RV32I-subset) processor core** designed from scratch in Verilog HDL, verified with testbenches in Vivado, and synthesised and implemented for the Xilinx Zynq-7000 (PYNQ-Z2, `xc7z020clg400-1`).

In a single-cycle core, **every instruction completes in exactly one clock cycle**: fetch, decode, register read, execute, memory access and write-back all happen between two clock edges. That makes the design simple and its CPI exactly 1, at the cost of a long clock period.

> This core is the baseline for [NANORISCV-C2](https://github.com/abhisshhekksoniii/NANORISCV-C2), the 2-stage pipelined version of the same design.

---

## Table of contents

1. [Features](#features)
2. [Architecture](#architecture)
3. [Repository structure](#repository-structure)
4. [Modules](#modules)
5. [Supported instructions](#supported-instructions)
6. [How an instruction executes](#how-an-instruction-executes)
7. [Verification](#verification)
8. [How to run](#how-to-run)
9. [Implementation results](#implementation-results)
10. [Single-cycle vs 2-stage](#single-cycle-vs-2-stage)
11. [Known limitations](#known-limitations)
12. [Roadmap](#roadmap)
13. [Author and acknowledgements](#author-and-acknowledgements)
14. [License](#license)

---

## Features

- Structural design: a top-level module wires together small, single-purpose modules.
- 32-bit datapath with a 32 x 32 register file (`x0` hard-wired to zero).
- One clock cycle per instruction, so CPI = 1 (no stalls, no flushes, no hazards).
- Separate instruction and data memories (Harvard style).
- ALU with add, subtract, OR, XOR, set-less-than and shifts, plus a zero flag for branches.
- Testbenches for the modules and the complete core.
- Synthesised and implemented in Vivado for the PYNQ-Z2 (Zynq-7000).
- Open ISA (RISC-V) and plain Verilog; no third-party IP cores.

---

## Architecture

![Single-cycle architecture](architecture/architecture.png)

> Replace `architecture.png` with the file name of your block diagram in the `architecture/` folder.

**Datapath in one paragraph.** The program counter addresses the instruction memory. The control unit decodes the opcode, the register file supplies the operands, and the ALU computes a result or a memory address. The data memory serves loads and stores, and a mux selects the value written back to the register file. For a `BEQ`, the ALU subtracts the two registers; if the result is zero, the next PC is `PC + immediate`, otherwise `PC + 4`.

---

## Repository structure

```
riscv-single-cycle-core/
├── architecture/              block diagram of the core
├── constraints/               Vivado constraints (XDC)
├── reports/                   Vivado timing, utilisation and power reports
├── src/                       Verilog source (design modules)
├── tb/                        testbenches
├── RISCV SIngle cycle.xpr     Vivado project (open this in Vivado)
└── README.md
```

---

## Modules

| Module | Role |
|---|---|
| `ProgramCounter` | Holds the current instruction address; resets to 0 |
| `PC_Adder` | Computes `PC + 4` |
| `InstructionMemory` | Word-aligned instruction store; returns the instruction at the PC (asynchronous read) |
| `ControlUnit` | Decodes the 7-bit opcode into `RegWrite`, `ALUSrc`, `MemRead`, `MemWrite`, `MemtoReg`, `Branch` and a 4-bit `ALUOp` |
| `RegisterFile` | 32 x 32-bit registers; two asynchronous read ports, one synchronous write port; `x0` always reads 0 |
| `ImmGen` | Sign-extended immediates for I, S, B, U and J formats |
| `ALU` | Arithmetic and logic operations and a `Zero` flag |
| `DataMemory` | Data store for loads and stores (synchronous write, asynchronous read) |
| `Mux2to1` | 32-bit 2-to-1 multiplexer (ALU source, write-back, next PC) |
| Top level | Connects all modules into the complete core |

> Memory depths are set in `InstructionMemory.v` and `DataMemory.v`.

---

## Supported instructions

| Instruction | Opcode | Operation |
|---|---|---|
| R-type (executes as `ADD`) | `0110011` | `rd = rs1 + rs2` |
| `ADDI` | `0010011` | `rd = rs1 + imm` |
| `LW` | `0000011` | `rd = mem[rs1 + imm]` |
| `SW` | `0100011` | `mem[rs1 + imm] = rs2` |
| `BEQ` | `1100011` | `if (rs1 == rs2) PC = PC + imm` |

### Control signals

| Instruction | RegWrite | ALUSrc | MemRead | MemWrite | MemtoReg | Branch | ALUOp |
|---|---|---|---|---|---|---|---|
| R-type (ADD) | 1 | 0 | 0 | 0 | 0 | 0 | `0010` |
| `ADDI` | 1 | 1 | 0 | 0 | 0 | 0 | `0000` |
| `LW` | 1 | 1 | 1 | 0 | 1 | 0 | `0000` |
| `SW` | 0 | 1 | 0 | 1 | 0 | 0 | `0000` |
| `BEQ` | 0 | 0 | 0 | 0 | 0 | 1 | `0001` |

### ALU operations

| `ALU_Control` | Operation |
|---|---|
| `0000`, `0010` | `A + B` |
| `0001` | `A - B` (used by `BEQ`) |
| `0011` | `A | B` |
| `0100` | `A ^ B` |
| `0101` | set less than (`A < B`) |
| `0110` | `A << B[4:0]` |
| `0111` | `A >> B[4:0]` |

`Zero` is 1 when the ALU result is 0, and a branch is taken when `Branch AND Zero` is 1.

---

## How an instruction executes

All of the following happens within one clock cycle:

| Step | What happens |
|---|---|
| 1. Fetch | `InstructionMemory` outputs the instruction at the PC; `PC_Adder` computes `PC + 4` |
| 2. Decode | `ControlUnit` reads the opcode; `ImmGen` builds the immediate; `RegisterFile` reads `rs1` and `rs2` |
| 3. Execute | `ALU` computes the result using register data or the immediate (`ALUSrc`) |
| 4. Memory | `DataMemory` is read (`LW`) or written (`SW`) |
| 5. Write-back | A mux (`MemtoReg`) chooses ALU result or memory data; `RegisterFile` stores it on the clock edge |
| 6. Next PC | `PC + 4`, or `PC + immediate` when `Branch AND Zero` is 1 |

Because a taken branch only changes which address is loaded on the next edge, there is **no branch penalty**. The price is that the clock period must cover the longest path through all six steps.

---

## Verification

Testbenches are in [`tb/`](tb/). They exercise the individual modules and the complete core.

| Testbench | Covers | Result |
|---|---|---|
| Module-level testbenches | Each design module on its own | TBD |
| Full-core testbench | A short program with `ADDI`, `ADD`, `SW`, `LW` and `BEQ` | TBD |

> Fill in the results from your simulation runs, and add the waveform screenshots below.

![Core waveform](reports/waveform_core.png)

*Full-core simulation: PC, instruction, register values and memory contents.*

---

## How to run

### Vivado

1. Open `RISCV SIngle cycle.xpr` in Vivado.
2. In **Sources**, check that the core top module is the design top and a testbench is the simulation top.
3. Run **Behavioral Simulation** and inspect the waveform.
4. Run **Synthesis**, then **Implementation**, to produce timing, utilisation and power reports.

Target device: **Zynq-7000 `xc7z020clg400-1` (PYNQ-Z2)**.

---

## Implementation results

Device: PYNQ-Z2 (`xc7z020clg400-1`), Vivado 2025.2. The full reports are in [`reports/`](reports/).

| Metric | Value |
|---|---|
| Worst setup slack (WNS) | TBD |
| Worst hold slack (WHS) | TBD |
| Clock constraint | TBD |
| LUTs | TBD |
| Flip-flops | TBD |
| Block RAM / DSP | TBD |
| Total on-chip power | TBD |

---

## Single-cycle vs 2-stage

The same set of modules was reorganised into a 2-stage pipeline in [NANORISCV-C2](https://github.com/abhisshhekksoniii/NANORISCV-C2).

| | Single-cycle (this repo) | 2-stage (NanoRISCV-C2) |
|---|---|---|
| Pipeline register | None | IF/EX register between fetch and execute |
| CPI | Exactly 1 | 1 plus one bubble per taken branch |
| Taken-branch cost | 0 extra cycles | 1 extra cycle (flush) |
| Clock period | Set by the full fetch-to-write-back path | Shorter path per stage |
| Control complexity | Lowest | Adds flush logic and a valid bit |
| FPGA used | PYNQ-Z2 (Zynq-7000) | Kintex-7 |

The two cores were implemented on different devices, so compare the architectures rather than the raw timing and area numbers.

---

## Known limitations

- Only a small RV32I subset runs: R-type (as `ADD`), `ADDI`, `LW`, `SW` and `BEQ`.
- No `JAL`, `LUI` or `BNE`, and `funct3` / `funct7` are not decoded, so the other ALU operations cannot yet be selected by instructions.
- No byte or half-word memory accesses.
- Memories are small and fixed in size.

---

## Roadmap

- [ ] Decode `funct3` / `funct7` so the full ALU is reachable
- [ ] Add `JAL`, `LUI` and `BNE`
- [ ] Run on the PYNQ-Z2 board (pin constraints and a board clock source)
- [ ] Compare timing and area with the 2-stage core on the same FPGA

---

## Author and acknowledgements

**Abhishek Soni** ([@abhisshhekksoniii](https://github.com/abhisshhekksoniii)), B.Tech ECE, ABES Engineering College, Ghaziabad.

AI tools were used as helpers for review, debugging and documentation. All design decisions, code and results were reviewed and tested by the author. RISC-V is an open standard from RISC-V International.

---

## License

Released under the MIT License. See `LICENSE`.
