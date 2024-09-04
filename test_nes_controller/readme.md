# NES Controller Test Bench README

## Overview

This README provides instructions for users on how to edit button states in the `nes_controller_tb.v` test bench and run the associated tests using the `test_controller.sh` script. The test bench is designed to simulate the behavior of an NES controller and verify the functionality of the Verilog design.

## Prerequisites

- **Verilog Simulator**: Ensure you have a Verilog simulator installed, Icarus Verilog (iverilog) to be specific.
- **GTKWave**: Make sure GTKWave is installed for waveform viewing.
- **Shell Environment**: The `test_controller.sh` script is written for a Unix-like shell environment.

## Directory Structure

The test files are located in the `test_nes_controller` directory. You must navigate to this directory before running the tests.

```
test_nes_controller/
├── nes_controller_tb.v
├── test_controller.sh
└── dump.vcd
```

## Editing Button States

To simulate different button presses, you will need to modify the `data` signal within the `nes_controller_tb.v` file. The `data` signal represents the serial input from the NES controller, and each bit corresponds to the state of a specific button. Set `data = 0;` to press a button or `data = 1;` for the opposite.

## Running the Test Bench

1. **Navigate to the Test Directory**:
   ```sh
   cd test_nes_controller
   ```

2. **Run the Test Script**:
   ```sh
   ./test_controller.sh
   ```

   This script will:
   - Compile and run the `nes_controller_tb.v` test bench using a Verilog simulator.
   - Open GTKWave with the generated `dump.vcd` file for waveform analysis.

3. **Analyze the Results**:
   - The terminal will display the button states based on your test scenario.
   - GTKWave will open, allowing you to visually inspect the waveform for the simulated NES controller signals.

## Customization

You can further customize the test bench by:
- **Adding more test cycles**: Copy and modify existing cycles in the `initial` block to extend the simulation.

## Conclusion

This test bench and script setup allows you to easily simulate and validate NES controller behavior. By editing the `data` signal in the `nes_controller_tb.v` file, you can simulate different button press scenarios and ensure your design meets the expected functionality.