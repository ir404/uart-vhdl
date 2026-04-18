--------------------------------------------------------------------------------
-- File Name    : uart_loopback_top.vhd
-- Author       : Imran
-- Date         : 18 April 2026
-- 
-- Description  : Top-level structural module for UART loopback testing.
--                This module acts as an "echo chamber" by directly wiring 
--                the output of the UART receiver (uart_rx) into the input 
--                of the UART transmitter (uart_tx). 
--
--                Any character received from the PC via the RsRx pin is 
--                immediately transmitted back out via the RsTx pin, 
--                verifying that both state machines and the physical 
--                USB-UART bridge are functioning correctly.
--
-- Dependencies : IEEE.STD_LOGIC_1164, uart_rx, uart_tx
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY uart_loopback_top IS
    PORT (
        clk 	: IN STD_LOGIC;
        RsRx 	: IN STD_LOGIC; 	-- USB-UART Rx pin (from PC)
        RsTx 	: OUT STD_LOGIC 	-- USB-UART Tx pin (to PC)
    );
END uart_loopback_top;

ARCHITECTURE structural OF uart_loopback_top IS
    -- Internal signals
    SIGNAL data_bus_s 	: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL data_ready_s : STD_LOGIC;
BEGIN

    -- Instantiate the receiver
    rx_inst : ENTITY work.uart_rx PORT MAP (
        clk         => clk,
        uart_rx_bit => RsRx,                -- receives bits from the PC
        data        => data_bus_s,          -- receives data from the PC
        data_valid  => data_ready_s,
        frame_err   => OPEN
    );

    -- Instantiate the transmitter
    tx_inst : ENTITY work.uart_tx PORT MAP (
        clk         => clk,
        send        => data_ready_s,         -- RX triggers TX directly
        data        => data_bus_s,          -- TX reads the RX bit
        ready       => OPEN,
        uart_tx_bit => RsTx                 -- sends bits to PC
    );
END structural;