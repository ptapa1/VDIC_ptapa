
module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------
	typedef enum bit[5:0] {err_data = 6'b100100,
		err_crc                    = 6'b010010,
		err_op                   = 6'b001001} error_flags;

	typedef enum bit[2:0] {and_op = 3'b000,
		or_op                    = 3'b001,
		add_op                   = 3'b100,
		sub_op                   = 3'b101} operation_t;
	bit              sin = 1;
	bit                 sout;
	bit                clk;
	bit                rst_n;
	operation_t			op_set;

	string             test_result = "PASSED";
	string             all_tests_result = "PASSED";
	
	bit [31:0] A,B,C;
	bit [3:0] crc, flags;
	bit [2:0] crc_out, crc_expected;
	bit [54:0] out;
	bit [31:0] expected;
	bit done=1'b0;
	error_flags error_flag;

	operation_t operation;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

	mtm_Alu DUT (.sin, .sout, .clk, .rst_n);

//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

// Covergroup checking the op codes and theri sequences
	covergroup op_cov;

		option.name = "cg_op_cov";

		coverpoint operation {
			// #A1 test all operations
			bins test_all_ops[] = {[and_op : sub_op]};

		// #A6 two operations in row
		//?? bins A6_twoops[]       = ([and_op : sub_op] [* 2]);

		}

	endgroup

// Covergroup checking for min and max arguments of the ALU
	covergroup zeros_or_ones_on_ops;

		option.name = "cg_zeros_or_ones_on_ops";

		all_ops : coverpoint operation {
			//bins test_all_ops[] = {[and_op : sub_op]};
		}

		a_leg: coverpoint A {
	        bins zeros = {'h00000000};
	        bins others= {['h01:'hFFFFFFFE]};
	        bins ones  = {'hFFFFFFFF};
	    }
	
	    b_leg: coverpoint B {
	        bins zeros = {'h00000000};
	        bins others= {['h01:'hFFFFFFFE]};
	        bins ones  = {'hFFFFFFFF};
	    }

		B_op_00_FF: cross a_leg, b_leg, all_ops {

			// #B1 simulate all zero input for all the operations

			bins test_zeros_add_00          = binsof (all_ops) intersect {add_op} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins test_zeros_and_00          = binsof (all_ops) intersect {and_op} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins test_zeros_or_00          = binsof (all_ops) intersect {or_op} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins test_zeros_sub_00          = binsof (all_ops) intersect {sub_op} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			// #B2 simulate all one input for all the operations

			bins test_ones_add_FF          = binsof (all_ops) intersect {add_op} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins test_ones_and_FF          = binsof (all_ops) intersect {and_op} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins test_ones_or_FF          = binsof (all_ops) intersect {or_op} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins test_ones_sub_FF          = binsof (all_ops) intersect {sub_op} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));


			ignore_bins others_only =
			binsof(a_leg.others) && binsof(b_leg.others);
		}

	endgroup

covergroup output_flags;

		option.name = "cg_output_flags";

		coverpoint flags {
			bins carry = {'h8};
			bins overflow= {'h4};
			bins zero  = {'h2};
			bins negative  = {'h1};
		}

	

	endgroup

op_cov                      oc;
zeros_or_ones_on_ops        c_00_FF;
output_flags				out_flags;
initial begin : coverage
    oc      = new();
    c_00_FF = new();
	out_flags = new();
    forever begin : sample_cov
        @(posedge clk);
        if(rst_n) begin
            oc.sample();
            c_00_FF.sample();
	        out_flags.sample();
        end
    end
end : coverage

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
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions

	function operation_t get_op();
		bit [2:0] op_choice;
		op_choice = $random;
		case (op_choice)
			3'b000 : return and_op;
			3'b001 : return or_op;
			3'b100 : return add_op;
			3'b101 : return sub_op;
		endcase // case (op_choice)
	endfunction : get_op

//---------------------------------
	function bit [31:0] get_data();
		bit [1:0] zero_ones;
		zero_ones = 2'($random);
		if (zero_ones == 2'b00)
			return 32'h00000000;
		else if (zero_ones == 2'b11)
			return 32'hFFFFFFFF;
		else
			return 32'($random);
	endfunction : get_data

//------------------------
// Tester main

	

	initial begin : tester
		reset_alu();
		
		repeat(1000)begin
			
	    
	        @(negedge clk);                                                                                                                                 
	        operation = get_op();                                                                                                                           
	        A      = get_data();
			B      = get_data();
			get_crc(B,A,operation,crc);                                                                                                                     
			send_data(B[31:24]);                                                                                            
			send_data(B[23:16]);                                                                                     
			send_data(B[15:8]);                                                                                      
			send_data(B[7:0]);                                                                                       
			send_data(A[31:24]);                                                                                     
			send_data(A[23:16]);                                                                                     
	        send_data(A[15:8]);                                                                                      
			send_data(A[7:0]);                                                                                       
			send_command(operation,crc);
			
			read_data(out);
			
			if(out[54:53] == 2'b00)begin                                                                             
				process_data(out[54:44],C[31:24]);                                                                   
				process_data(out[43:33],C[23:16]);                                                                   
				process_data(out[32:22],C[15:8]);                                                                    
				process_data(out[21:11],C[7:0]);                                                                     
				process_command(out[10:0],flags,crc_out);                                                            
				get_crc_out(C,flags,crc_expected);                                                                   
			end                                                                                                      
			else if(out[54:53] == 2'b01)begin                                                                        
				process_error(out[54:44],error_flag);                                                                                                                                                                  
			end                                                                                                      
			else begin                                                                                               
				$display("INTERNAL ERROR - incorrect packet returned\n");                                                                                   
			end
			done = 1'b1;
			
		    if($get_coverage() == 100) break; 
		    
		end                                  	
	
	
	
		$finish;
	end : tester

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------
	task reset_alu();
	`ifdef DEBUG
		$display("%0t DEBUG: reset_alu", $time);
	`endif
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
				test_result = "FAILED";
				return -1;
			end
		endcase
		return(ret);
	endfunction

//------------------------------------------------------------------------------
// calculate CRC
//-----------------------------------------------
	task get_crc;

		input [31:0] B;
		input [31:0] A;
		input [2:0] op;
		output [3:0] crc;
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
			crc = newcrc;
		end
	endtask


	task get_crc_out;
		input [31:0] data;
		input [3:0] flags;
		output [2:0] crc;
		reg [36:0] d;
		reg [2:0] c;
		reg [2:0] newcrc;
		begin
			d [36:5]= data;
			d [4]= 1'b0;
			d [3:0]= flags;
			c = 3'b000;

			newcrc[0] = d[35] ^ d[32] ^ d[31] ^ d[30] ^ d[28] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[18] ^ d[17] ^ d[16] ^ d[14] ^ d[11] ^ d[10] ^ d[9] ^ d[7] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[1];
			newcrc[1] = d[36] ^ d[35] ^ d[33] ^ d[30] ^ d[29] ^ d[28] ^ d[26] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[16] ^ d[15] ^ d[14] ^ d[12] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[2] ^ d[1] ^ d[0] ^ c[1] ^ c[2];
			newcrc[2] = d[36] ^ d[34] ^ d[31] ^ d[30] ^ d[29] ^ d[27] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[17] ^ d[16] ^ d[15] ^ d[13] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[3] ^ d[2] ^ d[1] ^ c[0] ^ c[2];
			crc = newcrc;
		end


	endtask

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------
always @(negedge clk) begin : scoreboard
    if(done) begin:verify_result
        logic [31:0] predicted_result;

        predicted_result = get_expected(A, B, operation);

        CHK_RESULT: assert(C === predicted_result) begin
           `ifdef DEBUG
            $display("%0t Test passed for A=%0d B=%0d op_set=%0d", $time, A, B, operation);
           `endif
        end
        else begin
            $warning("%0t Test FAILED for A=%0d B=%0d op_set=%0d\nExpected: %d  received: %d",
                $time, A, B, op_set , predicted_result, C);
        end;
        done = 1'b0;
    end
end : scoreboard

endmodule