library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.utils.all;

entity serial_echo is
    generic(
        BAUD_DIVISOR: positive;
        BAUD_DIVISOR_BITS: positive;
        DBIT: positive := 8;
        SB_TICK: positive := 16
    );
    port(
        clk: in std_logic;
        reset: in std_logic;
        rx: in std_logic;
        tx: out std_logic;

        dout: out std_logic_vector(7 downto 0);
        tick: out std_logic;
        rx_done: out std_logic;
        tx_done, tx_start: out std_logic
    );
end serial_echo;

architecture default of serial_echo is
    signal tick_s: std_logic;
    signal rx_done_s, tx_done_s, tx_start_s: std_logic;
    signal dout_s: std_logic_vector(7 downto 0);
begin
    tick <= tick_s;
    rx_done <= rx_done_s;
    tx_done <= tx_done_s;
    tx_start <= tx_start_s;
    dout <= dout_s;

    assert false
    report "Serial echo configuration: baud divisor=" & to_string(BAUD_DIVISOR);

    baud_gen_unit: entity work.mod_m_counter(behavioral)
        generic map(
            M => BAUD_DIVISOR,
            BITS => BAUD_DIVISOR_BITS)
        port map(
            clk => clk,
            reset => reset,
--            q => open,
            max_tick => tick_s);

    tx_start_gen: entity work.mod_m_counter(behavioral)
        generic map(
            M => 16 * 16, -- 16 ticks per bit
            BITS => 10)
        port map(
            clk => tick_s,
            reset => reset,
--            q => open,
            max_tick => tx_start_s);

    uart_tx_unit: entity work.uart_tx(default)
        generic map(
            DBIT => DBIT,
            SB_TICK => SB_TICK)
        port map(
            clk => clk,
            reset => reset,
            tick => tick_s,
            tx => tx,
            tx_start => tx_start_s,
            tx_done => tx_done_s,
            din => "00110111"); -- 55 in decimal is 'T' in ASCII

    uart_rx_unit: entity work.uart_rx(behavioral)
        generic map(
            DBIT => DBIT,
            SB_TICK => SB_TICK)
        port map(
            clk => clk,
            reset => reset,
            rx => rx,
            tick => tick_s,
            rx_done => rx_done_s,
            dout => dout_s);
end;
