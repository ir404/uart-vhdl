# FPGA UART Interface & Hardware Controller

A robust, from-scratch implementation of a Universal Asynchronous Receiver-Transmitter (UART) system in VHDL. Designed and tested on the Digilent Basys 3 FPGA (Artix-7), this project features reliable serial communication, physical hardware control, mechanical switch synchronisation, and 7-segment display multiplexing.

## Project Overview

This repository contains the structural and behavioural VHDL designs required to establish reliable PC-to-FPGA serial communication. It bridges the gap between asynchronous human input (buttons/switches) and the strict synchronous clock domain of the FPGA.

### Key Features
* **Standard 8N1 UART Protocol:** Custom `Tx` and `Rx` modules operating at 9600 baud (derived from a 100 MHz system clock).
* **Metastability Prevention:** Implements a 2-stage flip-flop synchroniser to safely transition asynchronous mechanical button presses into the internal clock domain.
* **Finite State Machines (FSM):** Clean FSM architectures used for both protocol transmission and rising-edge detection.
* **Structural Modularity:** Top-level designs act as blueprints, wiring together reusable sub-modules.
* **Hardware Multiplexing:** Combinatorial logic to translate binary switch states into ASCII data for transmission, while simultaneously driving an active-low multiplexed 7-segment display.

---

## System Architecture

The project is divided into core utility modules and top-level structural implementations.

### Core Modules
* `uart_tx.vhd`: The UART transmitter. Uses an FSM to send 8-bit data packets serially alongside start and stop bits.
* `uart_rx.vhd`: The UART receiver. Uses oversampling and an internal timer to reliably read incoming serial data and flag frame errors.
* `edge_detector.vhd`: A generic utility module. Combines a 2-stage input synchroniser with a 3-process FSM to generate a clean, single clock-cycle pulse from a noisy asynchronous strobe input.

### Top-Level Implementations
* **`uart_loopback_top.vhd` (Echo Chamber)**
  * Directly routes the `uart_rx` data output into the `uart_tx` data input.
  * *Purpose:* Verifies the physical USB-UART bridge and state machine integrity by instantly echoing typed characters back to the terminal.
* **`uart_switch_tx_top.vhd` (Hardware Control & Display)**
  * Reads a 3-bit binary value from hardware switches `[SW2:SW0]`.
  * Translates the binary value into an ASCII character and dynamically displays the decimal number on a single, multiplexed 7-segment digit.
  * Transmits the ASCII character to a PC terminal only when the centre push-button (`btnC`) is pressed, ensuring exactly one packet per press via the edge detector.

---

## Hardware Setup & Usage

### Prerequisites
* **Board:** Digilent Basys 3 (Xilinx Artix-7)
* **Software:** Xilinx Vivado, Tera Term (or any serial terminal)
* **Connection:** Micro-USB cable (handles both JTAG programming and UART communication)

### Pin Mapping
* **Clock:** 100 MHz (`W5`)
* **UART:** `RsTx` (`A18`), `RsRx` (`B18`)
* **Inputs:** Switches `[V17, V16, W16]`, Centre Button (`U18`)
* **Display:** Cathodes `[W7...V7]`, Anodes (`digit_sel`) `[W4...U2]`

### Running the Project
1. Open Tera Term and establish a new **Serial** connection to your Basys 3 COM port.
2. Navigate to *Setup > Serial Port* and configure to **9600 Baud, 8 Data bits, No Parity, 1 Stop bit**.
3. Flash the generated bitstream (`.bit`) file to the FPGA using Vivado's Hardware Manager.
   * *Note: If Tera Term stops receiving data after reprogramming, simply restart the Tera Term connection to refresh the USB COM drivers.*
4. Toggle the physical switches to select a number (0-7). Verify the output on the 7-segment display.
5. Press the centre button to transmit the selected number to your serial terminal.
