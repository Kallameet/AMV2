`include "Prol16Model.sv"

program testProl16Model();
	initial begin : stimuli
		Prol16State#(32) state = new();
		Prol16Model model = new(state);
		Prol16Opcode opcode = new(0, 0, Nop, 0);
		Prol16Opcode opcode1 = new(1, 2, Add, 0);
		model.execute(opcode);
		model.execute(opcode1);
		$stop;
	end : stimuli
endprogram
