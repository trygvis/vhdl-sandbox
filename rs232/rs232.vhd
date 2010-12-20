----------------------------------------------------------------------------------
-- Creation Date: 21:12:48 05/06/2010 
-- Module Name: RS232/UART Interface - Behavioral
-- Used TAB of 4 Spaces
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity uart is
generic (
	CLK_FREQ	: integer := 50;		-- Main frequency (MHz)
	SER_FREQ	: integer := 9600		-- Baud rate (bps)
);
port (
	-- Control
	clk			: in	std_logic;		-- Main clock
	rst			: in	std_logic;		-- Main reset
	-- External Interface
	rx			: in	std_logic;		-- RS232 received serial data
	tx			: out	std_logic;		-- RS232 transmitted serial data
	-- RS232/UART Configuration
	par_en		: in	std_logic;		-- Parity bit enable
	-- uPC Interface
	tx_req		: in	std_logic;						-- Request SEND of data
	tx_end		: out	std_logic;						-- Data SENDED
	tx_data		: in	std_logic_vector(7 downto 0);	-- Data to transmit
	rx_ready	: out	std_logic;						-- Received data ready to uPC read
	rx_data		: out	std_logic_vector(7 downto 0)	-- Received data 
);
end uart;

architecture default of uart is
 
	-- Constants
	constant UART_IDLE	:	std_logic := '1';
	constant UART_START	:	std_logic := '0';
	constant PARITY_EN	:	std_logic := '1';
	constant RST_LVL	:	std_logic := '1';
 
	-- Types
	type state is (idle,data,parity,stop1,stop2);			-- Stop1 and Stop2 are inter frame gap
 
	-- Signals
	signal rx_fsm		:	state;							-- Control of reception
	signal tx_fsm		:	state;							-- Control of transmission
	signal clock_en		:	std_logic;						-- Internal clock enable
 
	-- RX Data Temp
	signal rx_par_bit	:	std_logic;
	signal rx_data_tmp	:	std_logic_vector(7 downto 0);
	signal rx_data_cnt	:	std_logic_vector(2 downto 0);
 
	-- TX Data Temp
	signal tx_par_bit	:	std_logic;
	signal tx_data_tmp	:	std_logic_vector(7 downto 0);
	signal tx_data_cnt	:	std_logic_vector(2 downto 0);
 
begin
 
	clock_manager:process(clk)
		variable counter	:	integer range 0 to conv_integer((CLK_FREQ*1_000_000)/SER_FREQ-1);
	begin
		if clk'event and clk = '1' then
			-- Normal Operation
			if counter = (CLK_FREQ*1_000_000)/SER_FREQ-1 then
				clock_en	<=	'1';
				counter		:=	0;
			else
				clock_en	<=	'0';
				counter		:=	counter + 1;
			end if;
			-- Reset condition
			if rst = RST_LVL then
				counter		:=	0;
			end if;
		end if;
	end process;
 
	tx_proc:process(clk)
		variable data_cnt	: std_logic_vector(2 downto 0);
	begin
		if clk'event and clk = '1' then
			if clock_en = '1' then
				-- Default values
				tx_end					<=	'0';
				tx						<=	UART_IDLE;
				-- FSM description
				case tx_fsm is
					-- Wait to transfer data
					when idle =>
						-- Send Init Bit
						if tx_req = '1' then
							tx			<=	UART_START;
							tx_data_tmp	<=	tx_data;
							tx_fsm		<=	data;
							tx_data_cnt	<=	(others=>'1');
							tx_par_bit	<=	'0';
						end if;
					-- Data receive
					when data =>
						tx				<=	tx_data_tmp(0);
						tx_par_bit		<=	tx_par_bit xor tx_data_tmp(0);
						if tx_data_cnt = 0 then
							if par_en = PARITY_EN then
								tx_fsm	<=	parity;
							else
								tx_fsm	<=	stop1;
							end if;
							tx_data_cnt	<=	(others=>'1');
						else
							tx_data_tmp	<=	'0' & tx_data_tmp(7 downto 1);
							tx_data_cnt	<=	tx_data_cnt - 1;
						end if;
					when parity =>
						tx				<=	tx_par_bit;
						tx_fsm			<=	stop1;
					-- End of communication
					when stop1 =>
						-- Send Stop Bit
						tx				<=	UART_IDLE;
						tx_fsm			<=	stop2;
					when stop2 =>
						-- Send Stop Bit
						tx_end			<=	'1';
						tx				<=	UART_IDLE;
						tx_fsm			<=	idle;
				end case;
				-- Reset condition
				if rst = RST_LVL then
					tx_fsm				<=	idle;
					tx_par_bit			<=	'0';
					tx_data_tmp			<=	(others=>'0');
					tx_data_cnt			<=	(others=>'0');
				end if;
			end if;
		end if;
	end process;
 
	rx_proc:process(clk)
	begin
		if clk'event and clk = '1' then
			if clock_en = '1' then
				-- Default values
				rx_ready		<=	'0';
				-- FSM description
				case rx_fsm is
					-- Wait to transfer data
					when idle =>
						if rx = UART_START then
							rx_fsm		<=	data;
						end if;
						rx_par_bit		<=	'0';
						rx_data_cnt		<=	(others=>'0');
					-- Data receive
					when data =>
						-- Check data to generate parity
						if par_en = PARITY_EN then
							rx_par_bit		<=	rx_par_bit xor rx;
						end if;
 
						if rx_data_cnt = 7 then
							-- Data path
							rx_data(7)		<=	rx;
							for i in 0 to 6 loop
								rx_data(i)	<=	rx_data_tmp(6-i);
							end loop;
 
							-- With parity verification
							if par_en = PARITY_EN then
								rx_fsm		<=	parity;
							-- Without parity verification
							else
								rx_ready	<=	'1';
								rx_fsm		<=	idle;
							end if;
						else
							rx_data_tmp		<=	rx_data_tmp(6 downto 0) & rx;
							rx_data_cnt		<=	rx_data_cnt + 1;
						end if;
					when parity =>
						-- Check received parity
						rx_fsm				<=	idle;
						if rx_par_bit = rx then
							rx_ready		<=	'1';
						end if;
					when others => null;
				end case;
				-- Reset condition
				if rst = RST_LVL then
					rx_fsm			<=	idle;
					rx_ready		<=	'0';
					rx_data			<=	(others=>'0');
					rx_data_tmp		<=	(others=>'0');
					rx_data_cnt		<=	(others=>'0');
				end if;
			end if;
		end if;
	end process;
 
end;
