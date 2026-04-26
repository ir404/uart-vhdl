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
        clk         : IN STD_LOGIC;
        sw          : IN STD_LOGIC_VECTOR (2 DOWNTO 0);     -- for SW 2,1,0
        btnC        : IN STD_LOGIC;                         -- centre push btn on the Basys3 board
        RsTx        : OUT STD_LOGIC;                        -- UART transmit pin connected to PC
        LEDs        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);     -- represents a 7-segment display on the board (low-active)
        digit_sel   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)      -- 7-segment digit select
    );
END uart_switch_tx_top;

ARCHITECTURE structural OF uart_switch_tx_top IS
    -- Bit patterns of the constants for the 7-segment LEDs (follows the hgfedcba pattern and is represented as high-active)
    CONSTANT ZERO : STD_LOGIC_VECTOR(7 DOWNTO 0)    := "00111111";
    CONSTANT ONE : STD_LOGIC_VECTOR(7 DOWNTO 0)     := "00000110"; 
    CONSTANT TWO : STD_LOGIC_VECTOR(7 DOWNTO 0)     := "01011011";
    CONSTANT THREE : STD_LOGIC_VECTOR(7 DOWNTO 0)   := "01001111";
    CONSTANT FOUR : STD_LOGIC_VECTOR(7 DOWNTO 0)    := "01100110";
    CONSTANT FIVE : STD_LOGIC_VECTOR(7 DOWNTO 0)    := "01101101";
    CONSTANT SIX : STD_LOGIC_VECTOR(7 DOWNTO 0)     := "01111101";
    CONSTANT SEVEN : STD_LOGIC_VECTOR(7 DOWNTO 0)   := "00000111";
    CONSTANT EIGHT : STD_LOGIC_VECTOR(7 DOWNTO 0)   := "01111111";
    CONSTANT NINE : STD_LOGIC_VECTOR(7 DOWNTO 0)    := "01101111";

    -- Internal signals
    SIGNAL send_s       : STD_LOGIC := '0';
    SIGNAL tx_data_s    : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
BEGIN 
    -- concurrent ASCII conversion
    tx_data_s <= "00110" & sw;
    -- turn ON only the third digit (from the left)
    digit_sel <= "1101";

    PROCESS(sw) 
        VARIABLE led_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
    BEGIN 
        CASE sw IS
            WHEN "001" =>
                led_v := ONE;
            WHEN "010" =>
                led_v := TWO;
            WHEN "011" =>
                led_v := THREE;
            WHEN "100" =>
                led_v := FOUR;
            WHEN "101" =>
                led_v := FIVE;
            WHEN "110" =>
                led_v := SIX;
            WHEN "111" =>
                led_v := SEVEN;
            WHEN OTHERS => 
                led_v := ZERO;
        END CASE;
        LEDs <= NOT(led_v);
    END PROCESS;

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