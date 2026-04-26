--------------------------------------------------------------------------------
-- File Name    : edge_detector.vhd
-- Author       : Imran
-- Date         : 26 April 2026
-- 
-- Description  : Generic rising-edge detector using a 3-process FSM. Includes 
--                a built-in 2-stage synchroniser on the asynchronous strobe 
--                input to prevent metastability, ensuring safe operation within 
--                the synchronous clock domain.
--
-- Dependencies : IEEE.STD_LOGIC_1164
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY edge_detector IS
    PORT (
        clk         : IN STD_LOGIC;
        reset       : IN STD_LOGIC;
        strb_in     : IN STD_LOGIC;            -- The asynchronous strobe input
        pedg_out    : OUT STD_LOGIC            -- The positive edge pulse output
    );
END edge_detector;

ARCHITECTURE behavioural OF edge_detector IS 
    TYPE STATES IS (S_ZERO, S_EDGE, S_ONE);

    SIGNAL state_cs, state_ns   : STATES := S_ZERO;
    -- Synchroniser registers for the async input
    SIGNAL strb_sync_s          : STD_LOGIC := '0';
    SIGNAL strb_safe_s          : STD_LOGIC := '0';

BEGIN 

    -- sequential process (state register)
    sync : PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN 
            state_cs <= S_ZERO;
            strb_sync_s <= '0';
            strb_safe_s <= '0';
        ELSIF rising_edge(clk) THEN 
            -- double-flop the async input to prevent metastability
            strb_sync_s <= strb_in;
            strb_safe_s <= strb_sync_s;

            -- clock the current state to the next state
            state_cs <= state_ns;
        END IF;
    END PROCESS;

    -- combinatorial process (next state logic)
    delta : PROCESS(state_cs, strb_safe_s)
        VARIABLE state_v : STATES;
    BEGIN 
        state_v := state_cs;

        CASE state_v IS 
            WHEN S_ZERO => 
                IF strb_safe_s = '1' THEN 
                    state_v := S_EDGE;
                END IF;
            WHEN S_EDGE =>
                IF strb_safe_s = '1' THEN 
                    state_v := S_ONE;
                ELSE 
                    state_v := S_ZERO;
                END IF;
            WHEN S_ONE => 
                IF strb_safe_s = '0' THEN 
                    state_v := S_ZERO;
                END IF;
        END CASE;

        state_ns <= state_v;
    END PROCESS;

    -- combinatorial process (output logic)
    lamba : PROCESS(state_cs)
    BEGIN 
        IF state_cs = S_EDGE THEN 
            pedg_out <= '1';
        ELSE 
            pedg_out <= '0';
        END IF;
    END PROCESS;
END behavioural;