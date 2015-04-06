`include "Prol16Model.sv"

class TestClass;
	task assertWithoutFlags(int expectedRegisterValue, int expectedPCValue, Prol16State state, int register, string text);
		assert (expectedRegisterValue == state.regs[register])
		else $error("Expected Register Value: %d, Actual Register Value: %d, Info: %s", expectedRegisterValue, state.regs[register], text);
		
		assert (expectedPCValue == state.pc)
		else $error("Expected PC Value: %d, Actual PC Value: %d, Info: %s", expectedPCValue, state.pc, text);
	endtask
	
	task assertWithFlags(int expectedRegisterValue, int expectedPCValue, int expectedCarryFlag, int expectedZeroFlag, Prol16State state, int register, string text);
		assert (expectedRegisterValue == state.regs[register])
		else $error("Expected Register Value: %d, Actual Register Value: %d, Info: %s", expectedRegisterValue, state.regs[register], text);
		
		assert (expectedPCValue == state.pc)
		else $error("Expected PC Value: %d, Actual PC Value: %d, Info: %s", expectedPCValue, state.pc, text);
		
		assert (expectedCarryFlag == state.cFlag)
		else $error("Expected Carry Flag Value: %d, Actual Carry Flag Value: %d, Info: %s", expectedCarryFlag, state.cFlag, text);
		
		assert (expectedZeroFlag == state.zFlag)
		else $error("Expected Zero Flag Value: %d, Actual Zero Flag Value: %d, Info: %s", expectedZeroFlag, state.zFlag, text);
	endtask
endlcass

program testProl16Model();
	initial begin : stimuli
		Prol16State state = new();
		Prol16Model model = new(state);
		
		TestClass testClass = new();
		
		//Reset
		model.reset();
		testClass.assertWithoutFlags(0, 0, model.state, 12, "Reset test");
		
		//Nop
		Prol16Opcode opcode_Nop = new(0, 0, Nop, 0);
		model.execute(opcode_Nop);
		testClass.assertWithoutFlags(0, 1, model.state, 0, "Nop test");
		
		//Loadi
		Prol16Opcode opcode_Loadi = new(0, 3, Loadi, 50);
		Prol16Opcode opcode_Loadi2 = new(1, 3, Loadi, 20);
		model.execute(opcode_Loadi);
		testClass.assertWithoutFlags(50, 3, model.state, 0, "Loadi test 1");
		model.execute(opcode_Loadi2);
		testClass.assertWithoutFlags(20, 5, model.state, 1, "Loadi test 2");
		
		//Jump
		Prol16Opcode opcode_Jump = new(0, 0, Jump, 0);
		model.execute(opcode_Jump);
		testClass.assertWithoutFlags(50, 50, model.state, 0, "Jump test");
		
		//Jumpc
		Prol16Opcode opcode_Jumpc = new(0, 0, Jumpc, 0);
		model.execute(opcode_Jumpc);
		testClass.assertWithoutFlags(50, 51, model.state, 0, "Jumpc test Carry = 0");
				
		model.state.cFlag = 1;
		model.execute(opcode_Jumpc);
		testClass.assertWithoutFlags(50, 50, model.state, 0, "Jumpc test Carry = 0");
		
		//Jumpz
		Prol16Opcode opcode_Jumpz = new(1, 0, Jumpz, 0);
		model.execute(opcode_Jumpz);
		testClass.assertWithoutFlags(20, 51, model.state, 1, "Jumpz test Zero = 0");
				
		model.state.zFlag = 1;
		model.execute(opcode_Jumpz);
		testClass.assertWithoutFlags(20, 20, model.state, 1, "Jumpz test Zero = 0");
		
		//Move
		Prol16Opcode opcode_Move = new(2, 0, Move, 0);
		Prol16Opcode opcode_Move2 = new(2, 1, Move, 0);
		model.execute(opcode_Move);
		testClass.assertWithoutFlags(50, 21, model.state, 2, "Move test 1");
		model.execute(opcode_Move2);
		testClass.assertWithoutFlags(20, 22, model.state, 2, "Move test 2");
		
		//And
		Prol16Opcode opcode_And = new(2, 0, And, 0);
		Prol16Opcode opcode_And2 = new(2, 3, And, 0);
		model.state.regs[3] = 64;
		model.execute(opcode_And);
		testClass.assertWithFlags(16, 23, 0, 0, model.state, 2, "And test 1");
		model.execute(opcode_And2);
		testClass.assertWithFlags(0, 24, 0, 1, model.state, 2, "And test 2");
		
		//Or
		Prol16Opcode opcode_Or = new(2, 4, Or, 0);
		Prol16Opcode opcode_Or2 = new(2, 3, Or, 0);
		model.execute(opcode_Or);
		testClass.assertWithFlags(0, 25, 0, 1, model.state, 2, "Or test 1");
		model.execute(opcode_Or2);
		testClass.assertWithFlags(64, 26, 0, 0, model.state, 2, "Or test 2");
		
		//Xor
		Prol16Opcode opcode_Xor = new(2, 3, Xor, 0);
		Prol16Opcode opcode_Xor2 = new(3, 4, Xor, 0);
		model.execute(opcode_Xor);
		testClass.assertWithFlags(0, 27, 0, 1, model.state, 2, "Xor test 1");
		model.state.regs[4] = 96;
		model.execute(opcode_Xor2);
		testClass.assertWithFlags(32, 28, 0, 0, model.state, 3, "Xor test 2");
		
		//Not
		Prol16Opcode opcode_Not = new(3, 7, Not, 0);
		Prol16Opcode opcode_Not2 = new(5, 8, Not, 0);
		model.execute(opcode_Not);
		testClass.assertWithFlags(65503, 29, 0, 0, model.state, 2, "Not test 1");
		model.state.regs[5] = 65535;
		model.execute(opcode_Not2);
		testClass.assertWithFlags(0, 30, 0, 1, model.state, 3, "Not test 2");
		
		
		$stop;
	end : stimuli
endprogram
