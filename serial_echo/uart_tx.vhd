library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.utils.all;

entity uart_tx is
    generic(
        DBIT: positive := 8;        -- number of data bits
        SB_TICK: positive := 16     -- ticks for stop bits
    );
    port(
        clk, reset: in std_logic;
        tick: in bit;
        din: in bit_vector(7 downto 0);
        tx_start: in bit;
        tx_done: out bit;
        tx: out bit
    );
end uart_tx;

architecture default of uart_tx is
    type state_type is (idle, start, data, stop);
    signal state_reg, state_next: state_type;
    signal s_reg, s_next: unsigned(3 downto 0);
    signal n_reg, n_next: unsigned(2 downto 0);
    signal b_reg, b_next: bit_vector(7 downto 0);
    signal tx_reg: bit := '1';
    signal tx_next: bit;
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
