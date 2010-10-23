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
        clk: in std_logic;
        reset: in std_logic;
        din: in std_logic_vector(7 downto 0);
        tick: out std_logic;
        tx: out std_logic;
        tx_start, tx_done: out std_logic
    );
end;

architecture default of serial_tx is
    signal tick_s: std_logic;
    signal tx_done_s, tx_start_s: std_logic;
begin
    tick <= tick_s;
    tx_done <= tx_done_s;
    tx_start <= tx_start_s;

    assert false
    report "Serial configuration: baud divisor=" & to_string(BAUD_DIVISOR);

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
            clk => tick_s,
            reset => reset,
            max_tick => tx_start_s);

--    uart_tx_unit: entity work.uart_tx(default)
--        generic map(
--            DBIT => DBIT,
--            SB_TICK => SB_TICK)
--        port map(
--            clk => clk,
--            reset => reset,
--            tick => tick_s,
--            din => din,
--            tx => tx,
--            tx_start => tx_start_s,
--            tx_done => tx_done_s);
end;
