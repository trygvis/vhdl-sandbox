library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.utils.all;

entity serial_tx is
    generic(
        BAUD_DIVISOR: positive;
        BAUD_DIVISOR_BITS: positive;
        DBIT: positive := 8;
        SB_TICK: positive := 16
    );
    port(
        clk, reset: in std_logic;
        din: in bit_vector(7 downto 0);
        tick: out bit;
        tx: out bit;
        tx_start: out bit;
        tx_done: out bit
    );
end;

architecture default of serial_tx is
    signal tick_s: bit;
    signal tx_start_s: bit;
    signal tx_done_s: bit;

    attribute buffer_type: string;
    attribute clock_signal: string;

    attribute buffer_type of tick_s: signal is "BUFG";
--    attribute clock_signal of tick_s: signal is "yes";

    attribute buffer_type of tx_start_s: signal is "bufg";
--    attribute clock_signal of tx_start_s: signal is "yes";

--    attribute clock_signal of clk: signal is "yes";
--    attribute buffer_type of clk: signal is "bufg";
begin
    tick <= tick_s;
    tx_done <= tx_done_s;
    tx_start <= tx_start_s;

    assert false
    report "Serial configuration: baud divisor=" & to_string(BAUD_DIVISOR) severity info;

    baud_gen_unit: entity work.mod_m_counter(behavioral)
        generic map(
            M => BAUD_DIVISOR,
            BITS => BAUD_DIVISOR_BITS)
        port map(
            clk => clk,
            reset => reset,
            max_tick => tick_s);

    tx_start_gen: entity work.mod_m_counter(behavioral)
        generic map(
            M => 16 * 16, -- start a new tx after 16 bits (* 16 ticks)
            BITS => 10)
        port map(
            clk => to_std_logic(tick_s),
            reset => reset,
            max_tick => tx_start_s);

    uart_tx_unit: entity work.uart_tx(default)
        generic map(
            DBIT => DBIT,
            SB_TICK => SB_TICK)
        port map(
          clk => clk,
            reset => reset,
            tick => tick_s,
            din => din,
            tx => tx,
            tx_start => tx_start_s,
            tx_done => tx_done_s);
end;
