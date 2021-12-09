
virtual class base_tester extends uvm_component;
	
	`uvm_component_utils(base_tester)
	
	
	uvm_put_port #(alu_input) command_port;
	
	function new (string name,uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		command_port = new("command_port", this);
	endfunction : build_phase
//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions

	pure virtual function operation_t get_op();

//---------------------------------
	protected function no_ops get_no_op();
		bit [2:0] op_choice;
		op_choice = $random;
		case (op_choice)
			3'b010 : return no_op1;
			3'b011 : return no_op2;
			3'b110 : return no_op3;
			3'b111 : return no_op4;
		endcase // case (op_choice)
	endfunction : get_no_op
//---------------------------------
	pure virtual function bit [31:0] get_data();
	

//---------------------------------
	protected function bit [1:0] trigger_error();
		bit [1:0] error;
		error = 2'($random);
		if (error == 2'b01)
			return 2'b01;
		else if (error == 2'b10)
			return 2'b10;
		else if (error == 2'b11)
			return 2'b11;
		else
			return 2'b00;
	endfunction : trigger_error
	
	//------------------------------------------------------------------------------
// calculate CRC
//-----------------------------------------------
	protected function bit [3:0] get_crc;

		input [31:0] B;
		input [31:0] A;
		input [2:0] op;
		//output [3:0] crc;
		reg [67:0] d;
		reg [3:0] c;
		reg [3:0] newcrc;
		begin
			d[67:36] = B;
			d[35:4] = A;
			d[3] = 1'b1;
			d[2:0] = op;
			c = 4'b0000;

			newcrc[0] = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
			newcrc[1] = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
			newcrc[2] = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
			newcrc[3] = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
			get_crc = newcrc;
		end
	endfunction
	
	
//------------------------
// Tester main


	task run_phase(uvm_phase phase);
		alu_input command;
		phase.raise_objection(this);
		command.error_trig = 2'b00;
		command.send_error_flag_crc=0;
		command.send_error_flag_data=0;
		command.send_error_flag_op=0;
		command_port.put(command);
		repeat(10000)begin
			
			command.operation = get_op();
			command.A      = get_data();
			command.B      = get_data();
			command.crc = get_crc(command.B,command.A,command.operation);
			command.error_trig = trigger_error();
			if(command.error_trig == 2'b01) begin//
				command.send_error_flag_data <= 1'b1;
			end

			else if(command.error_trig == 2'b10) begin
				command.send_error_flag_crc <= 1'b1;
				command.crc = command.crc + 2'($random);
			end

			else if(command.error_trig == 2'b11) begin
				command.send_error_flag_op <= 1'b1;
				command.op_err = get_no_op();
				command.crc = get_crc(command.B,command.A,command.op_err);
			end
			command_port.put(command);
		end
		#2000;
		//$finish;
		phase.drop_objection(this);
	endtask 
	
	
	
endclass 
	