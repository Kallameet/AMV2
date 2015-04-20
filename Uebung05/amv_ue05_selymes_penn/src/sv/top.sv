`include "testProl16Rand.sv"

module top;
	logic clk = 0, rst;
	always #10 clk = ~clk;
	
	ifProl16 ifCpu();
	cpu TheCpu(clk, rst, ifCpu.mem_addr, ifCpu.mem_data_cpu, ifCpu.mem_data_tb, ifCpu.mem_ce_n, ifCpu.mem_oe_n,
			   ifCpu.mem_we_n, ifCpu.illegal_inst, ifCpu.cpu_halt);
	testProl16Rand TheTest(ifCpu.master, rst, clk);
endmodule
