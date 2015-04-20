class Prol16State #(parameter int gRegs = 32);
	pkgProl16::data_v regs[gRegs];
	pkgProl16::data_v programCounter;
	bit cFlag;
	bit zFlag;
	
	function new();
		for (int i = 0; i < gRegs; i++) begin
			regs[i] = '0;
		end
		programCounter = 0;
		cFlag = 0;
		zFlag = 0;
	endfunction
	
	task reset();
		for (int i = 0; i < gRegs; i++) begin
			regs[i] = '0;
		end
		programCounter = 0;
		cFlag = 0;
		zFlag = 0;
	endtask
endclass
