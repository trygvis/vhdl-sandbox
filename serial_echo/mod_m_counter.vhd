library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mod_m_counter is
    generic(
        BITS: positive;         -- number of bits
        M: positive             -- mod-M
    );
    port(
        clk, reset: in std_logic;
        max_tick: out bit
--        q: out std_logic_vector(BITS - 1 downto 0)
    );
end mod_m_counter;

architecture behavioral of mod_m_counter is
    signal r_reg: unsigned(BITS - 1 downto 0) := (others => '0');
    signal r_next: unsigned(BITS - 1 downto 0);
begin
    process(clk, reset)
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
