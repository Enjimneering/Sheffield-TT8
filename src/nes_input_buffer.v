/*
Project: TinyTapeStation
Author : Kwashie Andoh
Module: NES Gamepad Edge Detection Module

Summary:
This module generates a pulse when a button release is detected on an NES gamepad.

Description:
The `button_release_pulse` module detects the falling edge of the `button_in` signal, 
which corresponds to the release of a button on the NES gamepad. 
When a button release is detected, the module outputs a pulse on the `pulse_out` signal. 
The module includes an `enable` input to control whether the edge detection is active. 
When `enable` is low, the module does not generate pulses but continues to update its internal state.

Inputs:
- clk: Clock signal.
- reset: Asynchronous reset signal.
- enable: Enable signal to control edge detection.
- button_in: Input signal from the NES gamepad button.

Outputs:
- pulse_out: Output pulse signal indicating a button release.

*/
module button_release_pulse (
    input wire clk,
    input wire reset,
    input wire enable,  // New enable input
    input wire button_in,
    output reg pulse_out
);

    reg button_prev;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pulse_out <= 1'b0;
            button_prev <= 1'b0;
        end else if (enable) begin
            // Edge detection for falling edge (button release)
            pulse_out <= button_prev & ~button_in;
            button_prev <= button_in;
        end else begin
            pulse_out <= 1'b0;
            button_prev <= button_in;  // Still update button_prev even when not enabled
        end
    end

endmodule