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
	
	event CommandStart;
	event End;
	
	Prol16Opcode opcode = new(0, 0, Nop, 0);
	
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
	
	initial begin : stimuli
		Prol16State state = new();
		Prol16Model#(32) model = new(state);
		
		TestClass testClass = new();
						
		Prol16Opcode opcode_Nop = new(0, 0, Nop, 0);
		Prol16Opcode opcode_Loadi = new(0, 3, Loadi, 50);
		Prol16Opcode opcode_Loadi2 = new(1, 3, Loadi, 20);
		Prol16Opcode opcode_Jump = new(0, 0, Jump, 0);
		Prol16Opcode opcode_Jumpc = new(0, 0, Jumpc, 0);
		Prol16Opcode opcode_Jumpz = new(1, 0, Jumpz, 0);
		Prol16Opcode opcode_Move = new(2, 0, Move, 0);
		Prol16Opcode opcode_Move2 = new(2, 1, Move, 0);
		Prol16Opcode opcode_And = new(2, 0, And, 0);
		Prol16Opcode opcode_And2 = new(2, 3, And, 0);
		Prol16Opcode opcode_Or = new(2, 4, Or, 0);
		Prol16Opcode opcode_Or2 = new(2, 3, Or, 0);
		Prol16Opcode opcode_Xor = new(2, 3, Xor, 0);
		Prol16Opcode opcode_Xor2 = new(3, 4, Xor, 0);
		Prol16Opcode opcode_Not = new(3, 7, Not, 0);
		Prol16Opcode opcode_Not2 = new(5, 8, Not, 0);
		Prol16Opcode opcode_Add = new(6, 7, Add, 0);
		Prol16Opcode opcode_Addc = new(8, 9, Addc, 0);
		Prol16Opcode opcode_Sub = new(10, 11, Sub, 0);
		Prol16Opcode opcode_Subc = new(12, 13, Subc, 0);
		Prol16Opcode opcode_Comp = new(14, 15, Comp, 0);
		Prol16Opcode opcode_Inc = new(16, 17, Inc, 0);
		Prol16Opcode opcode_Dec = new(18, 19, Dec, 0);
		Prol16Opcode opcode_Shl = new(20, 21, Shl, 0);
		Prol16Opcode opcode_Shr = new(22, 23, Shr, 0);
		Prol16Opcode opcode_Shlc = new(24, 25, Shlc, 0);
		Prol16Opcode opcode_Shrc = new(26, 27, Shrc, 0);
		Prol16Opcode opcode_Invalid = new(28, 29, Invalid, 0);
		Prol16Opcode opcode_InvalidRegister = new(31, 32, Move, 0);
	
	
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
		$init_signal_spy("/top/TheCpu/carry_out", "/top/TheTest/cpuCFlag");
		$init_signal_spy("/top/TheCpu/zero", "/top/TheTest/cpuZFlag");		
		
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

		
		//Nop
		@(CommandStart);		
		testClass.assertWithDuv(model.state, 12, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Reset test");	
		
		model.execute(opcode);				
		opcode = opcode_Loadi;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 0, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Nop test");
		
		@(CommandStart);
		
		//Loadi
		model.execute(opcode);		
		opcode = opcode_Loadi2;		
		@(CommandStart);
		testClass.assertWithDuv(model.state, 0, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Loadi test 1");		
		testClass.assertWithoutFlags(50, 3, model.state, 0, "Loadi test 1");	
		
		@(CommandStart);
		
		model.execute(opcode);		
		opcode = opcode_Jump;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 1, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Loadi test 2");
		testClass.assertWithoutFlags(20, 5, model.state, 1, "Loadi test 2");
		
		//Jump
		model.execute(opcode);
		opcode = opcode_Jumpc;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 0, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Jump test");
		testClass.assertWithoutFlags(50, 50, model.state, 0, "Jump test");
		
		//Jumpc
		model.execute(opcode_Jumpc);
		opcode = opcode_Jumpc;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 0, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Jumpc test");
		testClass.assertWithoutFlags(50, 51, model.state, 0, "Jumpc test Carry = 0");
				
		model.state.cFlag = 1;
		$signal_force("/top/TheCpu/carry_out", "1", 0, 1);
		model.execute(opcode_Jumpc);
		opcode = opcode_Jumpz;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 0, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Jumpc test Carry = 1");
		testClass.assertWithoutFlags(50, 50, model.state, 0, "Jumpc test Carry = 1");
		
		//Jumpz
		model.execute(opcode_Jumpz);
		opcode = opcode_Jumpz;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 1, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Jumpz test Zero = 0");
		testClass.assertWithoutFlags(20, 51, model.state, 1, "Jumpz test Zero = 0");
				
		model.state.zFlag = 1;
		$signal_force("/top/TheCpu/zero", "1", 0, 1);
		model.execute(opcode_Jumpz);
		opcode = opcode_Move;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 1, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Jumpz test Zero = 1");
		testClass.assertWithoutFlags(20, 20, model.state, 1, "Jumpz test Zero = 1");
		
		//Move
		model.execute(opcode_Move);
		opcode = opcode_Move2;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 2, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Move test 1");
		testClass.assertWithoutFlags(50, 21, model.state, 2, "Move test 1");
		
		model.execute(opcode_Move2);
		opcode = opcode_And;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 2, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Move test 2");
		testClass.assertWithoutFlags(20, 22, model.state, 2, "Move test 2");
		
		//And
		model.state.regs[3] = 64;
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(3)", "16#0040", 0, 1);
		model.execute(opcode_And);
		opcode = opcode_And2;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 2, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "And test 1");
		testClass.assertWithFlags(16, 23, 0, 0, model.state, 2, "And test 1");
		
		model.execute(opcode_And2);
		opcode = opcode_Or;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 2, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "And test 2");
		testClass.assertWithFlags(0, 24, 0, 1, model.state, 2, "And test 2");
		
		//Or
		model.execute(opcode_Or);
		opcode = opcode_Or2;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 2, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Or test 1");
		testClass.assertWithFlags(0, 25, 0, 1, model.state, 2, "Or test 1");
		
		model.execute(opcode_Or2);
		opcode = opcode_Xor;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 2, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Or test 2");
		testClass.assertWithFlags(64, 26, 0, 0, model.state, 2, "Or test 2");
		
		//Xor
		model.execute(opcode_Xor);
		opcode = opcode_Xor2;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 2, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Xor test 1");
		testClass.assertWithFlags(0, 27, 0, 1, model.state, 2, "Xor test 1");
		
		model.state.regs[4] = 96;
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(3)", "16#0060", 0, 1);
		model.execute(opcode_Xor2);
		opcode = opcode_Not;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 3, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Xor test 2");
		testClass.assertWithFlags(32, 28, 0, 0, model.state, 3, "Xor test 2");
		
		//Not
		model.execute(opcode_Not);
		opcode = opcode_Not2;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 3, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Not test 1");
		testClass.assertWithFlags(65503, 29, 0, 0, model.state, 3, "Not test 1");
		
		model.state.regs[5] = 65535;
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(3)", "16#FFFF", 0, 1);
		model.execute(opcode_Not2);
		opcode = opcode_Add;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 5, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Not test 2");
		testClass.assertWithFlags(0, 30, 0, 1, model.state, 5, "Not test 2");
		
		//Add
		model.state.regs[6] = 10;
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(3)", "16#000A", 0, 1);
		model.state.regs[7] = 30;
		$signal_force("/top/TheCpu/datapath_inst/thereg_file/registers(3)", "16#001E", 0, 1);
		model.state.cFlag = 1;
		$signal_force("/top/TheCpu/carry_out", "1", 0, 1);
		model.execute(opcode_Add);
		opcode = opcode_Add;
		@(CommandStart);
		testClass.assertWithDuv(model.state, 6, cpuRegs, cpuPc, cpuCFlag, cpuZFlag, "Add test 1");
		testClass.assertWithFlags(40, 31, 0, 0, model.state, 6, "Add test 1");
		
		model.state.regs[6] = 65535;
		model.state.regs[7] = 1;
		model.execute(opcode_Add);
		testClass.assertWithFlags(0, 32, 1, 1, model.state, 6, "Add test 2");
		
		model.state.regs[6] = 65535;
		model.state.regs[7] = 2;
		model.execute(opcode_Add);
		testClass.assertWithFlags(1, 33, 1, 0, model.state, 6, "Add test 3");
		
		//Addc
		model.state.regs[8] = 10;
		model.state.regs[9] = 30;
		model.state.cFlag = 0;
		model.execute(opcode_Addc);
		testClass.assertWithFlags(40, 34, 0, 0, model.state, 8, "Addc test 1");
		model.state.regs[8] = 10;
		model.state.regs[9] = 30;
		model.state.cFlag = 1;
		model.execute(opcode_Addc);
		testClass.assertWithFlags(41, 35, 0, 0, model.state, 8, "Addc test 2");
		model.state.regs[8] = 65535;
		model.state.regs[9] = 1;
		model.execute(opcode_Addc);
		testClass.assertWithFlags(0, 36, 1, 1, model.state, 8, "Addc test 3");
		model.state.regs[8] = 65535;
		model.state.regs[9] = 1;
		model.execute(opcode_Addc);
		testClass.assertWithFlags(1, 37, 1, 0, model.state, 8, "Addc test 4");
		
		//Sub
		model.state.regs[10] = 30;
		model.state.regs[11] = 10;
		model.state.cFlag = 1;
		model.execute(opcode_Sub);
		testClass.assertWithFlags(20, 38, 0, 0, model.state, 10, "Sub test 1");
		model.state.regs[10] = 10;
		model.state.regs[11] = 10;
		model.execute(opcode_Sub);
		testClass.assertWithFlags(0, 39, 0, 1, model.state, 10, "Sub test 2");
		model.state.regs[10] = 1;
		model.state.regs[11] = 2;
		model.execute(opcode_Sub);
		testClass.assertWithFlags(65535, 40, 1, 0, model.state, 10, "Sub test 3");
		
		//Subc
		model.state.regs[12] = 30;
		model.state.regs[13] = 10;
		model.state.cFlag = 0;
		model.execute(opcode_Subc);
		testClass.assertWithFlags(20, 41, 0, 0, model.state, 12, "Subc test 1");
		model.state.regs[12] = 30;
		model.state.regs[13] = 10;
		model.state.cFlag = 1;
		model.execute(opcode_Subc);
		testClass.assertWithFlags(19, 42, 0, 0, model.state, 12, "Subc test 2");
		model.state.regs[12] = 10;
		model.state.regs[13] = 10;
		model.state.cFlag = 0;
		model.execute(opcode_Subc);
		testClass.assertWithFlags(0, 43, 0, 1, model.state, 12, "Subc test 3");
		model.state.regs[12] = 1;
		model.state.regs[13] = 2;
		model.execute(opcode_Subc);
		testClass.assertWithFlags(65535, 44, 1, 0, model.state, 12, "Subc test 4");
		
		//Comp
		model.state.regs[14] = 30;
		model.state.regs[15] = 10;
		model.execute(opcode_Comp);
		testClass.assertWithFlags(30, 45, 0, 0, model.state, 14, "Comp test 1");
		model.state.regs[14] = 30;
		model.state.regs[15] = 10;
		model.state.cFlag = 1;
		model.execute(opcode_Comp);
		testClass.assertWithFlags(30, 46, 0, 0, model.state, 14, "Comp test 2");
		model.state.regs[14] = 10;
		model.state.regs[15] = 10;
		model.execute(opcode_Comp);
		testClass.assertWithFlags(10, 47, 0, 1, model.state, 14, "Comp test 3");
		model.state.regs[14] = 1;
		model.state.regs[15] = 2;
		model.execute(opcode_Comp);
		testClass.assertWithFlags(1, 48, 1, 0, model.state, 14, "Comp test 4");
		
		//Inc
		model.state.regs[16] = 30;		
		model.execute(opcode_Inc);
		testClass.assertWithFlags(31, 49, 0, 0, model.state, 16, "Inc test 1");
		model.state.regs[16] = 30;		
		model.state.cFlag = 1;
		model.execute(opcode_Inc);
		testClass.assertWithFlags(31, 50, 0, 0, model.state, 16, "Inc test 2");
		model.state.regs[16] = 0;
		model.execute(opcode_Inc);
		testClass.assertWithFlags(1, 51, 0, 0, model.state, 16, "Inc test 3");
		model.state.regs[16] = 65535;
		model.execute(opcode_Inc);
		testClass.assertWithFlags(0, 52, 1, 1, model.state, 16, "Inc test 4");
		
		//Dec
		model.state.regs[18] = 30;		
		model.execute(opcode_Dec);
		testClass.assertWithFlags(29, 53, 0, 0, model.state, 18, "Dec test 1");
		model.state.regs[18] = 30;		
		model.state.cFlag = 1;
		model.execute(opcode_Dec);
		testClass.assertWithFlags(29, 54, 0, 0, model.state, 18, "Dec test 2");
		model.state.regs[18] = 0;
		model.execute(opcode_Dec);
		testClass.assertWithFlags(65535, 55, 1, 0, model.state, 18, "Dec test 3");
		model.state.regs[18] = 1;
		model.execute(opcode_Dec);
		testClass.assertWithFlags(0, 56, 0, 1, model.state, 18, "Dec test 4");
		
		//Shl
		model.state.regs[20] = 0;		
		model.execute(opcode_Shl);
		testClass.assertWithFlags(0, 57, 0, 1, model.state, 20, "Shl test 1");
		model.state.regs[20] = 1;		
		model.state.cFlag = 1;
		model.execute(opcode_Shl);
		testClass.assertWithFlags(2, 58, 0, 0, model.state, 20, "Shl test 2");
		model.state.regs[20] = 65535;
		model.execute(opcode_Shl);
		testClass.assertWithFlags(65534, 59, 1, 0, model.state, 20, "Shl test 3");
		model.state.regs[20] = 32768;
		model.execute(opcode_Shl);
		testClass.assertWithFlags(0, 60, 1, 1, model.state, 20, "Shl test 4");
		
		//Shr
		model.state.regs[22] = 0;		
		model.execute(opcode_Shr);
		testClass.assertWithFlags(0, 61, 0, 1, model.state, 22, "Shr test 1");
		model.state.regs[22] = 2;		
		model.state.cFlag = 1;
		model.execute(opcode_Shr);
		testClass.assertWithFlags(1, 62, 0, 0, model.state, 22, "Shr test 2");
		model.state.regs[22] = 65535;
		model.execute(opcode_Shr);
		testClass.assertWithFlags(32767, 63, 1, 0, model.state, 22, "Shr test 3");
		model.state.regs[22] = 1;
		model.execute(opcode_Shr);
		testClass.assertWithFlags(0, 64, 1, 1, model.state, 22, "Shr test 4");
		
		//Shlc
		model.state.regs[24] = 0;
		model.state.cFlag = 0;	
		model.execute(opcode_Shlc);
		testClass.assertWithFlags(0, 65, 0, 1, model.state, 24, "Shlc test 1");
		model.state.regs[24] = 1;		
		model.state.cFlag = 1;
		model.execute(opcode_Shlc);
		testClass.assertWithFlags(3, 66, 0, 0, model.state, 24, "Shlc test 2");
		model.state.regs[24] = 65535;
		model.execute(opcode_Shlc);
		testClass.assertWithFlags(65534, 67, 1, 0, model.state, 24, "Shlc test 3");
		model.state.regs[24] = 32768;
		model.state.cFlag = 0;
		model.execute(opcode_Shlc);
		testClass.assertWithFlags(0, 68, 1, 1, model.state, 24, "Shlc test 4");
		
		//Shrc
		model.state.regs[26] = 0;
		model.state.cFlag = 0;
		model.execute(opcode_Shrc);
		testClass.assertWithFlags(0, 69, 0, 1, model.state, 26, "Shrc test 1");
		model.state.regs[26] = 2;		
		model.state.cFlag = 1;
		model.execute(opcode_Shrc);
		testClass.assertWithFlags(32769, 70, 0, 0, model.state, 26, "Shrc test 2");
		model.state.regs[26] = 65535;
		model.execute(opcode_Shrc);
		testClass.assertWithFlags(32767, 71, 1, 0, model.state, 26, "Shrc test 3");
		model.state.regs[26] = 1;
		model.state.cFlag = 0;
		model.execute(opcode_Shrc);
		testClass.assertWithFlags(0, 72, 1, 1, model.state, 26, "Shrc test 4");
				
		//Invalid
		model.state.regs[28] = 123;
		model.state.cFlag = 0;
		model.state.zFlag = 0;
		model.execute(opcode_Invalid);
		testClass.assertWithFlags(123, 73, 0, 0, model.state, 28, "Invalid test");
		
		//InvalidRegister
		model.state.regs[31] = 1234;
		model.execute(opcode_InvalidRegister);
		testClass.assertWithFlags(1234, 74, 0, 0, model.state, 31, "Invalid register test");
		
		-> End;
		$stop;
	end : stimuli
endprogram
