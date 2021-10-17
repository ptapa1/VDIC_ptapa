
module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

typedef enum bit[2:0] {and_op = 3'b000,
    or_op                    = 3'b001,
    add_op                   = 3'b100,
    sub_op                   = 3'b101} operation_t;
wire         sin;
wire         		sout;
bit                clk;
bit                rst_n;
//operation_t        op_set;

assign op = sin;

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
        return 32'h0000;
    else if (zero_ones == 2'b11)
        return 32'hFFFF;
    else
        return 32'($random);
endfunction : get_data

//------------------------
// Tester main

bit [31:0] A,B; 
bit [31:0] result;
operation_t operation;

initial begin : tester
    reset_alu();
    repeat (100) begin : tester_main
        @(negedge clk);
        operation = get_op();
        A      = get_data();
        B      = get_data();
        case (operation) // handle the start signal
            and_op: begin : case_and_op
                @(negedge clk);
	            result = A & B;
            end
            or_op: begin : case_or_op
                @(negedge clk);
	            result = A | B;
            end
            add_op: begin : case_add_op
                @(negedge clk);
	            result = A + B;
            end
            sub_op: begin : case_sub_op
                @(negedge clk);
	            result = A - B;
            end
            default: begin : case_default
                @(negedge clk);

                //------------------------------------------------------------------------------
                // temporary data check - scoreboard will do the job later
                begin
                    automatic bit [31:0] expected = get_expected(A, B, operation);
                    if(result === expected) begin
                        //`ifdef DEBUG
                        $display("PASSED");
                        $display("Test passed for A=%0d B=%0d op_set=%0d", A, B, operation);
                        //`endif
                    end
                    else begin
                        $display("Test FAILED for A=%0d B=%0d op_set=%0d", A, B, operation);
                        $display("Expected: %d  received: %d", expected, result);
                        test_result = "FAILED";
                    end;
                end

            end
        endcase // case (op_set)
    // print coverage after each loop
    // $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
    // if($get_coverage() == 100) break;
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
        sub_op : ret = A - B;
        default: begin
            $display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op_set);
            test_result = "FAILED";
            return -1;
        end
    endcase
    return(ret);
endfunction


endmodule