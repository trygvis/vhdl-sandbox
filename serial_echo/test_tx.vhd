library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity test_tx is
end test_tx;

architecture behavior of test_tx is

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal tx_start : std_logic := '0';
    signal tick : std_logic := '0';
    signal din : std_logic_vector(7 downto 0) := (others => '0');

    signal tx_done_tick : std_logic;
    signal tx : std_logic;

    constant clk_period : time := 10 ns;
    constant tick_period : time := clk_period * 10;
begin
    uut: entity work.uart_tx(default) port map (
        clk => clk,
        reset => reset,
        tx_start => tx_start,
        tick => tick,
        din => din,
        tx_done_tick => tx_done_tick,
        tx => tx
    );

    clk <= not clk after 0.5 * clk_period;
    tick <= not tick after 0.5 * tick_period;
    reset <= '1', '0' after (1.75 * clk_period);

    stim_proc: process
    begin
        din <= "00100100";
        wait until rising_edge(clk) and reset='1';
        wait until rising_edge(clk) and reset='0';
        assert false report "Toggling tx_start";
        tx_start <= '1', '0' after clk_period;
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
