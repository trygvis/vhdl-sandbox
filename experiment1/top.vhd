library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( a : in  STD_LOGIC_vector(3 downto 0);
           b : in  STD_LOGIC_vector(3 downto 0);
           c : in  STD_LOGIC_vector(3 downto 0);
           d : in  STD_LOGIC_vector(3 downto 0);
			  sel : in std_logic_vector(1 downto 0);
           x : out STD_LOGIC_vector(3 downto 0));
end top;

architecture Behavioral of top is
begin

  x <= a when sel = "00" else
       b when sel = "01" else
		 c when sel = "10" else
		 d;

end Behavioral;
