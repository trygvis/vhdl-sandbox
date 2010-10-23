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

    signal din: unsigned(7 downto 0);
    signal din_next: unsigned(7 downto 0);

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
            din => std_logic_vector(din),
            tick => tick,
            tx => tx,
            tx_start => tx_start,
            tx_done => tx_done
        );

    din_next <= din + 1;
    process(ztex_clk)
    begin
        if rising_edge(ztex_clk) then
            din <= din_next;
        end if;
    end process;
end;
