`include "Prol16State.sv"
`include "Prol16Opcode.sv"

class Prol16Model#(parameter int gNumRegs);
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
		bit tmpCFlag = 0; // tmp carry flag
		
		// inc pc here, overwrite in jumps
		state.programCounter++;
		
	  if (opcode.ra > (gNumRegs - 1) || opcode.ra < 0 ||
	      opcode.rb > (gNumRegs - 1) || opcode.rb < 0)
	      $display("Illegal register, doing nop");
	  else
		begin
		
		case (opcode.cmd)
			Nop:
			begin
			end
			
			Loadi:
			begin
				state.regs[opcode.ra] = opcode.data;
				state.programCounter++;	// TODO: necessary?
			end
			
			Jump: 
			begin
				state.programCounter = state.regs[opcode.ra];
			end
			
			Jumpc:
			begin
				if (state.cFlag == 1) 
					state.programCounter = state.regs[opcode.ra];
			end
			
			Jumpz:
			begin
				if (state.zFlag == 1)
					state.programCounter = state.regs[opcode.ra];
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
				state.regs[opcode.ra] = ~(state.regs[opcode.ra]);
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
				if (state.regs[opcode.ra][$size(pkgProl16::data_v) - 1] == 1)
				  state.cFlag = 1;
				else
				  state.cFlag = 0;
				
				state.regs[opcode.ra] = state.regs[opcode.ra] << 1;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Shr:
			begin
        			if (state.regs[opcode.ra][0] == 1)
				  state.cFlag = 1;
				else
				  state.cFlag = 0;
				  
        			state.regs[opcode.ra] = state.regs[opcode.ra] >> 1;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Shlc:
			begin
			  if (state.regs[opcode.ra][$size(pkgProl16::data_v) - 1] == 1)
				  tmpCFlag = 1;
				else
				  tmpCFlag = 0;
				
				state.regs[opcode.ra] = state.regs[opcode.ra] << 1;
				state.regs[opcode.ra][0] = state.cFlag;
				state.cFlag = tmpCFlag;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			Shrc:
			begin
			  if (state.regs[opcode.ra][0] == 1)
				  tmpCFlag = 1;
				else
				  tmpCFlag = 0;
				  
				state.regs[opcode.ra] = state.regs[opcode.ra] >> 1;
				state.regs[opcode.ra][$size(pkgProl16::data_v) - 1] = state.cFlag;
				state.cFlag = tmpCFlag;
				calcZeroFlag(state.regs[opcode.ra]);
			end
			
			default : $display("Wrong opcode: doing nop");
		endcase
		end
	endtask
endclass
