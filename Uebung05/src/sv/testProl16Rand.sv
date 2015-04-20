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
	
	task assertWithDuv(Prol16State state, int register, logic [15:0] cpuRegs [31:0], logic[15:0] cpuPc, logic cpuCFlag, logic cpuZFlag, Prol16Command cmd);
		assert (state.regs[register] == cpuRegs[register])
		else $error("WithDuv: Expected Register Value: %d, Actual Register Value: %d, Info: %s", state.regs[register], cpuRegs[register], cmd.name());
		
		assert (state.programCounter == cpuPc)
		else $error("WithDuv: Expected PC Value: %d, Actual PC Value: %d, Info: %s", state.programCounter, cpuPc, cmd.name());
		
		assert (state.cFlag == cpuCFlag)
		else $error("WithDuv: Expected Carry Flag Value: %d, Actual Carry Flag Value: %d, Info: %s", state.cFlag, cpuCFlag, cmd.name());
		
		assert (state.zFlag == cpuZFlag)
		else $error("WithDuv: Expected Zero Flag Value: %d, Actual Zero Flag Value: %d, Info: %s", state.zFlag, cpuZFlag, cmd.name());
	endtask
endclass

program testProl16Rand(ifProl16.master cpu, output logic rst, input logic clk);
	logic [15:0] cpuRegs [31:0];
	logic [15:0] cpuPc;
	logic cpuCFlag;
	logic cpuZFlag;
	logic [5:0] opcodeDUV;
	logic [4:0] ra;
	logic [4:0] rb;
	
	logic [5:0] prevOpcodeDUV;
	
	const int numTestCases = 100;
	
	event CommandStart;
	event End;
	
	bit LoadiOccurred = 0;
	
	Prol16Opcode opcode = new(0, 0, Nop, 0);
	
	task trigger();
  		while (!End.triggered) begin
  		  @(negedge cpu.mem_oe_n)
		  begin
		    //$display("negEdge oe");
			if (LoadiOccurred == 0)
			begin
				cpu.mem_data_tb[15:10] <= opcode.cmd;
				cpu.mem_data_tb[9:5] <= opcode.ra;
				cpu.mem_data_tb[4:0] <= opcode.rb;	 
	      
	      prevOpcodeDUV <= opcodeDUV;
				
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
		    //$display("posEdge oe");
			-> CommandStart;
		  end
		end	
	endtask
	
	//always_ff @(negedge clk) begin
  //  previous_opcode <= opcode;
  //end
	
	covergroup CoverCpu @(negedge cpu.mem_oe_n);  // TODO, the right signal?
		option.per_instance = 1;

		cmd: coverpoint opcodeDUV iff (rst) {
      bins NOP   = {0};
      bins SLEEP = {1};
      bins LOADI = {2};
      bins LOAD  = {3};
      bins STORE = {4};
      bins JUMP  = {8};
      bins JUMPC = {10};
      bins JUMPZ = {11};
      bins MOVE  = {12};
      bins AND   = {16};
      bins OR    = {17};
      bins XOR   = {18};
      bins NOT   = {19};
      bins ADD   = {20};
      bins ADDC  = {21};
      bins SUB   = {22};
      bins SUBC  = {23};
      bins COMP  = {24};
      bins INC   = {26};
      bins DEC   = {27};
      bins SHL   = {28};
      bins SHR   = {29};
      bins SHLC  = {30};
      bins SHRC  = {31};
      bins Invalid = {63};
      illegal_bins other = default;
    }
		
		prevCmd: coverpoint prevOpcodeDUV iff (rst) {
      bins NOP   = {0};
      bins SLEEP = {1};
      bins LOADI = {2};
      bins LOAD  = {3};
      bins STORE = {4};
      bins JUMP  = {8};
      bins JUMPC = {10};
      bins JUMPZ = {11};
      bins MOVE  = {12};
      bins AND   = {16};
      bins OR    = {17};
      bins XOR   = {18};
      bins NOT   = {19};
      bins ADD   = {20};
      bins ADDC  = {21};
      bins SUB   = {22};
      bins SUBC  = {23};
      bins COMP  = {24};
      bins INC   = {26};
      bins DEC   = {27};
      bins SHL   = {28};
      bins SHR   = {29};
      bins SHLC  = {30};
      bins SHRC  = {31};
      bins Invalid = {63};
      //illegal_bins other = default;
    }
		
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
		
		trans_c: coverpoint cpuCFlag {
      bins from_0_to_1 = (0 => 1);
      bins from_1_to_0 = (1 => 0);
      bins from_0_to_0 = (0 => 0);
      bins from_1_to_1 = (1 => 1);
    }
		
		trans_z: coverpoint cpuZFlag {
      bins from_0_to_1 = (0 => 1);
      bins from_1_to_0 = (1 => 0);
      bins from_0_to_0 = (0 => 0);
      bins from_1_to_1 = (1 => 1);
    }
		
		prevCmdChangeFlags: coverpoint prevOpcodeDUV {
      bins doesnt_change_flags = { 0, 1, 2, 3, 4, 8, 10, 11, 12};
      bins c_flag_0_and_z_flag_x = { 16, 17, 18, 19 };
      bins c_flag_x_and_z_flag_x = { 20, 21, 22, 23, 24, 26, 27, 28, 29, 30, 31 };
    }
		
		crs_cmd_c_change: cross prevCmdChangeFlags, trans_c {
      illegal_bins ill = binsof(prevCmdChangeFlags.doesnt_change_flags) && (binsof(trans_c.from_0_to_1) || binsof(trans_c.from_1_to_0));
      
    }
			
		crs_cmd_z_change: cross prevCmdChangeFlags, trans_z {
      illegal_bins ill = binsof(prevCmdChangeFlags.doesnt_change_flags) && (binsof(trans_z.from_0_to_1) || binsof(trans_z.from_1_to_0));
    }
    
    crs_cmd_c_is_0: cross prevCmdChangeFlags, trans_c {
      illegal_bins ill = binsof(prevCmdChangeFlags.c_flag_0_and_z_flag_x) && (binsof(trans_c.from_0_to_1) || binsof(trans_c.from_1_to_1));
    }
		
	endgroup
	
	initial begin : stimuli
		Prol16State state = new();
		Prol16Model#(32) model = new(state);
		
		TestClass testClass = new();
	
		CoverCpu coverCpu = new;
	
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
	
		
		// generate reset -----------------------------------------------------
		rst = 1;
		#10 rst = 0;
		#20 rst = 1;
		
		//Reset
		model.reset();
		//testClass.assertWithoutFlags(0, 0, model.state, 12, "Reset test");
		  		
  		fork
  		  trigger();
		join_none

    //Nop
		@(CommandStart);		
		testClass.assertWithDuv(model.state, 12, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, opcode.cmd);

 			
		for (int i = 0; i < numTestCases; i++) begin
		  model.execute(opcode);
		  opcode.randomize();
		  $display("Command %b", opcode.cmd);
		  $display("CommandDUV %b", opcodeDUV);
			@(CommandStart);
			testClass.assertWithDuv(model.state, opcode.ra, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, opcode.cmd);		
		end
		
		-> End;
		$stop;
	end : stimuli
endprogram
