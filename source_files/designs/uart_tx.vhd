--------------------------------------------------------------------------------
-- File Name    : uart_tx.vhd
-- Author       : Imran
-- Date         : 16 April 2026
-- 
-- Description  : Universal Asynchronous Receiver-Transmitter (UART) Transmitter.
--                Transmits 8-bit data packets serially over a single line using 
--                the standard 8N1 protocol (1 start bit, 8 data bits, no parity, 
--                1 stop bit). 
--
--                The module utilises a Finite State Machine (FSM) to manage 
--                transmission states and handles internal logic using variables 
--                to prevent signal scheduling delays.
--
-- Parameters   : CLK_FREQ  - System clock frequency (default: 100 MHz)
--                BAUD_RATE - Target transmission rate (default: 9600 bps)
--
-- Dependencies : IEEE.STD_LOGIC_1164, IEEE.NUMERIC_STD
--------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY uart_tx IS
    PORT (
        send        : IN STD_LOGIC;
        data        : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clk         : IN STD_LOGIC;
        ready       : OUT STD_LOGIC;
        uart_tx_bit : OUT STD_LOGIC
    );
END uart_tx;

ARCHITECTURE behavioral OF uart_tx IS
    CONSTANT CLK_FREQ       : INTEGER := 100000000;             -- 100 MHz system clock
    CONSTANT BAUD_RATE      : INTEGER := 9600;                  -- bits per second
    CONSTANT BAUD_PERIOD    : INTEGER := CLK_FREQ / BAUD_RATE;  -- Cycles per bit
    CONSTANT PACKET_WIDTH   : INTEGER := 10;                    -- Start bit, 8 data bits, stop bit
    
    -- State machine definitions
    TYPE state_type IS (IDLE, LOAD_BIT, SEND_BIT);

    -- Internal Signals
    SIGNAL state_s          : state_type := IDLE;
    SIGNAL timer_s          : INTEGER RANGE 0 TO BAUD_PERIOD := 0;
    SIGNAL packet_s         : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '1'); 
    SIGNAL bit_ix_s         : INTEGER RANGE 0 TO 10 := 0;
    SIGNAL tx_reg_s         : STD_LOGIC := '1';                 -- By default, it's HIGH when IDLE

BEGIN 

    PROCESS (clk)
        VARIABLE state_v    : state_type; 
        VARIABLE bit_ix_v   : INTEGER RANGE 0 TO 10;
    BEGIN 
        IF rising_edge(clk) THEN
            state_v  := state_s;
            bit_ix_v := bit_ix_s;

            CASE state_v IS
                WHEN IDLE => 
                    tx_reg_s <= '1';                    -- keep line at '1' indicating that nothing is being transmitted
                    bit_ix_v := 0;
                    
                    IF send = '1' THEN 
                        packet_s <= '1' & data & '0';   -- [Stop (1), Data (8 bits), Start (0)], start is 0 to indicate the starting point of the data packet
                        state_v  := LOAD_BIT;
                    END IF;

                WHEN LOAD_BIT => 
                    -- Pull the current bit from the packet as the next one to transmit
                    tx_reg_s <= packet_s(bit_ix_v);
                    state_v  := SEND_BIT;

                WHEN SEND_BIT => 
                    -- Hold the bit on the wire for the duration of the baud period
                    IF timer_s = BAUD_PERIOD THEN
                        timer_s <= 0;
                        IF bit_ix_v = PACKET_WIDTH - 1 THEN
                        	state_v := IDLE;
                        ELSE
							bit_ix_v := bit_ix_v + 1;   -- point to the next bit in the packet to transfer 
							state_v  := LOAD_BIT;
                        END IF;
                    ELSE 
                        timer_s <= timer_s + 1;
                    END IF;
            END CASE;

            -- Update signals from variables at PROCESS end
            state_s  <= state_v;
            bit_ix_s <= bit_ix_v;
        END IF;
    END PROCESS;

    -- Output port assignments
    ready <= '1' WHEN (state_s = IDLE) ELSE '0';
    uart_tx_bit <= tx_reg_s;

END behavioral;