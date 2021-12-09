class ff_00_test extends random_test;
	
	`uvm_component_utils(ff_00_test)
	
	 function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        random_tester::type_id::set_type_override(ff_00_tester::get_type());
    endfunction : build_phase
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
endclass