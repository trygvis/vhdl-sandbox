library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.utils.all;

entity test_serial_tx_ztex is
end test_serial_tx_ztex;

architecture default of test_serial_tx_ztex is

    signal clk: std_logic := '0';
    signal pc: std_logic_vector(0 downto 0);
    signal clk_out: std_logic;
    signal reset_out: std_logic;
    signal tick: bit;
    signal tx: bit;
    signal tx_start, tx_done: bit;

    constant clk_period: time := 20.83 ns; -- 48MHz
begin
    uut: entity work.serial_tx_ztex(default)
        port map (
            clk => clk,
            pc => pc,
            clk_out => clk_out,
            reset_out => reset_out,
            tick => tick,
            tx => tx,
            tx_start => tx_start,
            tx_done => tx_done
        );

    clk <= '1', not clk after 0.5 * clk_period;
    pc(0) <= '1', '0' after (1.75 * clk_period);

    reset_monitor: entity work.std_logic_monitor(signal_event) generic map("reset") port map (pc(0));
--    clk_out_monitor: entity work.std_logic_monitor(signal_event) generic map("clk_out") port map (clk_out);
    tick_monitor: entity work.bit_monitor(r_edge) generic map("tick") port map (tick);
    tx_monitor: entity work.bit_monitor(signal_event) generic map("tx") port map (tx);
    tx_start_monitor: entity work.bit_monitor(r_edge) generic map("tx_start") port map (tx_start);
    tx_done_monitor: entity work.bit_monitor(r_edge) generic map("tx_done") port map (tx_done);
end;
