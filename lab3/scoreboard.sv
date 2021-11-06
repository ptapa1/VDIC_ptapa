module scoreboard(alu_bfm bfm);
import alu_pkg::*;
	
	
//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------
	always @(negedge bfm.clk) begin : scoreboard
		if(bfm.done) begin:verify_result

			if(bfm.send_error_flag_data || bfm.send_error_flag_crc || bfm.send_error_flag_op) begin
			`ifdef DEBUG
				$display("%0t Expected error packet for flag %s received for A=%0d B=%0d op_set=%0d", $time, error_flag.name, A, B, operation);
		   `endif
			end
			else begin
				logic [31:0] predicted_result;

				predicted_result = get_expected(bfm.A, bfm.B, bfm.operation);

				CHK_RESULT: assert(bfm.C === predicted_result) begin
			   `ifdef DEBUG
					$display("%0t Test passed for A=%0d B=%0d op_set=%0d", $time, bfm.A, bfm.B, bfm.operation);
			   `endif
				end
				else begin
					$warning("%0t Test FAILED for A=%0d B=%0d op_set=%0d\nExpected: %d  received: %d",
						$time, bfm.A, bfm.B, bfm.operation , predicted_result, bfm.C);
						bfm.test_result <= "FAILED";
				end;
			end
			bfm.done <= 1'b0;
			bfm.send_error_flag_data <= 1'b0;
			bfm.send_error_flag_crc <= 1'b0;
			bfm.send_error_flag_op <= 1'b0;
		end

end : scoreboard

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------
	function logic [31:0] get_expected(
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

endmodule