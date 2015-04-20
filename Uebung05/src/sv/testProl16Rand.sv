`include "Prol16Model.sv"

class TestClass;
	task assertWithoutFlags(int expectedRegisterValue, int expectedPCValue, Prol16State state, int register, string text);
		assert (expectedRegisterValue == state.regs[register])
		else $error("Expected Register Value: %d, Actual Register Value: %d, Info: %s", expectedRegisterValue, state.regs[register], text);
		
		assert (expectedPCValue == state.programCounter)
		else $error("Expected PC Value: %d, Actual PC Value: %d, Info: %s", expectedPCValue, state.programCounter, text);
	endtask
	
	task assertWithFlags(int expectedRegisterValue, int expectedPCValue, int expectedCarryFlag, int expectedZeroFlag, Prol16State state, int register, string text);
		assert (expectedRegisterValue == state.regs[register])
		else $error("Expected Register Value: %d, Actual Register Value: %d, Info: %s", expectedRegisterValue, state.regs[register], text);
		
		assert (expectedPCValue == state.programCounter)
		else $error("Expected PC Value: %d, Actual PC Value: %d, Info: %s", expectedPCValue, state.programCounter, text);
		
		assert (expectedCarryFlag == state.cFlag)
		else $error("Expected Carry Flag Value: %d, Actual Carry Flag Value: %d, Info: %s", expectedCarryFlag, state.cFlag, text);
		
		assert (expectedZeroFlag == state.zFlag)
		else $error("Expected Zero Flag Value: %d, Actual Zero Flag Value: %d, Info: %s", expectedZeroFlag, state.zFlag, text);
	endtask
	
	task assertWithDuv(Prol16State state, int register, logic [15:0] cpuRegs [31:0], logic[15:0] cpuPc, logic cpuCFlag, logic cpuZFlag, string text);
		assert (state.regs[register] == cpuRegs[register])
		else $error("WithDuv: Expected Register Value: %d, Actual Register Value: %d, Info: %s", state.regs[register], cpuRegs[register], text);
		
		assert (state.programCounter == cpuPc)
		else $error("WithDuv: Expected PC Value: %d, Actual PC Value: %d, Info: %s", state.programCounter, cpuPc, text);
		
		assert (state.cFlag == cpuCFlag)
		else $error("WithDuv: Expected Carry Flag Value: %d, Actual Carry Flag Value: %d, Info: %s", state.cFlag, cpuCFlag, text);
		
		assert (state.zFlag == cpuZFlag)
		else $error("WithDuv: Expected Zero Flag Value: %d, Actual Zero Flag Value: %d, Info: %s", state.zFlag, cpuZFlag, text);
	endtask
endclass

program testProl16Model(ifProl16.master cpu, output logic rst, input logic clk);
	logic [15:0] cpuRegs [31:0];
	logic [15:0] cpuPc;
	logic cpuCFlag;
	logic cpuZFlag;
	logic opcodeDUV;
	logic ra;
	logic rb;
	
	const int numTestCases = 100;
	
	event CommandStart;
	event End;
	
	bit LoadiOccurred = 0;
	
	task trigger();
  		while (!End.triggered) begin
  		  @(negedge cpu.mem_oe_n)
		  begin
		    $display("negEdge oe");
			if (LoadiOccurred == 0)
			begin
				cpu.mem_data_tb[15:10] <= opcode.cmd;
				cpu.mem_data_tb[9:5] <= opcode.ra;
				cpu.mem_data_tb[4:0] <= opcode.rb;	 
	
				if (opcode.cmd == Loadi) 
				begin					
					LoadiOccurred = 1;
				end
			end
			else
			begin
				cpu.mem_data_tb <= opcode.data;
				LoadiOccurred = 0;
			end			
		  end
		  @(posedge cpu.mem_oe_n)
		  begin
		    $display("posEdge oe");
			-> CommandStart;
		  end
		end	
	endtask
	
	covergroup CoverCpu @(posedge clk);  // TODO, clk the right signal?
		option.per_instance = 1;

		cmd: coverpoint opcodeDUV;
		
		ra: coverpoint ra;
		rb: coverpoint rb;
		
		crs_cmd_ra: cross cmd, ra;
		crs_cmd_rb: cross cmd, rb;
		
		cFlag: coverpoint cpuCFlag {
			bins set = {1};
			bins notset = {0};
		}
		
		zFlag: coverpoint cpuZFlag {
			bins set = {1};
			bins notset = {0};
		}
		
		crs_cmd_c: cross cmd, cFlag;
		crs_cmd_z: cross cmd, zFlag;
		
		// TODO: cmd changes flags
		// ...
		
	endgroup
	
	initial begin : stimuli
		Prol16State state = new();
		Prol16Model#(32) model = new(state);
		
		TestClass testClass = new();
	
		CoverCpu coverCpu = new;
		
		Prol16Opcode opcode = new(0, 0, Nop, 0);
	
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(0)", "/top/TheTest/cpuRegs(0)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(1)", "/top/TheTest/cpuRegs(1)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(2)", "/top/TheTest/cpuRegs(2)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(3)", "/top/TheTest/cpuRegs(3)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(4)", "/top/TheTest/cpuRegs(4)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(5)", "/top/TheTest/cpuRegs(5)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(6)", "/top/TheTest/cpuRegs(6)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(7)", "/top/TheTest/cpuRegs(7)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(8)", "/top/TheTest/cpuRegs(8)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(9)", "/top/TheTest/cpuRegs(9)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(10)", "/top/TheTest/cpuRegs(10)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(11)", "/top/TheTest/cpuRegs(11)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(12)", "/top/TheTest/cpuRegs(12)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(13)", "/top/TheTest/cpuRegs(13)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(14)", "/top/TheTest/cpuRegs(14)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(15)", "/top/TheTest/cpuRegs(15)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(16)", "/top/TheTest/cpuRegs(16)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(17)", "/top/TheTest/cpuRegs(17)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(18)", "/top/TheTest/cpuRegs(18)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(19)", "/top/TheTest/cpuRegs(19)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(20)", "/top/TheTest/cpuRegs(20)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(21)", "/top/TheTest/cpuRegs(21)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(22)", "/top/TheTest/cpuRegs(22)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(23)", "/top/TheTest/cpuRegs(23)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(24)", "/top/TheTest/cpuRegs(24)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(25)", "/top/TheTest/cpuRegs(25)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(26)", "/top/TheTest/cpuRegs(26)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(27)", "/top/TheTest/cpuRegs(27)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(28)", "/top/TheTest/cpuRegs(28)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(29)", "/top/TheTest/cpuRegs(29)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(30)", "/top/TheTest/cpuRegs(30)");
		$init_signal_spy("/top/TheCpu/datapath_inst/thereg_file/registers(31)", "/top/TheTest/cpuRegs(31)");
				
		$init_signal_spy("/top/TheCpu/datapath_inst/RegPC", "/top/TheTest/cpuPc");
		$init_signal_spy("/top/TheCpu/control_inst/Carry", "/top/TheTest/cpuCFlag");
		$init_signal_spy("/top/TheCpu/control_inst/Zero", "/top/TheTest/cpuZFlag");
		$init_signal_spy("/top/TheCpu/datapath_inst/RegOpcode", "/top/TheTest/opcodeDUV");		
		$init_signal_spy("/top/TheCpu/datapath_inst/RegAIdx", "/top/TheTest/ra");
		$init_signal_spy("/top/TheCpu/datapath_inst/RegBIdx", "/top/TheTest/rb");
		
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(0)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(1)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(2)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(3)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(4)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(5)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(6)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(7)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(8)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(9)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(10)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(11)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(12)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(13)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(14)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(15)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(16)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(17)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(18)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(19)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(20)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(21)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(22)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(23)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(24)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(25)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(26)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(27)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(28)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(29)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(30)", "16#0000", 0, 1);
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(31)", "16#0000", 0, 1);
	
		//Reset
		model.reset();
		//testClass.assertWithoutFlags(0, 0, model.state, 12, "Reset test");
		
		// generate reset -----------------------------------------------------
		rst = 1;
		#10 rst = 0;
		#20 rst = 1;
		  		
  		fork
  		  trigger();
		join_none

		for (int i = 0; i < numTestCases; i++) {
			opcode.randomize();
			@(CommandStart);		
			testClass.assertWithDuv(model.state, opcode.ra, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Random test " + i);
			model.execute(opcode);			
		}
		
		-> End;
		$stop;
	end : stimuli
endprogram
