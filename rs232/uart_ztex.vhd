library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_ztex is
    port(
        clk: in std_logic;
        reset_inv: in std_logic;
        rx_out: out std_logic;
        reset_out: out std_logic;
        rx: in std_logic;
        rx_done: out std_logic;
        tx: out std_logic;
        tx_start: out std_logic;
        tx_done: out std_logic
    );
end;

architecture default of uart_ztex is
    signal ztex_clk: std_logic;
    signal reset: std_logic;

    signal rx_s: std_logic;
    signal rx_done_s:std_logic;
    signal rx_data: std_logic_vector(7 downto 0);

    signal tx_s: std_logic;
    signal tx_start_s: std_logic;
    signal tx_done_s:std_logic;
    signal tx_data: std_logic_vector(7 downto 0);

    -- Baud rate | Tick rate (16 * baud rate)
    --     1,200 |   19,200
    --    19,200 |  307,200
    --
    -- Divisor = 48MHz / x = 307,200 => x = 156.25 ~ 156
    -- Divisor = 10MHz / 1200 baud = 520.833 ~ 520
    constant DIVISOR: positive := 156;
--    constant DIVISOR: positive := 520;
    constant DIVISOR_BITS: positive := 9;
begin
    reset_out <= not reset_inv;
    reset <= not reset_inv;

    rx_out <= rx;
    rx_s <= rx;
    rx_done <= rx_done_s;

    tx <= tx_s;
    tx_start <= tx_start_s;
    tx_done <= tx_done_s;

    ztex_clk <= clk;

    uart: entity work.uart(default)
        generic map(
            CLK_FREQ => 48,
            SER_FREQ => 19200
        )
        port map(
            clk => ztex_clk,
            rst => reset,
            rx => rx_s,
            tx => tx_s,
            par_en => '0',
            tx_req => tx_start_s,
            tx_end => tx_done_s,
            tx_data => tx_data,
            rx_ready => rx_done_s,
            rx_data => rx_data
        );

    echoer: process(clk, reset, rx_done_s, rx_data)
    begin
        tx_data <= rx_data;

        if reset = '1' then
            tx_data <= "01011010";
        elsif clk'event and clk = '1' then
            if rx_done_s = '1' then
                tx_start_s <= '1';
            else
                tx_start_s <= '0';
            end if;
        end if;
    end process;
end;
