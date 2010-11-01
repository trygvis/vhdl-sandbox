library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.utils.all;

entity test_serial_tx is
end test_serial_tx;

architecture default of test_serial_tx is

    signal clk: std_logic := '0';
    signal reset: std_logic;
    signal tick: bit;
    signal tx: bit;
    signal tx_start, tx_done: bit;

    constant clk_period: time := 100 ns;
begin
    uut: entity work.serial_tx(default)
        generic map (
            BAUD_DIVISOR => 100,
            BAUD_DIVISOR_BITS => 10
        )
        port map (
            clk => clk,
            reset => reset,
            din => "10101010",
            tx => tx,
            tick => tick,
            tx_start => tx_start,
            tx_done => tx_done
        );

    clk <= '1', not clk after 0.5 * clk_period;
    reset <= '1', '0' after (1.75 * clk_period);

    reset_monitor: entity work.std_logic_monitor(signal_event) generic map("reset") port map (reset);
--    clk_monitor: entity work.std_logic_monitor(r_edge) generic map("clk") port map (clk);
--    tick_monitor: entity work.bit_monitor(r_edge) generic map("tick") port map (tick);
--    tx_monitor: entity work.bit_monitor(signal_event) generic map("tx") port map (tx);
    tx_start_monitor: entity work.bit_monitor(r_edge) generic map("tx_start") port map (tx_start);
    tx_done_monitor: entity work.bit_monitor(r_edge) generic map("tx_done") port map (tx_done);
end;
