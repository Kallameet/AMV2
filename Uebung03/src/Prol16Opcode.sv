`include "Prol16Command.sv"

class Prol16Opcode;
	int ra;
	int rb;
	Prol16Command cmd;
	pkgProl16::data_v data;
	
	function new(int ra, int rb, Prol16Command cmd, pkgProl16::data_v data);
		this.ra = ra;
		this.rb = rb;
		this.cmd = cmd;
		this.data = data;
	endfunction
endclass