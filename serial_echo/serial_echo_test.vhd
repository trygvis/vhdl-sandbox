    library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.utils.all;

entity serial_echo_test is
end serial_echo_test;

architecture behavior of serial_echo_test is

   --Inputs
   signal clk : std_logic := '0';
   signal rx : std_logic := '0';
   signal pc: std_logic_vector(0 downto 0);

 	--Outputs
   signal tick : std_logic;
   signal tx : std_logic;
   signal dout : std_logic_vector(7 downto 0);
   signal clk_out : std_logic;
   signal reset_out : std_logic;
   signal rx_done_tick : std_logic;
   signal tx_done_tick : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20.83 ns; -- 48MHz
   constant clk_out_period : time := 20.83 ns;
begin
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.serial_echo(default) port map (
          clk => clk,
          pc => pc,
          tick => tick,
          rx => rx,
          tx => tx,
          dout => dout,
          clk_out => clk_out,
          reset_out => reset_out,
          rx_done_tick => rx_done_tick,
          tx_done_tick => tx_done_tick
        );

    clk <= not clk after 0.5 * clk_period;
    pc(0) <= '1' after (0.75 * clk_prd), '0' after (1.75 * clk_prd);

    -- Clock process definitions
--    clk_process :process
--    begin
--        clk <= '0';
--        wait for clk_period/2;
--        clk <= '1';
--        wait for clk_period/2;
--    end process;

--    reset_process :process
--    begin
--        pc(0) <= '1';
--        wait for clk_period * 2;
--        pc(0) <= '0';
--        wait;
--    end process;

end;
