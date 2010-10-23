library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package utils is

  function to_string(b : in std_logic) return string;
  function to_string(vec : in std_logic_vector) return string;

end package;

package body utils is

    function to_string(b : in std_logic) return string is
    begin
        case b is
            when '0' => return "0";
            when '1' => return "1";
            when 'U' => return "U";
            when others =>
                assert false report "Failure" severity failure;
                return "F";
        end case;
    end to_string;

    function to_string(vec : in std_logic_vector) return string is
        variable result: string(1 to vec'length);
    begin
        for i in vec'range loop
            case vec(i) is
                when '0' => result(i+1) := '0';
                when '1' => result(i+1) := '1';
                when others =>
                    assert false report "Failure" severity failure;
                    return "F";
            end case;
        end loop;
        return result;
    end to_string;

end package body;
