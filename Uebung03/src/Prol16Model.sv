`include "Prol16State.sv"
`include "Prol16Opcode.sv"

class Prol16Model;
	Prol16State state;
	
	function new(Prol16State _state);
		state = _state;
	endfunction
	
	task reset();
		state.reset();
	endtask
	
	task execute(Prol16Opcode opcode);
		case (opcode.cmd)
			Nop: $display("Opcode: %s", opcode.cmd);
			Loadi: $display("Opcode: %s", opcode.cmd);
			Jump: $display("Opcode: %s", opcode.cmd);
			Jumpc: $display("Opcode: %s", opcode.cmd);
			Jumpz: $display("Opcode: %s", opcode.cmd);
			Move: $display("Opcode: %s", opcode.cmd);
			And: $display("Opcode: %s", opcode.cmd);
			Or: $display("Opcode: %s", opcode.cmd);
			Xor: $display("Opcode: %s", opcode.cmd);
			Not: $display("Opcode: %s", opcode.cmd);
			Add: $display("Opcode: %s", opcode.cmd);
			Addc: $display("Opcode: %s", opcode.cmd);
			Sub: $display("Opcode: %s", opcode.cmd);
			Subc: $display("Opcode: %s", opcode.cmd);
			Comp: $display("Opcode: %s", opcode.cmd);
			Inc: $display("Opcode: %s", opcode.cmd);
			Dec: $display("Opcode: %s", opcode.cmd);
			Shl: $display("Opcode: %s", opcode.cmd);
			Shr: $display("Opcode: %s", opcode.cmd);
			Shlc: $display("Opcode: %s", opcode.cmd);
			Shrc: $display("Opcode: %s", opcode.cmd);
			default : $display("Wrong opcode: doing nop");
		endcase
	endtask
endclass