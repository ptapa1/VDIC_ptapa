class env extends uvm_env;

	`uvm_component_utils(env)

	sequencer sequencer_h;
	//tester tester_h;
	driver driver_h;
	//uvm_tlm_fifo #(random_command) command_f;
	coverage coverage_h;
	scoreboard scoreboard_h;
	command_monitor command_monitor_h;
	result_monitor result_monitor_h;
	
	function new (string name, uvm_component parent);
		super.new(name,parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		
		sequencer_h = sequencer::type_id::create("sequencer_h",this);
        driver_h = driver::type_id::create("driver_h",this);
		
		coverage_h = coverage::type_id::create ("coverage_h",this);
		scoreboard_h = scoreboard::type_id::create("scoreboard_h",this);
		
		command_monitor_h = command_monitor::type_id::create("command_monitor_h",this);
		result_monitor_h = result_monitor::type_id::create("result_monitor_h",this);
	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
		//tester_h.command_port.connect(command_f.put_export);
		command_monitor_h.ap.connect(coverage_h.analysis_export);
		command_monitor_h.ap.connect(scoreboard_h.cmd_f.analysis_export);
		result_monitor_h.ap.connect(scoreboard_h.analysis_export);
		
	endfunction : connect_phase

endclass