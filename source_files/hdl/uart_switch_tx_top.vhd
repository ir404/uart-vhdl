--------------------------------------------------------------------------------
-- File Name    : uart_switch_tx_top.vhd
-- Author       : Imran
-- Date         : 26 April 2026
-- 
-- Description  : Top-level structural module for standalone UART transmission. 
--                Reads a 3-bit binary value from hardware switches (SW2-SW0), 
--                converts it to its ASCII character equivalent, and transmits 
--                it to a PC via UART. 
--
--                Transmission is triggered by the centre push-button (btnC). 
--                This module acts as a structural blueprint, instantiating 
--                the UART transmitter and a generic edge detector to safely 
--                synchronise the mechanical button press into the clock domain.
--
-- Dependencies : IEEE.STD_LOGIC_1164, uart_tx, edge_detector
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY uart_switch_tx_top IS
    PORT (
        clk     : IN STD_LOGIC;
        sw      : IN STD_LOGIC_VECTOR (2 DOWNTO 0);     -- for SW 2,1,0
        btnC    : IN STD_LOGIC;                         -- centre push btn on the Basys3 board
        RsTx    : OUT STD_LOGIC                         -- UART transmit pin connected to PC
    );
END uart_switch_tx_top;

ARCHITECTURE structural OF uart_switch_tx_top IS
    -- Internal signals
    SIGNAL send_s       : STD_LOGIC := '0';
    SIGNAL tx_data_s    : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

BEGIN 
    -- concurrent ASCII conversion
    tx_data_s <= "00110" & sw;

    -- Instantiate the edge detector to detect button press
    edge_detector_inst : ENTITY work.edge_detector PORT MAP(
        clk         => clk,
        reset       => '0',
        strb_in     => btnC,
        pedg_out    => send_s
    );

    -- Instantiate the transmitter
    tx_inst : ENTITY work.uart_tx PORT MAP(
        clk         => clk,
        send        => send_s,
        data        => tx_data_s,
        ready       => OPEN,
        uart_tx_bit => RsTx
    );
END structural;