LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY uart_tx_tb IS
    -- Testbenches do not have ports because they are self-contained environments
END uart_tx_tb;

ARCHITECTURE behaviour OF uart_tx_tb IS

    -- Testbench constants
    CONSTANT CLK_PERIOD  : time := 10 ns;       -- 10 ns period represents a 100 MHz clock
    CONSTANT C_BAUD_RATE : integer := 115200;   -- Sped up from 9600 to make the simulation finish much faster

    -- UUT (Unit Under Test) Signals
    SIGNAL clk_s         : STD_LOGIC := '0';
    SIGNAL send_s        : STD_LOGIC := '0';
    SIGNAL data_s        : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ready_s       : STD_LOGIC;
    SIGNAL uart_tx_bit_s : STD_LOGIC;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: ENTITY work.uart_tx
        GENERIC MAP (
            CLK_FREQ   => 100000000,
            BAUD_RATE  => C_BAUD_RATE,
            DATA_WIDTH => 8
        )
        PORT MAP (
            clk         => clk_s,
            send        => send_s,
            data        => data_s,
            ready       => ready_s,
            uart_tx_bit => uart_tx_bit_s
        );

    -- Clock generation process
    clk_process : PROCESS
    BEGIN
        clk_s <= '0';
        WAIT FOR CLK_PERIOD / 2;
        clk_s <= '1';
        WAIT FOR CLK_PERIOD / 2;
    END PROCESS;

    -- Stimulus process to test the module's responses
    stim_process: PROCESS
    BEGIN
        -- 1. Initialise and wait for the system to settle
        WAIT FOR 100 ns;

        -- 2. Transmit the first character: 'A' (ASCII 0x41 / "01000001")
        data_s <= x"41";
        send_s <= '1';
        WAIT FOR CLK_PERIOD;    -- Pulse the send signal for exactly one clock cycle
        send_s <= '0';

        -- 3. Wait for the transmission to finish
        -- The ready signal drops low during transmission, then returns high when idle
        WAIT UNTIL ready_s = '1';
        WAIT FOR 1 us;          -- Provide a brief buffer before the next transmission

        -- 4. Transmit the second character: 'Z' (ASCII 0x5A / "01011010")
        data_s <= x"5A";
        send_s <= '1';
        WAIT FOR CLK_PERIOD;
        send_s <= '0';

        WAIT UNTIL ready_s = '1';
        
        -- End the simulation permanently
        WAIT;
    END PROCESS;

END behaviour;