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
		model.state.cFlag = 1;
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
		
		$stop;
	end : stimuli
endprogram
