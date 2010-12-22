    Library UNISIM;
use UNISIM.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

entity lcd_ztex is
    port(
        clk: in std_logic;
        reset_inv: in std_logic;

        lcd_rs: out std_logic;
        lcd_rw: out std_logic;
        -- Enable
        lcd_e: out std_logic;
        -- Data
        lcd_d: out std_logic_vector(7 downto 0));
end lcd_ztex;

architecture default of lcd_ztex is
	signal reset: std_logic;
	signal clk_6MHz, clk_6MHz_buffered, clk_1MHz, clk_200kHz: std_logic;

    signal lcd_e_next: std_logic;
    signal lcd_d_next: std_logic_vector(7 downto 0);

    type state_type is (idle, function_set, function_set_done, display_on, done);
    signal state_reg, state_next: state_type;
begin
	reset <= not reset_inv;

    divider_1: bufio2
        generic map(divide => 8, divide_bypass => false)
        port map(
            i => clk,
            divclk => clk_6MHz,
            ioclk => open,
            serdesstrobe => open);

    divider_1_buffer: bufg port map(i => clk_6MHz, o => clk_6MHz_buffered);

    divider_2: bufio2
        generic map(divide => 6, divide_bypass => false)
        port map(
            i => clk_6MHz_buffered, 
            divclk => clk_1MHz,
            ioclk => open,
            serdesstrobe => open);

    divider_3: bufio2
        generic map(divide => 5, divide_bypass => false)
        port map(
            i => clk_1MHz, 
            divclk => clk_200kHz,
            ioclk => open,
            serdesstrobe => open);

    main: process(clk_200kHz, reset)
    begin
        if reset = '1' then
            state_reg <= idle;
            lcd_rw <= '0';
        elsif clk_200kHz'event and clk_200kHz = '1' then
            state_reg <= state_next;
            lcd_rw <= '0';
            lcd_e <= lcd_e_next;
            lcd_d <= lcd_d_next;

            case state_reg is
                when idle =>
                    state_next <= function_set;
                when function_set =>
                    lcd_e_next <= '1';
                    -- bit 7: 0, 0, 0, dl=1, n=1, f=0, -, -
                    -- f=0 => 5x8 dots, f=1 => 5x10 dots
                    lcd_d_next <= "00111000";
                    state_next <= function_set_done;
                when function_set_done =>
                    lcd_e_next <= '0';
                    state_next <= display_on;
                when display_on =>
                    lcd_e_next <= '1';
                    lcd_d_next <= "00001110";
                    state_next <= done;
                when done =>
                    null;
            end case;
        end if;
    end process;

end default;
