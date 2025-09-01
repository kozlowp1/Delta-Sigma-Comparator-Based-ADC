## How it works

This project explores the implementation of a delta-sigma ADC entirely in a digital environment. A flip-flop is used as the quantizer. Due to the strong DVT (device voltage threshold) dependency of flip-flops, a reference line is introduced. Assuming identical behavior across flip-flops, this helps mitigate vDVT variance.

Of course, in practice, flip-flops and capacitors are never perfectly matched. The goal is to evaluate how these mismatches affect ADC linearity, beyond the non-linearity introduced by the RC constant, and to observe the threshold behavior of the flip-flops. This is a quick, exploratory project, so some assumptions may be oversimplified or incorrect. However, in digital simulations, the concept appears to function as intended.

Implementing this on-chip (rather than on an FPGA) offers better control over parasitics at the silicon level, which could improve overall conversion accuracy.

## How to test

Start by defining the current range to be measured. For example, if the range is 0–100 µA, the baseline of the delta-sigma oscillation should be around 0.6 V (half of a 1.2 V supply). This gives:

R1 = Vc2 / I = 0.6 / (100e-6) = 6000 Ω

The current source is typically a reverse-biased photodiode, but an SMU (source measure unit) can also be used. The circuit is designed to operate in bipolar mode, meaning it can measure both positive and negative currents. 

To operate the system, begin by connecting the discrete components: resistors, capacitors, and a current source or sink. After setup, reset the unit.
To start data acquisition, send a pulse in the clk clock domain to uio__in[7]. This will trigger the transmission of three filtered data signals in the next clock cycle: filtered_a, filtered_b, and filtered_ab_subtr. For synchronisation, a valid_out signal is sent during the transmission of the first bit of data. This simple approach was chosen to simplify the implementation.


If the internal logic for data transmission fails, components like the CIC filter can be implemented on an FPGA. This can be done by routing the inverter output not only to the capacitor but also to the FPGA. Be mindful of additional parasitics introduced in this setup.

## External hardware

- **Two identical capacitors**: Test values ranging from picofarads to nanofarads. A similar analog-based design supported values from 30 pF (resulting in higher peaks between clock cycles) up to 1300 pF or more.
- **Two identical resistors**, e.g., 6000 Ω.
- **A current source/sink**

![](diagram.svg)
