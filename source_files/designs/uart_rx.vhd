--------------------------------------------------------------------------------
-- File Name    : uart_rx.vhd
-- Author       : Imran
-- Date         : 17 April 2026
-- 
-- Description  : Universal Asynchronous Receiver-Transmitter (UART) Receiver.
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

ENTITY uart_rx IS
    PORT (
        clk         : IN STD_LOGIC;
        uart_rx_bit : IN STD_LOGIC;
        data        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        data_valid  : OUT STD_LOGIC;
        frame_err   : OUT STD_LOGIC
    );
END uart_rx;

ARCHITECTURE behavioral OF uart_rx IS 
    CONSTANT CLK_FREQ       : INTEGER := 100000000;             -- 100 MHz system clock
    CONSTANT BAUD_RATE      : INTEGER := 9600;                  -- bits per second
    CONSTANT BAUD_PERIOD    : INTEGER := CLK_FREQ / BAUD_RATE;  -- Cycles per bit
    CONSTANT DATA_WIDTH     : INTEGER := 8;                     -- 8 data bits

    -- State definition
    TYPE state_type IS (IDLE, START_SYNC, READ_DATA, CHECK_STOP);

    -- Internal signals
    SIGNAL state_s          : state_type := IDLE;
    SIGNAL timer_s          : INTEGER RANGE 0 TO BAUD_PERIOD := 0;
    SIGNAL bit_ix_s         : INTEGER RANGE 0 TO DATA_WIDTH - 1 := 0;
    SIGNAL data_reg_s       : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL frame_err_s      : STD_LOGIC := '0';
    SIGNAL data_valid_s     : STD_LOGIC := '0';

BEGIN 

    PROCESS (clk)
        -- variables for seq logic
        VARIABLE state_v      : state_type;
        VARIABLE timer_v      : INTEGER RANGE 0 TO BAUD_PERIOD;
        VARIABLE bit_ix_v     : INTEGER RANGE 0 TO DATA_WIDTH - 1;
        VARIABLE data_reg_v   : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE frame_err_v  : STD_LOGIC;
        VARIABLE data_valid_v : STD_LOGIC;
    BEGIN
        IF rising_edge(clk) THEN 
            state_v      := state_s;
            timer_v      := timer_s;
            bit_ix_v     := bit_ix_s;
            data_reg_v   := data_reg_s;
            frame_err_v  := frame_err_s;
            data_valid_v := '0';

            CASE state_v IS 
                WHEN IDLE =>
                    timer_v := 0;
                    IF uart_rx_bit = '0' THEN           -- a start bit is detected
                        state_v := START_SYNC;
                    END IF;

                WHEN START_SYNC =>
                    IF timer_v = BAUD_PERIOD / 2 THEN
                        timer_v := 0;
                        IF uart_rx_bit = '0' THEN
                            bit_ix_v := 0;
                            state_v := READ_DATA;
                        ELSE 
                            state_v := IDLE;
                        END IF;
                    ELSE 
                        timer_v := timer_v + 1;
                    END IF;

                WHEN READ_DATA => 
                    IF timer_v = BAUD_PERIOD THEN 
                        timer_v := 0;
                        data_reg_v(bit_ix_v) := uart_rx_bit;

                        IF bit_ix_v = DATA_WIDTH - 1 THEN
                            state_v := CHECK_STOP;
                        ELSE
                            bit_ix_v := bit_ix_v + 1;
                        END IF;
                    ELSE 
                        timer_v := timer_v + 1;
                    END IF;

                WHEN CHECK_STOP =>
                    IF timer_v = BAUD_PERIOD THEN
                        -- check if the stop bit is '1'
                        IF uart_rx_bit = '1' THEN
                            frame_err_v := '0';
                            data_valid_v := '1';
                        ELSE 
                            frame_err_v := '1';
                        END IF;
                        state_v := IDLE;
                    ELSE 
                        timer_v := timer_v + 1;
                    END IF;

            END CASE;

            -- update signals with the variable values
            state_s         <= state_v;
            timer_s         <= timer_v;
            bit_ix_s        <= bit_ix_v;
            data_reg_s      <= data_reg_v;
            frame_err_s     <= frame_err_v;
            data_valid_s    <= data_valid_v;
        END IF;
    END PROCESS;

    -- update the output ports
    data        <= data_reg_s;
    data_valid  <= data_valid_s;
    frame_err   <= frame_err_s;
    
END behavioral;