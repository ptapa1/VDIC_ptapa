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
		sub_op                   = 3'b101} operation_t;

	typedef enum bit[2:0] {no_op1 = 3'b010,
		no_op2                    = 3'b011,
		no_op3                   = 3'b110,
		no_op4                   = 3'b111} no_ops;
	
	typedef struct packed {
        bit [31:0] A;
        bit [31:0] B;
        //bit [31:0] C;
		bit [3:0] crc; 
		bit [3:0] flags;
		bit [1:0] error_trig;
		bit send_error_flag_data,send_error_flag_crc,send_error_flag_op;
		error_flags error_flag;
		operation_t operation;
		no_ops op_err;} alu_input;
	
	typedef struct packed {
        bit [31:0] C; 
		bit [54:0] read;
		bit [3:0] flags;
		error_flags error_flag;} alu_output;
	
	`include "command_monitor.svh"
	`include "result_monitor.svh"
	`include "driver.svh"
	
	`include "coverage.svh"
	`include "base_tester.svh"
	`include "scoreboard.svh"
	`include "random_tester.svh"
	`include "add_tester.svh"
	`include "env.svh"
	`include "random_test.svh"
	`include "add_test.svh"
	`include "ff_00_tester.svh"
	`include "ff_00_test.svh"
	
	
endpackage : alu_pkg
