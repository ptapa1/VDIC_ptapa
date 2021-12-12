class scoreboard extends uvm_subscriber #(result_transaction);
	
	`uvm_component_utils(scoreboard)
	
	typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
    } test_result;
	
	virtual alu_bfm bfm;
	uvm_tlm_analysis_fifo #(command_transaction) cmd_f;
	
	protected test_result tr = TEST_PASSED;
	
	function new(string name, uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
           $fatal(1, "Failed to get BFM");
		cmd_f = new("cmd_f", this);
	endfunction : build_phase
	
	
	
	protected function void print_test_result (test_result r);
        if(tr == TEST_PASSED) begin
            set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
            $write ("-----------------------------------\n");
            $write ("----------- Test PASSED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
        else begin
            set_print_color(COLOR_BOLD_BLACK_ON_RED);
            $write ("-----------------------------------\n");
            $write ("----------- Test FAILED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
	endfunction
	
	
	protected virtual function result_transaction get_expected(command_transaction cmd);
		result_transaction predicted;
		predicted = new("predicted");
		//bit [31:0] ret;
		`ifdef DEBUG
		$display("%0t DEBUG: get_expected(%0d,%0d,%0d)",$time, cmd.A, cmd.B, cmd.operation);
		`endif
		case(cmd.operation)
			and_op : predicted.C = cmd.A & cmd.B;
			add_op : predicted.C = cmd.A + cmd.B;
			or_op : predicted.C = cmd.A | cmd.B;
			sub_op : predicted.C = cmd.B - cmd.A;
			default: begin
				$error("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, operation_t'(cmd.operation));
				//return -1;
			end
		endcase
		return predicted;
	endfunction
	
//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------
	function void write(result_transaction t); 
			string data_str;
			command_transaction cmd;
			result_transaction predicted_result;
			//cmd = new("cmd");
			
			do
	            if (!cmd_f.try_get(cmd))
	                $fatal(1, "Missing command in self checker");
			while(bfm.rst_n == 0);
            
			if(cmd.send_error_flag_data || cmd.send_error_flag_crc || cmd.send_error_flag_op) begin
			//`ifdef DEBUG
			
				$display("!!!!!!!!!!!!!!!!!!%0t Expected error packet for flag %s received for A=%0d B=%0d op_set=%0d", $time, cmd.error_flag.name, cmd.A, cmd.B, cmd.operation);
		    //`endif
			end
			else begin
				predicted_result = get_expected(cmd);

				 data_str  = { cmd.convert2string(),
		            " ==>  Actual " , t.convert2string(),
		            "/Predicted ",predicted_result.convert2string()};
		
		        if (!predicted_result.compare(t)) begin
		            `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
		            tr = TEST_FAILED;
		        end
		        else
		            `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)
			end
			
	endfunction

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------
	
	
	function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction : report_phase

endclass