library ieee;
use ieee.std_logic_1164.all;

entity test_mod_m_counter is
end test_mod_m_counter;

architecture default of test_mod_m_counter is
    signal clk, reset: std_logic := '0';
    signal max_tick: std_logic := '0';
    constant clk_period : time := 10 ns;
begin
    clk <= not clk after 0.5 * clk_period;
    reset <= '1', '0' after (1.75 * clk_period);

    baud_gen_unit: entity work.mod_m_counter(behavioral)
        generic map(
            M => 10,
            BITS => 10)
        port map(
            clk => clk,
            reset => reset,
--            q => open,
            max_tick => max_tick);

    clk_monitor: entity work.signal_monitor(r_edge) generic map("clk") port map (clk);
    max_tick_monitor: entity work.signal_monitor(r_edge) generic map("max_tick") port map (max_tick);

end default;
