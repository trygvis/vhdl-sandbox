library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity serial_echo is
    port(
        clk: in std_logic;
        pc: in std_logic_vector(0 downto 0);
        tick: out std_logic;
        rx: in std_logic;
        tx: out std_logic;

        dout: out std_logic_vector(7 downto 0);
        clk_out, reset_out, rx_done_tick, tx_done_tick, tx_start: out std_logic
    );
end serial_echo;

architecture default of serial_echo is
    signal tick_s: std_logic;
    signal rx_done_tick_s, tx_done_tick_s, tx_start_s: std_logic;
    signal dout_s: std_logic_vector(7 downto 0);

    signal internal_reset: std_logic;

    -- Baud rate: 19,200
    -- Tick rate = 16 * baud rate = 307,200
    -- Divisor = 48MHz / x = 307,200 => x = 156.25 ~ 156
    constant DBIT: positive := 8;
    constant DIVISOR: positive := 156;
    constant DIVISOR_BITS: positive := 8;
    constant SB_TICK: positive := 16;
begin
    tick <= tick_s;
    rx_done_tick <= rx_done_tick_s;
    tx_done_tick <= tx_done_tick_s;
    tx_start <= tx_start_s;
    dout <= dout_s;

    clk_out <= clk;
    internal_reset <= pc(0);
    reset_out <= pc(0);

    baud_gen_unit: entity work.mod_m_counter(behavioral)
        generic map(
            M => DIVISOR,
            BITS => DIVISOR_BITS)
        port map(
            clk => clk,
            reset => internal_reset,
            q => open,
            max_tick => tick_s);

    uart_rx_unit: entity work.uart_rx(behavioral)
        generic map(
            DBIT => DBIT,
            SB_TICK => SB_TICK)
        port map(
            clk => clk,
            reset => internal_reset,
            rx => rx,
            tick => tick_s,
            rx_done_tick => rx_done_tick_s,
            dout => dout_s);

    uart_tx_unit: entity work.uart_tx(default)
        generic map(
            DBIT => DBIT,
            SB_TICK => SB_TICK)
        port map(
            clk => clk,
            reset => internal_reset,
            tx_start => tx_start_s,
            tx => tx,
            tick => tick_s,
            tx_done_tick => tx_done_tick_s,
            din => "00110111"); -- 55 in decimal is 'T' in ASCII

    foo_unit: entity work.mod_m_counter(behavioral)
        generic map(
            M => 1000,
            BITS => 10)
        port map(
            clk => tick_s,
            reset => internal_reset,
            q => open,
            max_tick => tx_start_s);
end default;
