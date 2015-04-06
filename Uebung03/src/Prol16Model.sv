`include "Prol16State.sv"
`include "Prol16Opcode.sv"

class Prol16Model;
	Prol16State state;
	
	function new(Prol16State _state);
		state = _state;
	endfunction
	
	task reset();
		state.reset();
	endtask
	
	task calcCarryFlag(int data);
		if (data > (2**$size(pkgProl16::data_v) - 1) || data < 0) 
			state.cFlag = 1;
		else
			state.cFlag = 0;
	endtask
	
	task calcZeroFlag(pkgProl16::data_v data);
		if (data == '0)
			state.zFlag = 1;
		else
			state.zFlag = 0;
	endtask
	
	task execute(Prol16Opcode opcode);
		int data = 0;	// tmp data for carry calc
		
		// inc pc here, overwrite in jumps
		state.pc++;
	
		case (opcode.cmd)
			Nop:
			begin
			end
			
			Loadi:
			begin
				state.regs[opcode.ra] = opcode.data;
				state.pc++;	// TODO: necessary?
			end
			
			Jump: 
			begin
				state.pc = state.regs[opcode.ra];
			end
			
			Jumpc:
			begin
				if (state.cFlag == 1) 
					state.pc = state.regs[opcode.ra];
			end
			
			Jumpz:
			begin
				if (state.zFlag == 1)
					state.pc = state.regs[opcode.ra];
			end
			
			Move:
			begin
				state.regs[opcode.ra] = state.regs[opcode.rb];
			end
			
			And:
			begin
				state.regs[opcode.ra] = state.regs[opcode.ra] & state.regs[opcode.rb];
				state.cFlag = 0;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Or:
			begin
				state.regs[opcode.ra] = state.regs[opcode.ra] | state.regs[opcode.rb];
				state.cFlag = 0;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Xor:
			begin
				state.regs[opcode.ra] = state.regs[opcode.ra] ^ state.regs[opcode.rb];
				state.cFlag = 0;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Not:
			begin
				state.regs[opcode.ra] = ~ state.regs[opcode.ra];
				state.cFlag = 0;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Add:
			begin
				data = state.regs[opcode.ra] + state.regs[opcode.rb];
				calcCarryFlag(data);
				state.regs[opcode.ra] = data;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Addc:
			begin
				data = state.regs[opcode.ra] + state.regs[opcode.rb] + state.cFlag;
				calcCarryFlag(data);
				state.regs[opcode.ra] = data;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Sub:
			begin
				data = state.regs[opcode.ra] - state.regs[opcode.rb];
				calcCarryFlag(data);
				state.regs[opcode.ra] = data;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Subc:
			begin
				data = state.regs[opcode.ra] - state.regs[opcode.rb] - state.cFlag;
				calcCarryFlag(data);
				state.regs[opcode.ra] = data;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Comp:
			begin
				data = state.regs[opcode.ra] - state.regs[opcode.rb];
				calcCarryFlag(data);
				calcZeroFlag(data);
			end
			
			Inc:
			begin
				data = state.regs[opcode.ra] + 1;
				calcCarryFlag(data);
				state.regs[opcode.ra] = data;
				calcZeroFlag(state.regs[opcode.ra]);
			end
				
			Dec:
			begin
				data = state.regs[opcode.ra] - 1;
				calcCarryFlag(data);
				state.regs[opcode.ra] = data;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Shl:
			begin
				data = state.regs[opcode.ra] << 1;
				calcCarryFlag(data);
				state.regs[opcode.ra] = data;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Shr:
			begin
				data = state.regs[opcode.ra] >> 1;
				calcCarryFlag(data);
				state.regs[opcode.ra] = data;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Shlc:
			begin
				data = state.regs[opcode.ra] << 1;
				data[0] = state.cFlag;
				calcCarryFlag(data);
				state.regs[opcode.ra] = data;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Shrc:
			begin
				data = state.regs[opcode.ra] >> 1;
				data[$size(pkgProl16::data_v) - 1] = state.cFlag;
				calcCarryFlag(data);
				state.regs[opcode.ra] = data;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			default : $display("Wrong opcode: doing nop");
		endcase
	endtask
endclass