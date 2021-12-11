class minmax extends random_test;
	
	`uvm_component_utils(minmax)
	
	 function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tester::type_id::set_type_override(minmax::get_type());
    endfunction : build_phase
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
endclass