interface alu_bfm;
import alu_pkg::*;
	
	bit              sin = 1;
	bit                 sout;
	bit                clk;
	bit                rst_n=1'b1;
	bit [31:0] A,B,C;
	bit [3:0] crc, flags;
	bit [2:0] op;
	bit [2:0] crc_out;
	bit [54:0] out;
	bit send_error_flag_data=0,send_error_flag_crc=0,send_error_flag_op=0;
	bit [1:0] error_trig=2'b0;
	bit done=1'b0;
	error_flags error_flag;
	
	operation_t operation;
	
	string   test_result = "PASSED";
//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

	initial begin : clk_gen
		clk = 0;
		forever begin : clk_frv
			#10;
			clk = ~clk;
		end
	end
	
//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------
	task reset_alu();
	`ifdef DEBUG
		$display("%0t DEBUG: reset_alu", $time);
	`endif
		@(negedge clk);
		rst_n = 1'b0;
		@(negedge clk);
		rst_n = 1'b1;
	endtask
	
	
	//------------------------------------------------------------------------------
// send data and command tasks
//------------------------------------------------------------------------------

	task send_data;
		input[7:0] A;
		static reg [10:0] packet = 11'b00000000001;

		packet[8:1] = A[7:0];
		for(int i=10;i>=0;i--) begin
			@(negedge clk);
			sin = packet[i];
		end
	endtask

	task send_command;
		input[2:0] in_op;
		input[3:0] in_crc;
		static reg [10:0] packet = 11'b01000000001;

		packet [7:5]= in_op;
		packet [4:1]= in_crc;
		for(int i=10;i>=0;i--)begin
			@(negedge clk);
			sin = packet[i];
		end
	endtask
	
	task send_op (alu_input command);
		A = command.A;
		B = command.B;
		operation = operation_t'(command.operation);
		crc = command.crc;
		send_error_flag_data = command.send_error_flag_data;
		send_error_flag_crc = command.send_error_flag_crc;
		send_error_flag_op  = command.send_error_flag_op;
		error_trig = command.error_trig;

		if(error_trig == 2'b01) begin
			send_data(B[31:24]);
			send_data(B[23:16]);
			send_data(B[7:0]);
			send_data(A[23:16]);
			send_data(A[15:8]);
			send_data(A[7:0]);
			send_command(operation,crc);
		end
	
		else if(error_trig == 2'b10) begin
			send_data(B[31:24]);
			send_data(B[23:16]);
			send_data(B[15:8]);
			send_data(B[7:0]);
			send_data(A[31:24]);
			send_data(A[23:16]);
			send_data(A[15:8]);
			send_data(A[7:0]);
			send_command(operation,crc);
		end
	
		else if(error_trig == 2'b11) begin
			send_data(B[31:24]);
			send_data(B[23:16]);
			send_data(B[15:8]);
			send_data(B[7:0]);
			send_data(A[31:24]);
			send_data(A[23:16]);
			send_data(A[15:8]);
			send_data(A[7:0]);
			send_command(operation,crc);
	
		end
	
		else begin
			send_data(B[31:24]);
			send_data(B[23:16]);
			send_data(B[15:8]);
			send_data(B[7:0]);
			send_data(A[31:24]);
			send_data(A[23:16]);
			send_data(A[15:8]);
			send_data(A[7:0]);
			send_command(operation,crc);
		end
	
		read_data(out);
	
		if(out[54:53] == 2'b00)begin
			process_data(out[54:44],C[31:24]);
			process_data(out[43:33],C[23:16]);
			process_data(out[32:22],C[15:8]);
			process_data(out[21:11],C[7:0]);
			process_command(out[10:0],flags,crc_out);
		end
		else if(out[54:53] == 2'b01)begin
			process_error(out[54:44],error_flag);
		end
		else begin
			$display("INTERNAL ERROR - incorrect packet returned\n");
			test_result = "FAILED";
		end
		done=1'b1;
	endtask


//------------------------------------------------------------------------------
// read data and command tasks
//------------------------------------------------------------------------------

	task read_data;
		output[54:0] alu_out;

		@(negedge sout);
		for(int i=54;i>=0;i--)begin
			@(negedge clk);
			alu_out[i] = sout;
		end
	endtask

	task process_data;
		input [10:0] packet;
		output[7:0] alu_out;

		@(negedge clk);
		alu_out[7:0] = packet[8:1];

	endtask


	task process_command;
		input [10:0] packet;
		output[3:0] flags_out;
		output[2:0] crc_out;

		@(negedge clk)begin
			flags_out = packet[7:4];
			crc_out = packet[3:1];
		end
	endtask

	task process_error;
		input [10:0] packet;
		output error_flags flags_out;

		@(negedge clk)begin
			flags_out = error_flags'(packet[7:2]);
		end
	endtask
	
	command_monitor command_monitor_h;



	always @(posedge clk) begin : op_monitor
	    alu_input command;
	    if (done) begin : start_high
	            command.A  <= A;
	            command.B  <= B;
	            command.operation <= operation;
		    	command.flags <= flags;
		    	command.error_flag <= error_flag;
	            command_monitor_h.write_to_monitor(command);
	    end : start_high
	end : op_monitor
	
	always @(negedge rst_n) begin : rst_monitor
	    alu_input command;
	    reset_alu();
	    if (command_monitor_h != null) //guard against VCS time 0 negedge
	        command_monitor_h.write_to_monitor(command);
	end : rst_monitor
	
	result_monitor result_monitor_h;
	alu_input result;
	
	initial begin : result_monitor_thread
	    forever begin
	        @(posedge clk) ;
	        if (done)
	            result_monitor_h.write_to_monitor(result);
	        	done = 1'b0;
	    end
	end : result_monitor_thread
	
endinterface : alu_bfm