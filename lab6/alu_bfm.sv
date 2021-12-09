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
	command_monitor command_monitor_h;
	alu_input inputs_h;
	alu_output outputs_h;
	result_monitor result_monitor_h;
	
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
		input alu_input A_in;
		static reg [10:0] packet = 11'b00000000001;

		packet[8:1] = A_in.A[7:0];
		for(int i=10;i>=0;i--) begin
			@(negedge clk);
			sin = packet[i];
		end
		@(negedge clk);
	endtask

	task send_command;
		input alu_input in_alu;
		//input[3:0] in_crc;
		static reg [10:0] packet = 11'b01000000001;

		packet [7:5]= in_alu.operation;
		packet [4:1]= in_alu.crc;
		for(int i=10;i>=0;i--)begin
			@(negedge clk);
			sin = packet[i];
		end
		@(negedge clk);
	endtask

	

//------------------------------------------------------------------------------
// read data and command tasks
//------------------------------------------------------------------------------

	task read_data;
		output alu_output alu_out;

		@(negedge sout);
		for(int i=54;i>=0;i--)begin
			@(negedge clk);
			alu_out.read[i] = sout;
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
	
	//command_monitor_h.write_to_monitor(A, B, operation);
	
//	function operation_t op2enum();
//    operation_t opi;
//    if( ! $cast(opi,op) )
//        $fatal(1, "Illegal operation on op bus");
//    return opi;
//endfunction : op2enum
//
//
always @(posedge clk) begin : op_monitor
    static bit in_command = 0;
    alu_input inputs;
    if (!done) begin : start_high
        if (!in_command) begin : new_command
            inputs.A  <= inputs_h.A;
            inputs.B  <= inputs_h.B;
            inputs.operation <= inputs_h.operation;
            command_monitor_h.write_to_monitor(inputs);
            //in_command = 1;
        end : new_command
    end : start_high
    else // start low
        in_command = 0;
end : op_monitor

always @(negedge rst_n) begin : rst_monitor
    alu_input command;
	forever begin
			@(negedge rst_n) begin
				command = inputs_h;
				reset_alu();
			    if (command_monitor_h != null) //guard against VCS time 0 negedge
			        command_monitor_h.write_to_monitor(command);
			end
	end
	
end : rst_monitor

//result_monitor result_monitor_h;
//
initial begin : result_monitor_thread
    forever begin
        @(posedge clk) ;
        if (done)begin
            result_monitor_h.write_to_monitor(outputs_h);
        	done = 1'b0;
        end 
    end
end : result_monitor_thread
	
endinterface : alu_bfm