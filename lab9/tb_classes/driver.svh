
class driver extends uvm_driver #(sequence_item);
	`uvm_component_utils(driver)

	virtual alu_bfm bfm;
	//uvm_get_port #(random_command) command_port;
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
			`uvm_fatal("DRIVER", "Failed to get BFM")
		//command_port = new("command_port",this);
	endfunction : build_phase
	
	task run_phase(uvm_phase phase);
		sequence_item command;
		
		void'(begin_tr(command));
		
		forever begin : command_loop
			bit [31:0] result;
            seq_item_port.get_next_item(command);
			if(command.error_trig == 2'b01) begin
				command.crc = get_crc(command.B,command.A,command.operation);
				command.send_error_flag_data = 1'b1;
				command.send_error_flag_crc = 1'b0;
				command.send_error_flag_op = 1'b0;
			end

			else if(command.error_trig == 2'b10) begin
				command.send_error_flag_crc = 1'b1;
				command.send_error_flag_data = 1'b0;
				command.send_error_flag_op = 1'b0;
				command.crc = command.crc + 2'($random);
			end

			else if(command.error_trig == 2'b11) begin
				command.send_error_flag_op = 1'b1;
				command.send_error_flag_crc = 1'b0;
				command.send_error_flag_data = 1'b0;
				command.operation = operation_t'(command.op_err);
				command.crc = get_crc(command.B,command.A,command.operation);
			end
			else begin
				command.send_error_flag_op = 1'b0;
				command.send_error_flag_crc = 1'b0;
				command.send_error_flag_data = 1'b0;
				command.crc = get_crc(command.B,command.A,command.operation);
			end
			
	        bfm.send_op(command);
            seq_item_port.item_done();
		end : command_loop
		
		end_tr(command);
		#100;
	endtask : run_phase
	
	protected function bit [3:0] get_crc;

		input [31:0] B;
		input [31:0] A;
		input [2:0] op;
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
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
endclass : driver