class random_test extends uvm_test;
	`uvm_component_utils(random_test)
	
    env env_h;
	
	function void build_phase(uvm_phase phase);
		env_h = env::type_id::create("env_h",this);
		base_tester::type_id::set_type_override(random_tester::get_type());
	endfunction 
	
	function new(string name, uvm_component parent);
		super.new(name,parent);
	endfunction
	
	 function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        this.print(); // print test environment topology
    endfunction : end_of_elaboration_phase
	
endclass