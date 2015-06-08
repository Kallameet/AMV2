architecture Bhv of SimpleBus is
  signal clk, request, grant, data_valid, done, abort_ : std_ulogic := '0';
begin  
  clk <= not clk after 10 ns;
  request <= '0' after 0 ns,
			 '1' after 20 ns,
			 '0' after 40 ns;
  grant <= '1' after 40 ns;
end Bhv;