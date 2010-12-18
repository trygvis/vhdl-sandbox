library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity uart_tx is
    generic(
        DBIT: positive := 8;        -- number of data bits
        SB_TICK: positive := 16     -- ticks for stop bits
    );
    port(
        clk, reset: in std_logic;
        tick: in std_logic;
        din: in std_logic_vector(7 downto 0);
        tx_start: in std_logic;
        tx_done: out std_logic;
        tx: out std_logic
    );
end uart_tx;

architecture default of uart_tx is
    type state_type is (idle, start, data, stop);
    signal state_reg, state_next: state_type;
    signal s_reg, s_next: unsigned(3 downto 0);
    signal n_reg, n_next: unsigned(2 downto 0);
    signal b_reg, b_next: std_logic_vector(7 downto 0);
    signal tx_reg:std_logic := '1';
    signal tx_next: std_logic;
begin
    -- FSMD state & data registers
    process(clk, reset)
    begin
        if reset='1' then
            state_reg <= idle;
            s_reg <= (others => '0');
            n_reg <= (others => '0');
            b_reg <= (others => '0');
            tx_reg <= '1';
            assert false report "uart_tx reset" severity note;
        elsif clk'event and clk='1' then
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
            tx_reg <= tx_next;
        end if;
    end process;

    process(state_reg, b_reg)
    begin
        case state_reg is
            when idle  => tx_next <= '1';
            when start => tx_next <= '0';
            when data  => tx_next <= b_reg(0);
            when stop  => tx_next <= '1';
        end case;
    end process;

    -- next-state logic & data path functional units/routing
    -- n_next is in the list for the assert
    process(state_reg, s_reg, n_reg, b_reg, tick, tx_start, din, n_next)
    begin
        state_next <= state_reg;
        s_next <= s_reg;
        n_next <= n_reg;
        b_next <= b_reg;
        tx_done <= '0';

        case state_reg is
            when idle =>
                if tx_start = '1' then
                    assert false report "state_next=start, data=" & to_string(din) severity note;
                    state_next <= start;
                    s_next <= (others => '0');
                    b_next <= din;
                end if;
            when start =>
                if tick = '1' then
                    state_next <= data;
                    assert false report "state_next=data" severity note;
                    s_next <= (others => '0');
                    n_next <= (others => '0');
                end if;
            when data =>
                if tick = '1' then
                    if s_reg = 15 then
                        s_next <= (others => '0');
                        b_next <= '0' & b_reg(7 downto 1);
                        if n_reg = (DBIT - 1) then
                            state_next <= stop;
                            assert false report "state_next=stop" severity note;
                        else
                            n_next <= n_reg + 1;
                            assert false report "state_next=data (still) n_next=" & to_string(to_integer(n_next)) severity note;
                        end if;
                    else
                        s_next <= s_reg + 1;
                    end if;
                end if;
            when stop =>
                if tick = '1' then
                    if s_reg = (SB_TICK - 1) then
                        state_next <= idle;
                        assert false report "state_next=idle" severity note;
                        tx_done <= '1';
                    else
                        s_next <= s_reg + 1;
                    end if;
                end if;
        end case;
    end process;

    tx <= tx_reg;
end default;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity mod_m_counter is
    generic(
        BITS: positive;         -- number of bits
        M: positive             -- mod-M
    );
    port(
        clk, reset: in std_logic;
        max_tick: out std_logic
--        q: out std_logic_vector(BITS - 1 downto 0)
    );
end mod_m_counter;

architecture behavioral of mod_m_counter is
    signal r_reg: unsigned(BITS - 1 downto 0) := (others => '0');
    signal r_next: unsigned(BITS - 1 downto 0);
begin
    process(clk, reset, r_next)
    begin
        if reset = '1' then
            r_reg <= (others => '0');
        elsif rising_edge(clk) then
            r_reg <= r_next;
        end if;
    end process;

    r_next <= (others => '0') when r_reg=(M - 1) else r_reg + 1;
