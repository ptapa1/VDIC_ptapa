
class result_monitor extends uvm_component;
	`uvm_component_utils(result_monitor)

	virtual alu_bfm bfm;
	uvm_analysis_port #(result_transaction) ap;

	//function void write_to_monitor(bit [31:0] C, bit [2:0] crc_out, bit [3:0] flags, error_flags error_flag);


	function void build_phase(uvm_phase phase);

		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
			`uvm_fatal("RESULT MONITOR", "Failed to get BFM")
		bfm.result_monitor_h = this;
		ap = new("ap",this);
	endfunction : build_phase

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void write_to_monitor(bit [31:0] C);
		result_transaction result_t;
		result_t = new("result_t");
		result_t.C = C;
		ap.write(result_t);
	endfunction : write_to_monitor

endclass : result_monitor