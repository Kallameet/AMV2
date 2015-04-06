`include "Prol16Model.sv"

program testProl16Model();
	initial begin : stimuli
		Prol16State#(32) state = new();
		Prol16Model model = new(state);
		Prol16Opcode opcode = new(0, 0, Nop, 0);
		model.execute(opcode);	
	end : stimuli
endprogram