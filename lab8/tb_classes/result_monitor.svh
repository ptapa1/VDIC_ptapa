
class result_monitor extends uvm_component;
	`uvm_component_utils(result_monitor)

	
	uvm_analysis_port #(result_transaction) ap;

	function void build_phase(uvm_phase phase);
		alu_agent_config alu_agent_config_h;
        if(!uvm_config_db #(alu_agent_config)::get(this, "","config", alu_agent_config_h))
			`uvm_fatal("RESULT MONITOR", "Failed to get CONFIG")
		alu_agent_config_h.bfm.result_monitor_h = this;
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