--    q <= std_logic_vector(r_reg);
    max_tick <= '1' when r_reg=(M - 1) else '0';
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
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
        din: in std_logic_vector(7 downto 0);
        tick: out std_logic;
        tx: out std_logic;
        tx_start: out std_logic;
        tx_done: out std_logic
    );
end;

library unisim;
use unisim.vcomponents.bufg;

architecture default of serial_tx is
    signal tick_s, tick_buffered: std_logic;
    signal tx_start_s, tx_start_buffered: std_logic;
    signal tx_done_s: std_logic;

    attribute buffer_type: string;
    attribute clock_signal: string;

--    attribute clock_signal of tick_s: signal is "yes";
begin
    tick <= tick_buffered;
    tx_done <= tx_done_s;
    tx_start <= tx_start_s;

    assert false
    report "Serial configuration: baud divisor=" & to_string(BAUD_DIVISOR) severity note;

    tick_buffered <= tick_s;
    tx_start_buffered <= tx_start_s;

--    tick_buf: component bufg port map(i => tick_s, o => tick_buffered);
--    tx_start_buf: component bufg port map(i => tx_start_s, o => tx_start_buffered);

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
            clk => tick_buffered,
            reset => reset,
            max_tick => tx_start_s);

    uart_tx_unit: entity work.uart_tx(default)
        generic map(
            DBIT => DBIT,
            SB_TICK => SB_TICK)
        port map(
          clk => clk,
            reset => reset,
            tick => tick_buffered,
            din => din,
            tx => tx,
            tx_start => tx_start_buffered,
            tx_done => tx_done_s);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity delayer is
    generic(
        COUNT: positive;
        BITS: positive
    );
    port(
        clk: in std_logic;
        input: in std_logic;
        output: out std_logic
    );
end;

architecture default of delayer is
    type delayer_state is (active, idle);
    signal state: delayer_state := idle;
    signal state_next: delayer_state := idle;
    signal counter, counter_next: unsigned(BITS - 1 downto 0);
begin
    process(clk, input)
    begin
        if clk'event and clk='1' then
            state <= state_next;
            if input = '1' then
                state_next <= active;
                counter <= (others => '0');
            else
                counter <= counter_next;
                if counter=(COUNT - 1) then
                    state_next <= idle;
                end if;
            end if;
        end if;
    end process;

    counter_next <= counter + 1;
--    state_next <= idle when counter=(COUNT - 1) else active;
    output <= '1' when state = active else '0';
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

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

    signal tick_s: std_logic;
    signal tx_s: std_logic;
    signal tx_start_s: std_logic;
    signal tx_done_s:std_logic;

    signal din: std_logic_vector(7 downto 0);
    signal data: natural range 0 to 255;
    signal data_next: natural range 0 to 255;

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
    clk_out <= ztex_clk;
    reset_out <= pc(0);
    reset <= pc(0);
--    reset <= reset_in;
--    reset <= '0';

    with tx_s select tx <= '1' when '1', '0' when others;

    -- Make sure that all metadata output signals are clk/48 long (48MHz/48=1MHz=1us)
    tick_delayer: entity work.delayer generic map(48, 6) port map(clk, tick_s, tick);
    tx_start_delayer: entity work.delayer generic map(48, 6) port map(clk, tx_start_s, tx_start);
    tx_done_delayer: entity work.delayer generic map(48, 6) port map(clk, tx_done_s, tx_done);

    ztex_clk <= clk;

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
--    data_next <= 65 when data = 90 else data + 1;
--    din <= std_logic_vector(to_unsigned(65, 8)) when data = 90 or reset = '1' else std_logic_vector(to_unsigned(data, 8));
    process(tx_start_s)
    begin
        if rising_edge(tx_start_s) then
--            data <= 84;
--            data <= "01010100"; -- 84, 0x54 b01010100
            data <= data_next;
        end if;
    end process;

    -- FSMD state & data registers
    process(reset)
    begin
        if reset='1' then
            data <= 0;
        end if;
    end process;
end;
