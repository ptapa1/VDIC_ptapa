
class driver extends uvm_component;
	`uvm_component_utils(driver)

	virtual alu_bfm bfm;
	uvm_get_port #(alu_input) command_port;
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
			$fatal(1, "Failed to get BFM");
		command_port = new("command_port",this);
	endfunction : build_phase
	
	task run_phase(uvm_phase phase);
		alu_input command;
		alu_output command_out;
		//alu_output result;
		bfm.reset_alu();
		forever begin : command_loop
			command_port.get(command);
			if(command.error_trig == 2'b01) begin
				command.send_error_flag_data <= 1'b1;
				bfm.send_data(command.B[31:24]);
				bfm.send_data(command.B[23:16]);
				bfm.send_data(command.B[7:0]);
				bfm.send_data(command.A[23:16]);
				bfm.send_data(command.A[15:8]);
				bfm.send_data(command.A[7:0]);
				bfm.send_command(command);
			end

			else if(command.error_trig == 2'b10) begin
				command.send_error_flag_crc <= 1'b1;
				bfm.send_data(command.B[31:24]);
				bfm.send_data(command.B[23:16]);
				bfm.send_data(command.B[15:8]);
				bfm.send_data(command.B[7:0]);
				bfm.send_data(command.A[31:24]);
				bfm.send_data(command.A[23:16]);
				bfm.send_data(command.A[15:8]);
				bfm.send_data(command.A[7:0]);
				bfm.send_command(command);
			end

			else if(command.error_trig == 2'b11) begin
				command.send_error_flag_op <= 1'b1;
				bfm.send_data(command.B[31:24]);
				bfm.send_data(command.B[23:16]);
				bfm.send_data(command.B[15:8]);
				bfm.send_data(command.B[7:0]);
				bfm.send_data(command.A[31:24]);
				bfm.send_data(command.A[23:16]);
				bfm.send_data(command.A[15:8]);
				bfm.send_data(command.A[7:0]);
				bfm.send_command(command);

			end

			else begin
				bfm.send_data(command.B[31:24]);
				bfm.send_data(command.B[23:16]);
				bfm.send_data(command.B[15:8]);
				bfm.send_data(command.B[7:0]);
				bfm.send_data(command.A[31:24]);
				bfm.send_data(command.A[23:16]);
				bfm.send_data(command.A[15:8]);
				bfm.send_data(command.A[7:0]);
				bfm.send_command(command);
			end

			bfm.read_data(bfm.out);

			if(bfm.out[54:53] == 2'b00)begin
				bfm.process_data(command_out.read[54:44],command_out.C[31:24]);
				bfm.process_data(command_out.read[43:33],command_out.C[23:16]);
				bfm.process_data(command_out.read[32:22],command_out.C[15:8]);
				bfm.process_data(command_out.read[21:11],command_out.C[7:0]);
				bfm.process_command(command_out.read[10:0],command_out.flags,bfm.crc_out);
			end
			else if(bfm.out[54:53] == 2'b01)begin
				bfm.process_error(command_out.read[54:44],command_out.error_flag);
			end
			else begin
				$display("INTERNAL ERROR - incorrect packet returned\n");
				bfm.test_result = "FAILED";
			end
			
			bfm.done = 1'b1;
			
		end : command_loop
	endtask : run_phase
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
endclass : driver