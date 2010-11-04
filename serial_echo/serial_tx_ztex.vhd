library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_tx_ztex is
    port(
        clk: in std_logic;
--        reset_in: in std_logic;
        pc: in std_logic_vector(0 downto 0);
        clk_out: out std_logic;
        reset_out: out std_logic;
        tick: out std_logic;
        tx: out std_logic;
        tx_start: out std_logic;
        tx_done: out std_logic
    );
end;

architecture default of serial_tx_ztex is
    signal ztex_clk: std_logic;
    signal reset: std_logic;

    signal tick_s: bit;
    signal tx_s: bit;
    signal tx_start_s: bit;
    signal tx_done_s: bit;

    signal din: bit_vector(7 downto 0);
    signal data: natural;
    signal data_next: natural;

    -- Baud rate | Tick rate
    --     1,200 |   19,200
    --    19,200 |  307,200
    -- Tick rate = 16 * baud rate = 307,200
    -- Divisor = 48MHz / x = 307,200 => x = 156.25 ~ 156
    -- Divisor = 10MHz / 1200 baud = 520.833 ~ 520
    constant DIVISOR: positive := 156;
--    constant DIVISOR: positive := 520;
    constant DIVISOR_BITS: positive := 9;
begin
    clk_out <= ztex_clk;
    reset_out <= pc(0);
    reset <= pc(0);
--    reset <= reset_in;
--    reset <= '0';

    with tick_s select tick <= '1' when '1', '0' when others;
    with tx_s select tx <= '1' when '1', '0' when others;
    with tx_start_s select tx_start <= '1' when '1', '0' when others;
    with tx_done_s select tx_done <= '1' when '1', '0' when others;

    ztex_clk <= clk;

--    clk_gen_unit: entity work.mod_m_counter(behavioral)
--        generic map(
--            M => 48,
--            BITS => 10)
--        port map(
--            reset => reset,
--            clk => clk,
--            max_tick => ztex_clk);

    serial_tx: entity work.serial_tx(default)
        generic map(
            BAUD_DIVISOR => DIVISOR,
            BAUD_DIVISOR_BITS => DIVISOR_BITS
        )
        port map(
            reset => reset,
            clk => ztex_clk,
            din => din,
            tick => tick_s,
            tx => tx_s,
            tx_start => tx_start_s,
            tx_done => tx_done_s
        );

    data_next <= data + 1;
    din <= work.utils.to_bit_vector(data_next, 8);
    process(tx_start_s)
    begin
        if tx_start_s'event and tx_start_s='1' then
--        if rising_edge(tx_start_s) then
            data <= 84;
--            din <= "01010100"; -- 84, 0x54 b01010100
--            din <= din_next;
        end if;
    end process;
end;
