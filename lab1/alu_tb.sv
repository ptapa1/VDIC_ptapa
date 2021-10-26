
module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------


typedef enum bit[2:0] {and_op = 3'b000,
    or_op                    = 3'b001,
    add_op                   = 3'b100,
    sub_op                   = 3'b101} operation_t;
bit         	sin=1;
bit         		sout;
bit                clk;
bit                rst_n;
//operation_t        op_set;

//assign op = sin;

string             test_result = "PASSED";

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

mtm_Alu DUT (.sin, .sout, .clk, .rst_n);

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
        return 32'h0000000;
    else if (zero_ones == 2'b11)
        return 32'hFFFFFFF;
    else
        return 32'($random);
endfunction : get_data

//------------------------
// Tester main

bit [31:0] A,B,C; 
bit [89:0] buffer;
bit [3:0] crc, flags;
bit [2:0] crc_out, crc_expected;
bit [54:0] out;
bit [31:0] expected;


operation_t operation;

initial begin : tester
    reset_alu();
	
	//random data
    repeat (50) begin : tester_main
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
        process_data(out[54:44],C[31:24]);
        process_data(out[43:33],C[23:16]);
	    process_data(out[32:22],C[15:8]);
	    process_data(out[21:11],C[7:0]);
	    process_command(out[10:0],flags,crc_out);
	    get_crc_out(C,flags,crc_expected);
	    
	    
	    
	    begin
            expected = get_expected(A, B, operation);
            if(C === expected) begin
                `ifdef DEBUG
                $display("Test passed for A=%0b B=%0b op_set=%s", A, B, operation.name);
                $display("Asserted flags: %4b", flags);
                `endif
                test_result = "PASSED";
            end
            //else if()
            else begin
                $display("Test FAILED for A=%0b B=%0b op_set=%s", A, B, operation.name);
                $display("Expected: %b  received: %b", expected, C);
                test_result = "FAILED";
            end;
        end
    end
    
    //error generation
    //err_data - too many frames
    @(negedge clk);	    
        operation = get_op();
        A      = get_data();
        B      = get_data();
	    get_crc(B,A,operation,crc);
	    send_data(B[31:24]);
	    send_data(B[23:16]);
    	send_data(B[23:16]); //additional frame
	    send_data(B[15:8]);
	    send_data(B[7:0]);
	    send_data(A[31:24]);
	    send_data(A[23:16]);
	    send_data(A[15:8]);
	    send_data(A[7:0]);
	    send_command(operation,crc);
	    read_data(out);
        process_data(out[54:44],C[31:24]);
        process_data(out[43:33],C[23:16]);
	    process_data(out[32:22],C[15:8]);
	    process_data(out[21:11],C[7:0]);
	    process_command(out[10:0],flags,crc_out);
	    get_crc_out(C,flags,crc_expected);
	    
	    
	    begin
            expected = get_expected(A, B, operation);
            if(C === expected) begin
                `ifdef DEBUG
                $display("Test passed for A=%0b B=%0b op_set=%s", A, B, operation.name);
                $display("Asserted flags: %4b", flags);
                `endif
                test_result = "PASSED";
            end
            //else if()
            else begin
                $display("Test FAILED for A=%0b B=%0b op_set=%s", A, B, operation.name);
                $display("Expected: %b  received: %b", expected, C);
                test_result = "FAILED";
            end;
        end
    
    //err_data - too few frames
    @(negedge clk);	    
        operation = get_op();
        A      = get_data();
        B      = get_data();
	    get_crc(B,A,operation,crc);
	    send_data(B[31:24]);
	    //send_data(B[23:16]); deleted frame
	    send_data(B[15:8]);
	    send_data(B[7:0]);
	    send_data(A[31:24]);
	    send_data(A[23:16]);
	    //send_data(A[15:8]); deleted frame
	    send_data(A[7:0]);
	    send_command(operation,crc);
	    read_data(out);
        process_data(out[54:44],C[31:24]);
        process_data(out[43:33],C[23:16]);
	    process_data(out[32:22],C[15:8]);
	    process_data(out[21:11],C[7:0]);
	    process_command(out[10:0],flags,crc_out);
	    get_crc_out(C,flags,crc_expected);
	    
	    begin
            expected = get_expected(A, B, operation);
            if(C === expected) begin
                `ifdef DEBUG
                $display("Test passed for A=%0b B=%0b op_set=%s", A, B, operation.name);
                $display("Asserted flags: %4b", flags);
                `endif
                test_result = "PASSED";
            end
            //else if()
            else begin
                $display("Test FAILED for A=%0b B=%0b op_set=%s", A, B, operation.name);
                $display("Expected: %b  received: %b", expected, C);
                test_result = "FAILED";
            end;
	    end
	    
	//err_crc 
    @(negedge clk);	    
        operation = get_op();
        A      = get_data();
        B      = get_data();
	    get_crc(B,A,operation,crc);
	    crc = crc + 3'($random); //incorrect crc
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
        process_data(out[54:44],C[31:24]);
        process_data(out[43:33],C[23:16]);
	    process_data(out[32:22],C[15:8]);
	    process_data(out[21:11],C[7:0]);
	    process_command(out[10:0],flags,crc_out);
	    get_crc_out(C,flags,crc_expected);
	    
	    begin
            expected = get_expected(A, B, operation);
            if(C === expected) begin
                `ifdef DEBUG
                $display("Test passed for A=%0b B=%0b op_set=%s", A, B, operation.name);
                $display("Asserted flags: %4b", flags);
                `endif
                test_result = "PASSED";
            end
            //else if()
            else begin
                $display("Test FAILED for A=%0b B=%0b op_set=%s", A, B, operation.name);
                $display("Expected: %b  received: %b", expected, C);
                test_result = "FAILED";
            end;
        end
	    
	//err_op 
    @(negedge clk);	    
        operation = 3'b010;
        A      = get_data();
        B      = get_data();
	    get_crc(B,A,operation,crc);
	    crc = crc + 3'($random); //incorrect crc
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
        process_data(out[54:44],C[31:24]);
        process_data(out[43:33],C[23:16]);
	    process_data(out[32:22],C[15:8]);
	    process_data(out[21:11],C[7:0]);
	    process_command(out[10:0],flags,crc_out);
	    get_crc_out(C,flags,crc_expected);
	    
	    begin
            expected = get_expected(A, B, operation);
            if(C === expected) begin
                `ifdef DEBUG
                $display("Test passed for A=%0b B=%0b op_set=%s", A, B, operation.name);
                $display("Asserted flags: %4b", flags);
                `endif
                test_result = "PASSED";
            end
            //else if()
            else begin
                $display("Test FAILED for A=%0b B=%0b op_set=%s", A, B, operation.name);
                $display("Expected: %b  received: %b", expected, C);
                test_result = "FAILED";
            end;
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
    reg [10:0] packet = 11'b00000000001;

		packet[8:1] = A[7:0];
		for(int i=10;i>=0;i--) begin
			@(negedge clk);
	    		sin = packet[i];
		end
endtask

task send_command;
	input[2:0] in_op;
	input[3:0] in_crc;
    reg [10:0] packet = 11'b01000000001;
	
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
		crc_out	= packet[3:1];
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
            $display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op_set);
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
 //
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
//


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
	  
//	
endtask 

endmodule