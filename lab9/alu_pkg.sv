//`timescale 1ns/1ps

package alu_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	typedef enum bit[5:0] {err_data = 6'b100100,
		err_crc                    = 6'b010010,
		err_op                   = 6'b001001} error_flags;

	typedef enum bit[2:0] {and_op = 3'b000,
		or_op                    = 3'b001,
		add_op                   = 3'b100,
		sub_op                   = 3'b101,
		rst_op					 = 3'b111} operation_t;

	typedef enum bit[2:0] {no_op1 = 3'b010,
		no_op2                    = 3'b011,
		no_op3                   = 3'b110} no_ops;
	
	
    typedef enum {
        COLOR_BOLD_BLACK_ON_GREEN,
        COLOR_BOLD_BLACK_ON_RED,
        COLOR_BOLD_BLACK_ON_YELLOW,
        COLOR_BOLD_BLUE_ON_WHITE,
        COLOR_BLUE_ON_WHITE,
        COLOR_DEFAULT
    } print_color;
	
	 function void set_print_color ( print_color c );
        string ctl;
        case(c)
            COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
            COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
            COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
            COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
            COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
            COLOR_DEFAULT : ctl              = "\033\[0m\n";
            default : begin
                $error("set_print_color: bad argument");
                ctl                          = "";
            end
        endcase
        $write(ctl);
    endfunction
	
	`include "sequence_item.svh"
	//`include "minmax_sequence_item.svh"
	`include "result_transaction.svh"
	`include "random_sequence.svh"
	`include "minmax_sequence.svh"
	
	`include "sequencer.svh"
	//`include "runall_sequence.svh"
	
	//`include "random_command.svh"
	//`include "minmax_command.svh"
	
	
	`include "driver.svh"
	`include "coverage.svh"
	
	`include "scoreboard.svh"
	`include "command_monitor.svh"
	`include "result_monitor.svh"
	`include "env.svh"
	`include "alu_base_test.svh"
	`include "random_test.svh"
	`include "minmax_test.svh"
	
	
	//`include "tester.svh"
	
	
	//`include "random_test.svh"
	//`include "minmax_test.svh"
endpackage : alu_pkg
