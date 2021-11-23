class tester;
	virtual alu_bfm bfm;
	
	function new (virtual alu_bfm b);
		bfm = b;
	endfunction
//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions

	protected function operation_t get_op();
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
	protected function bit [31:0] get_data();
		bit [1:0] zero_ones;
		zero_ones = 2'($random);
		if (zero_ones == 2'b00)
			return 32'h00000000;
		else if (zero_ones == 2'b11)
			return 32'hFFFFFFFF;
		else
			return 32'($random);
	endfunction : get_data

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


	task execute();
		bfm.reset_alu();
		repeat(10000)begin
			@(negedge bfm.clk);
			bfm.operation = get_op();
			bfm.A      = get_data();
			bfm.B      = get_data();
			bfm.crc = get_crc(bfm.B,bfm.A,bfm.operation);
			bfm.error_trig = trigger_error();
			if(bfm.error_trig == 2'b01) begin//
				bfm.send_error_flag_data <= 1'b1;
				bfm.send_data(bfm.B[31:24]);
				bfm.send_data(bfm.B[23:16]);
				bfm.send_data(bfm.B[7:0]);
				bfm.send_data(bfm.A[23:16]);
				bfm.send_data(bfm.A[15:8]);
				bfm.send_data(bfm.A[7:0]);
				bfm.send_command(bfm.operation,bfm.crc);
			end

			else if(bfm.error_trig == 2'b10) begin
				bfm.send_error_flag_crc <= 1'b1;
				bfm.crc = bfm.crc + 2'($random);
				bfm.send_data(bfm.B[31:24]);
				bfm.send_data(bfm.B[23:16]);
				bfm.send_data(bfm.B[15:8]);
				bfm.send_data(bfm.B[7:0]);
				bfm.send_data(bfm.A[31:24]);
				bfm.send_data(bfm.A[23:16]);
				bfm.send_data(bfm.A[15:8]);
				bfm.send_data(bfm.A[7:0]);
				bfm.send_command(bfm.operation,bfm.crc);
			end

			else if(bfm.error_trig == 2'b11) begin
				bfm.send_error_flag_op <= 1'b1;
				bfm.op = get_no_op();
				bfm.crc = get_crc(bfm.B,bfm.A,bfm.op);
				bfm.send_data(bfm.B[31:24]);
				bfm.send_data(bfm.B[23:16]);
				bfm.send_data(bfm.B[15:8]);
				bfm.send_data(bfm.B[7:0]);
				bfm.send_data(bfm.A[31:24]);
				bfm.send_data(bfm.A[23:16]);
				bfm.send_data(bfm.A[15:8]);
				bfm.send_data(bfm.A[7:0]);
				bfm.send_command(bfm.op,bfm.crc);

			end

			else begin
				bfm.send_data(bfm.B[31:24]);
				bfm.send_data(bfm.B[23:16]);
				bfm.send_data(bfm.B[15:8]);
				bfm.send_data(bfm.B[7:0]);
				bfm.send_data(bfm.A[31:24]);
				bfm.send_data(bfm.A[23:16]);
				bfm.send_data(bfm.A[15:8]);
				bfm.send_data(bfm.A[7:0]);
				bfm.send_command(bfm.operation,bfm.crc);
			end

			bfm.read_data(bfm.out);

			if(bfm.out[54:53] == 2'b00)begin
				bfm.process_data(bfm.out[54:44],bfm.C[31:24]);
				bfm.process_data(bfm.out[43:33],bfm.C[23:16]);
				bfm.process_data(bfm.out[32:22],bfm.C[15:8]);
				bfm.process_data(bfm.out[21:11],bfm.C[7:0]);
				bfm.process_command(bfm.out[10:0],bfm.flags,bfm.crc_out);
			end
			else if(bfm.out[54:53] == 2'b01)begin
				bfm.process_error(bfm.out[54:44],bfm.error_flag);
			end
			else begin
				$display("INTERNAL ERROR - incorrect packet returned\n");
				bfm.test_result = "FAILED";
			end
			bfm.done = 1'b1;
			if($get_coverage() == 100) break;

		end

		$finish;
	endtask 
	
	
	
endclass : tester
