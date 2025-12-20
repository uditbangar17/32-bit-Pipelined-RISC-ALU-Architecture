# Waveform Verification

This folder contains ModelSim waveform screenshots used to verify the
functional correctness of each pipeline stage in the 32-bit 5-stage
pipelined RISC processor.

All waveforms were captured after clean compilation and simulation,
with the clock, reset, pipeline registers, and control signals enabled.

---

## IF Stage – Instruction Fetch

[IF Stage](if_stage_instruction_fetch.png)

Verified signals:
- Program Counter (“pc“)
- Instruction output (“instr“)
- IF/ID pipeline register (“if_id_instr“)
- Clock synchronization

Observation:  
The PC increments correctly and the fetched instruction is latched into
the IF/ID pipeline register on each rising clock edge.

---

## ID/EX Stage – Decode & Register Read

[ID/EX Stage](id_ex_stage_decode_register_read.png)

Verified signals:
- Source registers (“rs“, “rt“)
- Immediate value (“id_ex_imm“)
- Control signals (“ALUSrc“, “RegWrite“)
- ID/EX pipeline register contents

Observation:  
Instruction fields and control signals are decoded correctly and passed
to the Execute stage without corruption.

---

## EX/MEM Stage – Execute & ALU Operation

[EX/MEM Stage](ex_mem_stage_alu_execution.png)

Verified signals:
- ALU operands (“ex_opA“, “ex_opB“)
- ALU result (“ex_alu_y“)
- ALU control select (“alu_sel“)
- EX/MEM pipeline register outputs

Observation:  
The ALU performs correct arithmetic operations, and results are forwarded
to the EX/MEM register, validating execution-stage functionality.

---

## WB Stage – Register Writeback

[WB Stage](04_WB_Writeback_Data_and_Register_Update.png

Verified signals:
- Write-back register index (“mem_wb_write_reg“)
- Write-back data (“wb_write_data“)
- Control signals (“RegWrite“, “MemToReg“)
- MEM/WB pipeline register outputs

Observation:  
The correct result is selected and written back to the destination register
at the WB stage, confirming end-to-end pipeline correctness.

---

## Summary

These waveforms collectively demonstrate:
- Correct instruction flow across all pipeline stages
- Proper pipeline register operation
- Accurate ALU execution and data propagation
- Successful register write-back

This waveform-based validation confirms the functional correctness of
the pipelined processor design.
