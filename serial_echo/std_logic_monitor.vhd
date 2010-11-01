library ieee;
use ieee.std_logic_1164.all;
use work.utils.all;

entity std_logic_monitor is
    generic ( tag: string );
    port    ( sig : in std_logic);
end;

architecture signal_event of std_logic_monitor is
begin
    signal_monitor: process
    begin
        wait until sig'event;
        if rising_edge(sig) then
            assert false report "monitor: " & tag & " rising edge, value=" & to_string(sig) severity note;
        elsif falling_edge(sig) then
            assert false report "monitor: " & tag & " falling edge, value=" & to_string(sig) severity note;
        else
            assert false report "monitor: " & tag & " change, value=" & to_string(sig) severity note;
        end if;
    end process;
end;

architecture r_edge of std_logic_monitor is
begin
    signal_monitor: process
    begin
        wait until rising_edge(sig);
        assert false report "monitor: " & tag & " rising edge" severity note;
    end process;
end;

architecture f_edge of std_logic_monitor is
begin
    signal_monitor: process
    begin
        wait until falling_edge(sig);
        assert false report "monitor: " & tag & " falling edge" severity note;
    end process;
end;
