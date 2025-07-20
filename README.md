# Simple Processor in Verilog

This project implements a basic 9-bit processor in Verilog, capable of executing a small instruction set including `mv`, `mvi`, `add`, `sub`, and a custom instruction called `ones`, which counts the number of 1s in a value.

## Files Overview

- `main.v`: Top-level module that instantiates the processor.
- `proc.v`: Main processor logic including FSM, datapath, and control logic.
- `ALU.v`: Arithmetic Logic Unit implementing addition, subtraction, and bit-counting.
- `regn.v`: Register module.
- `multiplexers.v`: Controls routing of data across the internal bus.
- `dec3to8.v`: 3-to-8 decoder for register addressing.
- `waveform.wmf`: Simulation file for waveform testing.

## Target FPGA

This project was tested on the **Intel Cyclone V SoC (5CSXFC6D6F31C6)** FPGA board.  
Any FPGA with similar I/O capability and support for Quartus should be compatible.

## How to Compile

1. Open **Quartus** and create a new project.
2. Add all Verilog source files (`main.v`, `proc.v`, `ALU.v`, etc.) to the project.
3. Assign the necessary pins using your board’s pin planner (based on your specific setup).
4. Compile the project (`Processing > Start Compilation`).
5. After successful compilation, use **Programmer** tool to upload the `.sof` file to your FPGA.

## How to Use

- Inputs:
  - `DIN[8:0]`: Data input
  - `Run`: Begin execution of an instruction
  - `Clock`, `Resetn`: Clock and asynchronous reset
- Outputs:
  - `Done`: Indicates instruction execution finished
  - `BusWires[8:0]`: The internal 9-bit bus (can be monitored for debug)

## Simulation

Use the `waveform.wmf` file with the **ModelSim** simulator or **Quartus**' built-in simulator to observe signal behavior.  
Make sure to include all modules and set `main` as the top-level module.

---

This is a simple educational processor project meant to demonstrate the construction of a datapath, ALU, and control logic using Verilog.

