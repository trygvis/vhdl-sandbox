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
        tick: out bit;
        tx: out bit;
        tx_start: out bit;
        tx_done: out bit
    );
end;

architecture default of serial_tx_ztex is
    signal ztex_clk: std_logic;
    signal reset: std_logic;

    signal tx_start_s: bit;

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

    tx_start <= tx_start_s;

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
            tick => tick,
            tx => tx,
            tx_start => tx_start_s,
            tx_done => tx_done
        );

    data_next <= data + 1;
    din <= work.utils.to_bit_vector(data_next, 8);
    process(tx_start_s)
    begin
        if clk'event and clk='1' then
--        if rising_edge(tx_start_s) then
            data <= 84;
--            din <= "01010100"; -- 84, 0x54 b01010100
--            din <= din_next;
        end if;
    end process;
end;
