library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity test_tx is
end test_tx;

ARCHITECTURE behavior OF test_tx IS 

    --Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal tx_start : std_logic := '0';
    signal tick : std_logic := '0';
    signal din : std_logic_vector(7 downto 0) := (others => '0');

    --Outputs
    signal tx_done_tick : std_logic;
    signal tx : std_logic;

    -- Clock period definitions
    constant clk_period : time := 10 ns;
    constant tick_period : time := clk_period * 10;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.uart_tx(default) port map (
        clk => clk,
        reset => reset,
        tx_start => tx_start,
        tick => tick,
        din => din,
        tx_done_tick => tx_done_tick,
        tx => tx
    );

    -- Clock process definitions
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    tick_process :process
    begin
        tick <= '0';
        wait for tick_period/2;
        tick <= '1';
        wait for tick_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        din <= "00100100";

        reset <= '1';
        wait for clk_period;

        reset <= '0';
        wait for clk_period;

        tx_start <= '1';
        wait for clk_period;

        tx_start <= '0';

        wait;
    end process;

    tx_monitor: process(tick, tx)
    begin
        if rising_edge(tick) then
            assert false report "Tick: tx=" & to_string(tx) severity note;
--            wait for clk_period;
        end if;
    end process;

    tx_done_monitor: process(tx_done_tick)
    begin
        if rising_edge(tx_done_tick) then
            assert false report "TX Done!" severity note;
        end if;
    end process;
end;
