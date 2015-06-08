library IEEE;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_1164.ALL;

entity SimpleBus is
end entity;

architecture Bhv of SimpleBus is
  signal clk, request, grant, data_valid, done, aborting : std_ulogic := '0';
begin  
  clk <= not clk after 10 ns;
  request <= '0' after 0 ns,
			       '1' after 20 ns,
			       '0' after 40 ns,
			       '1' after 280 ns,
			       '0' after 300 ns;
  grant <= '1' after 60 ns,
           '0' after 80 ns;
  data_valid <= '1' after 80 ns,
                '0' after 240 ns;
  done <= '1' after 240 ns,
          '0' after 260 ns;
  aborting <= '1' after 300 ns,
              '0' after 320 ns;        
  
  
end Bhv;