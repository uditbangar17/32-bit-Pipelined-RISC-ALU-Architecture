# Design & Optimization of a 32-bit Pipelined RISC Processor

## Overview

This project focuses on the *RTL design, optimization, and verification of a 32-bit Arithmetic Logic Unit (ALU)* and its integration into a *5-stage pipelined RISC processor*.  
The design emphasizes *performance optimization, modular architecture, and pipeline correctness*, making it suitable for graduate-level computer architecture coursework and research-oriented study.

The processor is implemented in *Verilog HDL* and follows a classical RISC pipeline structure with additional support for *data hazard detection and forwarding*.

## Processor Architecture

The processor follows a *classical 5-stage RISC pipeline* consisting of:

1. *Instruction Fetch (IF)* – Fetches the instruction from instruction memory  
2. *Instruction Decode (ID)* – Decodes the instruction and reads register operands  
3. *Execute (EX)* – Performs arithmetic and logical operations using the ALU  
4. *Memory Access (MEM)* – Accesses data memory for load/store instructions  
5. *Write Back (WB)* – Writes the result back to the register file  

Pipeline registers separate each stage to enable *instruction-level parallelism* and improve overall throughput.
