library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package utils is

  function to_string(b: std_logic) return string;
  function to_string(vec: std_logic_vector) return string;
  function to_string(int: integer) return string;
  function to_string(int: integer; base: integer) return string;
  function chr(int: integer) return character;

end package;

package body utils is

    function to_string(b: std_logic) return string is
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

    function to_string(vec: std_logic_vector) return string is
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

   function chr(int: integer) return character is
        variable c: character;
   begin
        case int is
            when  0 => c := '0';
            when  1 => c := '1';
            when  2 => c := '2';
            when  3 => c := '3';
            when  4 => c := '4';
            when  5 => c := '5';
            when  6 => c := '6';
            when  7 => c := '7';
            when  8 => c := '8';
            when  9 => c := '9';
            when 10 => c := 'A';
            when 11 => c := 'B';
            when 12 => c := 'C';
            when 13 => c := 'D';
            when 14 => c := 'E';
            when 15 => c := 'F';
            when 16 => c := 'G';
            when 17 => c := 'H';
            when 18 => c := 'I';
            when 19 => c := 'J';
            when 20 => c := 'K';
            when 21 => c := 'L';
            when 22 => c := 'M';
            when 23 => c := 'N';
            when 24 => c := 'O';
            when 25 => c := 'P';
            when 26 => c := 'Q';
            when 27 => c := 'R';
            when 28 => c := 'S';
            when 29 => c := 'T';
            when 30 => c := 'U';
            when 31 => c := 'V';
            when 32 => c := 'W';
            when 33 => c := 'X';
            when 34 => c := 'Y';
            when 35 => c := 'Z';
            when others => c := '?';
        end case;
        return c;
    end chr;

    function to_string(int: integer; base: integer) return string is
        variable temp:      string(1 to 10);
        variable num:       integer;
        variable abs_int:   integer;
        variable len:       integer := 1;
        variable power:     integer := 1;
    begin

        -- bug fix for negative numbers
        abs_int := abs(int);

        num     := abs_int;

        while num >= base loop                     -- Determine how many
            len := len + 1;                        -- characters required
            num := num / base;                     -- to represent the
        end loop ;                                 -- number.

        for i in len downto 1 loop                 -- Convert the number to
            temp(i) := chr(abs_int/power mod base);-- a string starting
            power := power * base;                 -- with the right hand
        end loop ;                                 -- side.

        -- return result and add sign if required
        if int < 0 then
            return '-'& temp(1 to len);
        else
            return temp(1 to len);
        end if;
    end;

    -- convert integer to string, using base 10
    function to_string(int: integer) return string is
    begin
        return to_string(int, 10);
    end;

end package body;
