
# XM-Sim Command File
# TOOL:	xmsim	19.09-s003
#

set tcl_prompt1 {puts -nonewline "xcelium> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level error
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 0
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
set probe_exclude_patterns {}
set probe_packed_limit 4k
set probe_unpacked_limit 16k
set assert_internal_msg no
set svseed 1
set assert_reporting_mode 0
alias . run
alias quit exit
stop -create -name Randomize -randomize
database -open -shm -into waves.shm waves -default
probe -create -database waves top.bfm.A top.bfm.B top.bfm.C top.bfm.clk top.bfm.command_monitor_h top.bfm.crc top.bfm.crc_out top.bfm.done top.bfm.error_flag top.bfm.error_trig top.bfm.flags top.bfm.op top.bfm.op_err top.bfm.operation top.bfm.out top.bfm.result_monitor_h top.bfm.rst_n top.bfm.send_error_flag_crc top.bfm.send_error_flag_data top.bfm.send_error_flag_op top.bfm.sin top.bfm.sout -all -depth  2
probe -create -database waves top.bfm.command_monitor_h.bfm.clk_gen top.bfm.command_monitor_h.bfm.op_monitor top.bfm.command_monitor_h.bfm.process_command top.bfm.command_monitor_h.bfm.process_data top.bfm.command_monitor_h.bfm.process_error top.bfm.command_monitor_h.bfm.read_data top.bfm.command_monitor_h.bfm.reset_alu top.bfm.command_monitor_h.bfm.result_monitor_thread top.bfm.command_monitor_h.bfm.rst_monitor top.bfm.command_monitor_h.bfm.send_command top.bfm.command_monitor_h.bfm.send_data top.bfm.command_monitor_h.bfm.send_op alu_pkg::command_monitor::type_name
probe -create -database waves top.bfm.command_monitor_h.bfm.clk_gen top.bfm.command_monitor_h.bfm.op_monitor top.bfm.command_monitor_h.bfm.process_command top.bfm.command_monitor_h.bfm.process_data top.bfm.command_monitor_h.bfm.process_error top.bfm.command_monitor_h.bfm.read_data top.bfm.command_monitor_h.bfm.reset_alu top.bfm.command_monitor_h.bfm.result_monitor_thread top.bfm.command_monitor_h.bfm.rst_monitor top.bfm.command_monitor_h.bfm.send_command top.bfm.command_monitor_h.bfm.send_data top.bfm.command_monitor_h.bfm.send_op
probe -create -database waves top.bfm.command_monitor_h.bfm.command_monitor_h.ap top.bfm.command_monitor_h.bfm.command_monitor_h.bfm top.bfm.command_monitor_h.bfm.clk_gen top.bfm.command_monitor_h.bfm.op_monitor top.bfm.command_monitor_h.bfm.process_command top.bfm.command_monitor_h.bfm.process_data top.bfm.command_monitor_h.bfm.process_error top.bfm.command_monitor_h.bfm.read_data top.bfm.command_monitor_h.bfm.reset_alu top.bfm.command_monitor_h.bfm.result_monitor_thread top.bfm.command_monitor_h.bfm.rst_monitor top.bfm.command_monitor_h.bfm.send_command top.bfm.command_monitor_h.bfm.send_data top.bfm.command_monitor_h.bfm.send_op -all -depth  2

simvision -input /home/student/ptapa/VDIC/lab7/.simvision/286080_ptapa__autosave.tcl.svcf
