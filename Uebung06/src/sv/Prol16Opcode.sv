`include "Prol16Command.sv"

class Prol16Opcode;
	rand int ra;
	rand int rb;
	randc Prol16Command cmd;
	rand pkgProl16::data_v data;
	
	constraint ra_size {ra >= 0 && ra <= 31;};
	constraint rb_size {rb >= 0 && rb <= 31;};
	
	// constraint ra_0 {
		// ra dist { [0:0]:/50, [1:31]:/50 };
	// }
	
	// constraint rb_0 {
		// rb dist { [0:0]:/50, [1:31]:/50 };
	// }
	
	// constraint nop_0 {
		// (cmd == Nop) -> (ra == 0) && (rb == 0);
	// }
	
	function new(int ra, int rb, Prol16Command cmd, pkgProl16::data_v data);
		this.ra = ra;
		this.rb = rb;
		this.cmd = cmd;
		this.data = data;
	endfunction
endclass