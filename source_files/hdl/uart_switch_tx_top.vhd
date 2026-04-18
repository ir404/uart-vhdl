--------------------------------------------------------------------------------
-- File Name    : uart_switch_tx_top.vhd
-- Author       : Imran
-- Date         : 18 April 2026
-- 
-- Description  : Top-level module for standalone UART transmission testing. 
--                Reads a 3-bit binary value from hardware switches (SW2-SW0), 
--                converts it to its ASCII character equivalent, and transmits 
--                it to a PC via UART. 
--
--                Transmission is triggered by the centre push-button (btnC). 
--                The module features an edge-detector with synchronisation 
--                registers to prevent metastability and ensure only a single 
--                packet is sent per button press.
--
-- Dependencies : IEEE.STD_LOGIC_1164, uart_tx
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

ARCHITECTURE behavioral OF uart_switch_tx_top IS
    -- Internal signals
    SIGNAL btn_sync_s   : STD_LOGIC := '0';
    SIGNAL btn_prev_s   : STD_LOGIC := '0';
    SIGNAL send_s       : STD_LOGIC := '0';
    SIGNAL tx_data_s    : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

BEGIN 

    -- Edge Detector & ASCII Converter
    PROCESS (clk)
        VARIABLE btn_sync_v : STD_LOGIC;
        VARIABLE btn_prev_v : STD_LOGIC;
    BEGIN 
        IF rising_edge(clk) THEN 
            btn_prev_v  := btn_sync_s;
            btn_sync_v  := btnC;

            -- trigger ONLY on the rising edge (i.e. when the btnC state transitions from 0 to 1)
            IF btn_sync_v = '1' AND btn_prev_v = '0' THEN 
                send_s  <= '1';
                tx_data_s <= "00110" & sw;              -- concatenate "00110" with the 3 switch bits to create ASCII 0-7
            ELSE 
                send_s <= '0';
            END IF;

            -- update signals with variable values
            btn_sync_s <= btn_sync_v;
            btn_prev_s <= btn_prev_v;
        END IF;
    END PROCESS;

    -- Instantiate the transmitter
    tx_inst : ENTITY work.uart_tx PORT MAP(
        clk         => clk,
        send        => send_s,
        data        => tx_data_s,
        ready       => OPEN,
        uart_tx_bit => RsTx
    );
END behavioral;