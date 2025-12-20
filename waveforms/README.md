# Waveform Verification

This directory contains ModelSim waveform screenshots used to verify the
functional correctness of each pipeline stage of the 32-bit pipelined RISC processor.

Each waveform corresponds to a specific pipeline stage and demonstrates
correct signal propagation, control behavior, and data flow across pipeline registers.

---

## 01. IF Stage – Instruction Fetch

[IF Stage](01_IF_Instruction_Fetch.png)

Verified signals:
- Program Counter (PC)
- Instruction Memory Output
- IF/ID pipeline register

Observation:  
The PC increments correctly and instructions are fetched sequentially
from instruction memory.

---

## 02. ID/EX Stage – Decode and Register Read

[ID Stage](02_ID_EX_Decode_and_Register_Read.png)

Verified signals:
- Source register indices
- Register file read data
- Immediate generation
- Control signals latched into ID/EX register

Observation:  
Instruction fields are correctly decoded and operands are read from
the register file.

---

## 03. EX/MEM Stage – ALU Execution and Forwarding

[EX Stage](03_EX_MEM_ALU_Execution_and_Forwarding.png)

Verified signals:
- ALU operands and result
- Forwarding control signals
- EX/MEM pipeline register outputs

Observation:  
ALU operations execute correctly, and data forwarding resolves
read-after-write hazards without unnecessary stalls.

---

## 04. WB Stage – Register Writeback

[WB Stage](04_WB_Writeback_Data_and_Register_Update.png)

Verified signals:
- Destination register (“mem_wb_write_reg“)
- Write-back data (“wb_write_data“)
- Write enable (“RegWrite“)
- MEM/WB pipeline register

Observation:  
The correct result is written back to the register file on the rising
clock edge, confirming end-to-end pipeline correctness.

---

## Summary

These waveforms collectively demonstrate:
- Correct pipeline sequencing
- Proper control signal propagation
- Functional hazard detection and data forwarding
- Correct register write-back behavior
