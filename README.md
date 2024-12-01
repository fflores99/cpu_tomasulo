# Tomasulo algorithm implementation

This repository contains the implementation of a Tomasulo algorithm for a Superscalar CPU based on RISC-V architecture.

## Content
- assembly: This folder contains the assembli code written in RARS RISC-V simulator.
    - bin: This folder contains the assembly codes made a hex file to be loaded in memory.
- sim: this folder contains the simulation files
    - do: wavefor files to be loaded in questa sim.
    - questa: Questa Sim project folder.
    - testbench: System Verilog testbench files
- src: System Verilog source files, organized in folders on common, frontend, backend, and modules.

## Simulation procedure
1. Unzip the folder
2. You can either create a project on questa sim and import all files in src folder and its subfolders, or import the project from the questa folder.
3. rom.sv file will already have the relative path toi the bubble sort hex file. You can load your own binary file by updating line 13 on rom.sv file with the path of your own .bin or .txt file.
    - If updating the code, change the .SIZE() calue on cpu_tb.sv on ROM instance to the acxtual size of your code in bytes. 
4. Load the cpu_tb.sv file into the project if not included yet.
5. Start simulation of cpu_tb.sv
6. Run the following command <b>do ../do/cpu_sin.do</b>.
    - The waveforms of the cpu should appear in the waveform window organized in sections.

### Authors
Francisco Rafael Flores de Maria y Campos.

