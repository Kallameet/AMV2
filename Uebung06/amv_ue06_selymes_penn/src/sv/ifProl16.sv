interface ifProl16 #(parameter int gDataWidth = 16);
	
	logic [gDataWidth-1:0] mem_addr;		// unused
	logic [gDataWidth-1:0] mem_data_cpu;	// data from cpu
	logic [gDataWidth-1:0] mem_data_tb;		// data from tb
	logic mem_ce_n;
	logic mem_oe_n;
	logic mem_we_n;							// unused
	logic illegal_inst;
	logic cpu_halt;
	
	modport master (
		output mem_data_tb,
		input mem_data_cpu, mem_ce_n, mem_oe_n, illegal_inst, cpu_halt
	);
		
endinterface
