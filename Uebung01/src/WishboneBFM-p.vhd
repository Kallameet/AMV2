-------------------------------------------------------------------------------
-- Title      : Wishbone BFM
-- Project    : AMV2
-- Author	  : Bernhard Selymes
------------------------------------------------------------------------------- 
-- Description:
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package WishboneBFM is

  constant cDataWidth : natural := 32;
  constant cAddrWidth : natural := 8;
  constant cByte      : natural := 8;

  type aBusIn is record
    clk_i : std_ulogic;
	rst_i : std_ulogic;
    dat_i : std_ulogic_vector(cDataWidth-1 downto 0);
    ack_i : std_ulogic;
  end record;

  type aBusOut is record
    we_o : std_ulogic;
    adr_o : std_ulogic_vector(cAddrWidth-1 downto 0);
    dat_o : std_ulogic_vector(cDataWidth-1 downto 0);
    sel_o : std_ulogic_vector((cDataWidth/cByte)-1 downto 0);
	stb_o : std_ulogic;
	cyc_o : std_ulogic;
  end record;

  type aAddrBlock is array (natural range <>) of std_ulogic_vector(cAddrWidth-1 downto 0);
  type aDataBlock is array (natural range <>) of std_ulogic_vector(cDataWidth-1 downto 0);
  
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
  
  procedure SingleRead (
    constant addr : in std_ulogic_vector(cAddrWidth-1 downto 0);
    variable data : out std_ulogic_vector(cDataWidth-1 downto 0); -- variable ?
    signal busin  : in aBusIn;
    signal busout : out aBusOut);
  
  procedure SingleWrite (
    constant addr : in std_ulogic_vector(cAddrWidth-1 downto 0);
    constant data : in std_ulogic_vector(cDataWidth-1 downto 0);
    signal busin  : in aBusIn;
    signal busout : out aBusOut);

  procedure BlockRead (
    constant addr : in aAddrBlock;
    variable data : out aDataBlock;
	constant len  : in natural;
    signal busin  : in aBusIn;
    signal busout : out aBusOut);

  procedure BlockWrite (
    constant addr : in aAddrBlock;
    constant data : in aDataBlock;
	constant len  : in natural;
    signal busin  : in aBusIn;
    signal busout : out aBusOut);
		
end WishboneBFM;

package body WishboneBFM is

  -- Single Read
  procedure SingleRead (
    constant addr : in std_ulogic_vector(cAddrWidth-1 downto 0);
    variable data : out std_ulogic_vector(cDataWidth-1 downto 0);
    signal busin  : in aBusIn;
    signal busout : out aBusOut) is
  begin
    -- clock edge 0
    wait on busin.clk_i until busin.clk_i = '1';
	busout.adr_o <= addr;
	busout.we_o <= '0';
	busout.sel_o <= (others => '1');
	busout.cyc_o <= '1';
	busout.stb_o <= '1';
	
	-- setup, edge 1
	wait on busin.clk_i until busin.ack_i = '1';
	
	-- clock edge 1
	data := busin.dat_i;
	busout.stb_o <= '0';
	busout.cyc_o <= '0';
  end SingleRead;
  
  -- Single Write
  procedure SingleWrite (
    constant addr : in std_ulogic_vector(cAddrWidth-1 downto 0);
    constant data : in std_ulogic_vector(cDataWidth-1 downto 0);
    signal busin  : in aBusIn;
    signal busout : out aBusOut) is
  begin
    -- clock edge 0
    wait on busin.clk_i until busin.clk_i = '1';
	busout.adr_o <= addr;
	busout.dat_o <= data;
	busout.we_o <= '1';
	busout.sel_o <= (others => '1');
	busout.cyc_o <= '1';
	busout.stb_o <= '1';
	
	-- setup, edge 1
	wait on busin.clk_i until busin.ack_i = '1';
	
	-- clock edge 1
	busout.stb_o <= '0';
	busout.cyc_o <= '0';
  end SingleWrite;
  
  -- Block Read
  procedure BlockRead (
    constant addr : in aAddrBlock;
    variable data : out aDataBlock;
	constant len  : in natural;
    signal busin  : in aBusIn;
    signal busout : out aBusOut) is
  begin
    
	Reading: for i in 0 to len-1 loop
	  -- clock edge 0
      wait on busin.clk_i until busin.clk_i = '1';
	  busout.adr_o <= addr(i);
	  busout.we_o <= '0';
	  busout.sel_o <= (others => '1');
	  busout.cyc_o <= '1';
	  busout.stb_o <= '1';
	
	  -- setup, edge 1
	  wait on busin.clk_i until busin.ack_i = '1';
	
	  -- clock edge 1
	  data(i) := busin.dat_i;
	end loop;
	
	busout.stb_o <= '0';
	busout.cyc_o <= '0';
  
  end BlockRead;
  
  -- Block Write
  procedure BlockWrite (
    constant addr : in aAddrBlock;
    constant data : in aDataBlock;
	constant len  : in natural;
    signal busin  : in aBusIn;
    signal busout : out aBusOut) is
  begin
    
	Writing: for i in 0 to len-1 loop
	  -- clock edge 0
      wait on busin.clk_i until busin.clk_i = '1';
	  busout.adr_o <= addr(i);
	  busout.dat_o <= data(i);
	  busout.we_o <= '1';
	  busout.sel_o <= (others => '1');
	  busout.cyc_o <= '1';
	  busout.stb_o <= '1';
	
	  -- setup, edge 1
	  wait on busin.clk_i until busin.ack_i = '1';
	end loop;
	
	busout.stb_o <= '0';
	busout.cyc_o <= '0';
	
  end BlockWrite;


end WishboneBFM;