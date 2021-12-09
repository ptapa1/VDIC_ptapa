class add_test extends random_test;
	
	`uvm_component_utils(add_test)
	
	env env_h;
	
	function void build_phase(uvm_phase phase);
        env_h = env::type_id::create("env_h",this);
        random_tester::type_id::set_type_override(add_tester::get_type());
	endfunction : build_phase
	
	function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

    
	
endclass