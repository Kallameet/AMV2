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
endclass

program testProl16Model();
	initial begin : stimuli
		Prol16State state = new();
		Prol16Model model = new(state);
		
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
	
		//Reset
		model.reset();
		testClass.assertWithoutFlags(0, 0, model.state, 12, "Reset test");
		
		//Nop
		model.execute(opcode_Nop);
		testClass.assertWithoutFlags(0, 1, model.state, 0, "Nop test");
		
		//Loadi
		model.execute(opcode_Loadi);
		testClass.assertWithoutFlags(50, 3, model.state, 0, "Loadi test 1");
		model.execute(opcode_Loadi2);
		testClass.assertWithoutFlags(20, 5, model.state, 1, "Loadi test 2");
		
		//Jump
		model.execute(opcode_Jump);
		testClass.assertWithoutFlags(50, 50, model.state, 0, "Jump test");
		
		//Jumpc
		model.execute(opcode_Jumpc);
		testClass.assertWithoutFlags(50, 51, model.state, 0, "Jumpc test Carry = 0");
				
		model.state.cFlag = 1;
		model.execute(opcode_Jumpc);
		testClass.assertWithoutFlags(50, 50, model.state, 0, "Jumpc test Carry = 0");
		
		//Jumpz
		model.execute(opcode_Jumpz);
		testClass.assertWithoutFlags(20, 51, model.state, 1, "Jumpz test Zero = 0");
				
		model.state.zFlag = 1;
		model.execute(opcode_Jumpz);
		testClass.assertWithoutFlags(20, 20, model.state, 1, "Jumpz test Zero = 0");
		
		//Move
		model.execute(opcode_Move);
		testClass.assertWithoutFlags(50, 21, model.state, 2, "Move test 1");
		model.execute(opcode_Move2);
		testClass.assertWithoutFlags(20, 22, model.state, 2, "Move test 2");
		
		//And
		model.state.regs[3] = 64;
		model.execute(opcode_And);
		testClass.assertWithFlags(16, 23, 0, 0, model.state, 2, "And test 1");
		model.execute(opcode_And2);
		testClass.assertWithFlags(0, 24, 0, 1, model.state, 2, "And test 2");
		
		//Or
		model.execute(opcode_Or);
		testClass.assertWithFlags(0, 25, 0, 1, model.state, 2, "Or test 1");
		model.execute(opcode_Or2);
		testClass.assertWithFlags(64, 26, 0, 0, model.state, 2, "Or test 2");
		
		//Xor
		model.execute(opcode_Xor);
		testClass.assertWithFlags(0, 27, 0, 1, model.state, 2, "Xor test 1");
		model.state.regs[4] = 96;
		model.execute(opcode_Xor2);
		testClass.assertWithFlags(32, 28, 0, 0, model.state, 3, "Xor test 2");
		
		//Not
		model.execute(opcode_Not);
		testClass.assertWithFlags(65503, 29, 0, 0, model.state, 3, "Not test 1");
		model.state.regs[5] = 65535;
		model.execute(opcode_Not2);
		testClass.assertWithFlags(0, 30, 0, 1, model.state, 5, "Not test 2");
		
		//Add
		model.state.regs[6] = 10;
		model.state.regs[7] = 30;
		model.execute(opcode_Add);
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
		model.execute(opcode_Addc);
		testClass.assertWithFlags(40, 34, 0, 0, model.state, 8, "Addc test 1");
		model.state.regs[8] = 10;
		model.state.regs[9] = 30;
		model.state.cFlag = 1;
		model.execute(opcode_Addc);
		testClass.assertWithFlags(41, 35, 0, 0, model.state, 8, "Addc test 1");
		model.state.regs[8] = 65535;
		model.state.regs[9] = 1;
		model.execute(opcode_Addc);
		testClass.assertWithFlags(0, 36, 1, 1, model.state, 8, "Addc test 2");
		model.state.regs[8] = 65535;
		model.state.regs[9] = 1;
		model.execute(opcode_Addc);
		testClass.assertWithFlags(1, 37, 1, 0, model.state, 8, "Addc test 3");
		
		//Sub
		model.state.regs[10] = 30;
		model.state.regs[11] = 10;
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
		model.execute(opcode_Subc);
		testClass.assertWithFlags(20, 41, 0, 0, model.state, 12, "Subc test 1");
		model.state.regs[12] = 30;
		model.state.regs[13] = 10;
		model.state.cFlag = 1;
		model.execute(opcode_Subc);
		testClass.assertWithFlags(19, 41, 0, 0, model.state, 12, "Subc test 1");
		model.state.regs[12] = 10;
		model.state.regs[13] = 10;
		model.execute(opcode_Subc);
		testClass.assertWithFlags(0, 42, 0, 1, model.state, 12, "Subc test 2");
		model.state.regs[12] = 1;
		model.state.regs[13] = 2;
		model.execute(opcode_Subc);
		testClass.assertWithFlags(65535, 43, 1, 0, model.state, 12, "Subc test 3");
		
		$stop;
	end : stimuli
endprogram
