class scoreboard extends uvm_subscriber #(alu_input);
	
	`uvm_component_utils(scoreboard)
	
	virtual alu_bfm bfm;
	uvm_tlm_analysis_fifo #(alu_input) cmd_f;
	
	function new(string name, uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1, "Failed to get BFM");
		cmd_f = new("cmd_f", this);
	endfunction : build_phase
	
//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------
	function void write(alu_input t); 
		
			alu_input cmd;
				if(cmd.send_error_flag_data || cmd.send_error_flag_crc || cmd.send_error_flag_op) begin
				`ifdef DEBUG
					$display("%0t Expected error packet for flag %s received for A=%0d B=%0d op_set=%0d", $time, cmd.error_flag.name, cmd.A, cmd.B, cmd.operation);
			   `endif
				end
				else begin
					logic [31:0] predicted_result;
	
					predicted_result = get_expected(cmd.A, cmd.B, operation_t'(cmd.operation));
	
					CHK_RESULT: assert(cmd.C === predicted_result) begin
				   `ifdef DEBUG
						$display("%0t Test passed for A=%0d B=%0d op_set=%0d", $time, cmd.A, cmd.B, cmd.operation);
				   `endif
					end
					else begin
						$warning("%0t Test FAILED for A=%0d B=%0d op_set=%0d\nExpected: %d  received: %d",
							$time, cmd.A, cmd.B, cmd.operation , predicted_result, cmd.C);
							bfm.test_result <= "FAILED";
					end;
				end
				cmd.send_error_flag_data <= 1'b0;
				cmd.send_error_flag_crc <= 1'b0;
				cmd.send_error_flag_op <= 1'b0;
	endfunction

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------
	protected virtual function logic [31:0] get_expected(
			bit [31:0] A,
			bit [31:0] B,
			operation_t op_set
		);
		bit [31:0] ret;
		`ifdef DEBUG
		$display("%0t DEBUG: get_expected(%0d,%0d,%0d)",$time, A, B, op_set);
		`endif
		case(op_set)
			and_op : ret = A & B;
			add_op : ret = A + B;
			or_op : ret = A | B;
			sub_op : ret = B - A;
			default: begin
				$error("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op_set);
				return -1;
			end
		endcase
		return(ret);
	endfunction

endclass