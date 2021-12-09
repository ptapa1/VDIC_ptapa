class scoreboard extends uvm_subscriber #(alu_output);
	
	`uvm_component_utils(scoreboard)
	
	virtual alu_bfm bfm;
	uvm_tlm_analysis_fifo #(alu_input) cmd_f;
	
	function new(string name, uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		cmd_f = new("cmd_f", this);
	endfunction : build_phase
	
	function void write(alu_output t);
		alu_input cmd;
		alu_output cmd_out;
		//forever  begin 
			//if(bfm.done) begin:verify_result
	
				if(cmd.send_error_flag_data || cmd.send_error_flag_crc ) begin
				`ifdef DEBUG
					$display("%0t Expected error packet for flag %s received for A=%0d B=%0d op_set=%0d", $time, cmd.error_flag.name, cmd.A, cmd.B, cmd.operation);
			   `endif
				end
				else if(cmd.send_error_flag_op) begin
				`ifdef DEBUG
					$display("%0t Expected error packet for flag %s received for A=%0d B=%0d op_set=%0d", $time, cmd.error_flag.name, cmd.A, cmd.B, cmd.op_err);
			   `endif
				end
				else begin
					logic [31:0] predicted_result;
	
					predicted_result = get_expected(cmd);
	
					CHK_RESULT: assert(cmd_out.C === predicted_result) begin
				   `ifdef DEBUG
						$display("%0t Test passed for A=%0d B=%0d op_set=%0d", $time, cmd.A, cmd.B, cmd.operation);
				   `endif
					end
					else begin
						$warning("%0t Test FAILED for A=%0d B=%0d op_set=%0d\nExpected: %d  received: %d",
							$time, cmd.A, cmd.B, cmd.operation , predicted_result, cmd_out.C);
							bfm.test_result <= "FAILED";
					end;
				end
				//bfm.done <= 1'b0;
				cmd.send_error_flag_data <= 1'b0;
				cmd.send_error_flag_crc <= 1'b0;
				cmd.send_error_flag_op <= 1'b0;
			//end
		//end
	endfunction : write
	
//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------
	//task run_phase(uvm_phase phase); 
	//	forever  begin 
	//		@(negedge bfm.clk)
	//		if(bfm.done) begin:verify_result
	//
	//			if(bfm.send_error_flag_data || bfm.send_error_flag_crc || bfm.send_error_flag_op) begin
	//			`ifdef DEBUG
	//				$display("%0t Expected error packet for flag %s received for A=%0d B=%0d op_set=%0d", $time, error_flag.name, A, B, operation);
	//		   `endif
	//			end
	//			else begin
	//				logic [31:0] predicted_result;
	//
	//				predicted_result = get_expected(bfm.A, bfm.B, bfm.operation);
	//
	//				CHK_RESULT: assert(bfm.C === predicted_result) begin
	//			   `ifdef DEBUG
	//					$display("%0t Test passed for A=%0d B=%0d op_set=%0d", $time, bfm.A, bfm.B, bfm.operation);
	//			   `endif
	//				end
	//				else begin
	//					$warning("%0t Test FAILED for A=%0d B=%0d op_set=%0d\nExpected: %d  received: %d",
	//						$time, bfm.A, bfm.B, bfm.operation , predicted_result, bfm.C);
	//						bfm.test_result <= "FAILED";
	//				end;
	//			end
	//			bfm.done <= 1'b0;
	//			bfm.send_error_flag_data <= 1'b0;
	//			bfm.send_error_flag_crc <= 1'b0;
	//			bfm.send_error_flag_op <= 1'b0;
	//		end
	//	end

//endtask 

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------
	protected virtual function alu_output get_expected(
			alu_input data
		);
		alu_output ret;
		`ifdef DEBUG
		$display("%0t DEBUG: get_expected(%0d,%0d,%0d)",$time, data.A, data.B, data.operation);
		`endif
		case(data.operation)
			and_op : ret = data.A & data.B;
			add_op : ret = data.A + data.B;
			or_op : ret = data.A | data.B;
			sub_op : ret = data.B - data.A;
			default: begin
				$error("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, data.operation);
				return -1;
			end
		endcase
		return(ret);
	endfunction

endclass