library ieee;
use ieee.std_logic_1164.all;
use work.utils.all;

entity bit_monitor is
    generic (tag: string);
    port    (sig: in bit);
end;

architecture signal_event of bit_monitor is
begin
    signal_monitor: process
    begin
        wait until sig'event;
        if sig'event and sig='1' then
            assert false report "monitor: " & tag & " rising edge, value=" & to_string(sig) severity note;
        elsif sig'event and sig='0' then
            assert false report "monitor: " & tag & " falling edge, value=" & to_string(sig) severity note;
        else
            assert false report "monitor: " & tag & " change, value=" & to_string(sig) severity note;
        end if;
    end process;
end;

architecture r_edge of bit_monitor is
begin
    signal_monitor: process
    begin
        wait until sig'event and sig='1';
        assert false report "monitor: " & tag & " rising edge" severity note;
    end process;
end;

architecture f_edge of bit_monitor is
begin
    signal_monitor: process
    begin
        wait until sig'event and sig='0';
        assert false report "monitor: " & tag & " falling edge" severity note;
    end process;
end;
