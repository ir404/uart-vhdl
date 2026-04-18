LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY uart_tx_tb IS
-- Testbenches have no ports
END uart_tx_tb;

ARCHITECTURE sim OF uart_tx_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT uart_tx_module
        PORT (
            send        : IN STD_LOGIC;
            data        : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            clk         : IN STD_LOGIC;
            ready       : OUT STD_LOGIC;
            uart_tx_bit : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Signals to connect to the UUT
    SIGNAL clk_tb         : STD_LOGIC := '0';
    SIGNAL send_tb        : STD_LOGIC := '0';
    SIGNAL data_tb        : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ready_tb       : STD_LOGIC;
    SIGNAL uart_tx_bit_tb : STD_LOGIC;

    -- Clock period definitions (100 MHz = 10ns)
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: uart_tx_module
        PORT MAP (
            send        => send_tb,
            data        => data_tb,
            clk         => clk_tb,
            ready       => ready_tb,
            uart_tx_bit => uart_tx_bit_tb
        );

    -- Clock generation process
    clk_process : PROCESS
    BEGIN
        clk_tb <= '0';
        WAIT FOR clk_period/2;
        clk_tb <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc: PROCESS
    BEGIN		
        -- Initial Wait
        WAIT FOR 100 ns;

        -- Test Case 1: Send character 'A' (Binary: 01000001, Hex: 0x41)
        WAIT UNTIL ready_tb = '1'; -- Ensure the module is IDLE
        data_tb <= "01000001";
        send_tb <= '1';
        WAIT FOR clk_period;       -- Hold send for one clock cycle
        send_tb <= '0';

        -- Wait for the transmission to finish (10 bits * 104us each)
        -- We wait until 'ready' goes high again
        WAIT UNTIL ready_tb = '1';
        WAIT FOR 200 us;           -- Small gap between transmissions

        -- Test Case 2: Send character 'B' (Binary: 01000010, Hex: 0x42)
        data_tb <= "01000010";
        send_tb <= '1';
        WAIT FOR clk_period;
        send_tb <= '0';

        WAIT UNTIL ready_tb = '1';
        
        -- End Simulation
        REPORT "Simulation Finished Successfully";
        WAIT;
    END PROCESS;

END sim;