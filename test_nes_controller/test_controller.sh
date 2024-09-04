#!/bin/bash

# Compile the Verilog files
iverilog -o nes_controller_tb.vvp nes_controller_tb.v ../src/nes_controller.v

# Run the simulation
vvp nes_controller_tb.vvp

# Open the waveform in GTKWave
gtkwave dump.vcd