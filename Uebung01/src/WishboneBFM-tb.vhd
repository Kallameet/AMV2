-------------------------------------------------------------------------------
-- Title      : Wishbone BFM tb
-- Project    : AMV2
-- Author	  : Reinhard Penn
------------------------------------------------------------------------------- 
-- Description:
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.WishboneBFM.all;

entity tbWishboneBFM is  
end entity;


architecture bhv of tbWishboneBFM is

COMPONENT RAM PORT (
clk_i	: in   STD_ULOGIC;
rst_i	: in   STD_ULOGIC;
adr_i	: in   STD_ULOGIC_VECTOR(cAddrWidth-1 downto 0);
dat_i	: in   STD_ULOGIC_VECTOR(cDataWidth-1 downto 0);
sel_i	: in   STD_ULOGIC_VECTOR((cDataWidth/8)-1 downto 0);
cyc_i	: in   STD_ULOGIC;
stb_i	: in   STD_ULOGIC;
we_i	: in   STD_ULOGIC;
dat_o	: out  STD_ULOGIC_VECTOR(cDataWidth-1 downto 0);
ack_o	: out  STD_ULOGIC
 );
END COMPONENT;

constant busInInit	: aBusIn	:= (clk_i 	=> '0',
									rst_i	=> '0',
									dat_i 	=> (others => '0'),
									ack_i 	=> '0');
								
constant busOutInit	: aBusOut	:= (we_o 	=> '0',
									adr_o	=> (others => '0'),
									dat_o	=> (others => '0'),
									sel_o	=> (others => '0'),
									stb_o	=> '0',
									cyc_o	=> '0');

signal busIn	: aBusIn	:= busInInit;
signal busOut	: aBusOut	:= busOutInit;

constant cEndAddress : natural := (2**cAddrWidth)-1;
constant testInput1 : std_ulogic_vector(cDataWidth-1 downto 0) := x"AAAAAAAA";
constant testInput2 : std_ulogic_vector(cDataWidth-1 downto 0) := x"55555555";

begin

DUV : RAM PORT MAP(
clk_i => busIn.clk_i,
rst_i => busIn.rst_i,
adr_i => busOut.adr_o,
dat_i => busOut.dat_o,
sel_i => busOut.sel_o,
cyc_i => busOut.cyc_o,
stb_i => busOut.stb_o,
we_i  => busOut.we_o,
dat_o => busIn.dat_i,
ack_o => busIn.ack_i
);

CLOCK:
busIn.clk_i <=  '1' after 5 ns when busIn.clk_i = '0' else
        '0' after 5 ns when busIn.clk_i = '1';

Stimuli : process is
variable rd : std_ulogic_vector(cDataWidth-1 downto 0) := (others => '0');
variable addressBlock	: aAddrBlock(0 to cEndAddress) := (others => (others => '0'));
variable dataBlock		: aDataBlock(0 to cEndAddress) := (others => (others => '0'));
variable readDataBlock	: aDataBlock(0 to cEndAddress) := (others => (others => '0'));
begin
  
  --test Single Read Write with data 10101...
	for i in 0 to cEndAddress loop
		SingleWrite(std_ulogic_vector(to_unsigned(i, cAddrWidth)), -- address
		testInput1, -- data
			busIn, busOut);
		SingleRead(std_ulogic_vector(to_unsigned(i, cAddrWidth)), -- address
			rd, busIn, busOut);
	
		assert rd = testInput1
			report "SindleTest: TestInput1 is wrong" 
			severity error;
	end loop;
	
	--test Single Read Write with data 010101...
	for i in 0 to cEndAddress loop
		SingleWrite(std_ulogic_vector(to_unsigned(i, cAddrWidth)), -- address
		testInput2, -- data
			busIn, busOut);
		SingleRead(std_ulogic_vector(to_unsigned(i, cAddrWidth)), -- address
			rd, busIn, busOut);
	
		assert rd = testInput2
			report "SingleTest: TestInput2 is wrong" 
			severity error;
	end loop;
	
	--test Block Read Write with data 1010101...
	for i in 0 to cEndAddress loop
		addressBlock(i) := std_ulogic_vector(to_unsigned(i, cAddrWidth));
		dataBlock(i)	:= testInput1;
	end loop;
	
	BlockWrite(addressBlock, -- address
		dataBlock, -- data
		cEndAddress+1, busIn, busOut);
	
	BlockRead(addressBlock, -- address
		readDataBlock, -- data
		cEndAddress+1, busIn, busOut);
		
	for i in 0 to cEndAddress loop
		assert readDataBlock(i) = testInput1
			report "BlockTest: TestInput1 is wrong" 
			severity error;		
	end loop;
	
	
		--test Block Read Write with data 01010101...
	for i in 0 to cEndAddress loop
		addressBlock(i) := std_ulogic_vector(to_unsigned(i, cAddrWidth));
		dataBlock(i)	:= testInput2;
	end loop;
	
	BlockWrite(addressBlock, -- address
		dataBlock, -- data
		cEndAddress+1, busIn, busOut);
	
	BlockRead(addressBlock, -- address
		readDataBlock, -- data
		cEndAddress+1, busIn, busOut);
		
	for i in 0 to cEndAddress loop
		assert readDataBlock(i) = testInput2
			report "BlockTest: TestInput2 is wrong" 
			severity error;		
	end loop;	
  
assert false
    report "This is not a failure: Simulation finished !!!"
    severity failure;
    
end process;

end architecture;