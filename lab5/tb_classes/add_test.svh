class add_test extends random_test;
	
	`uvm_component_utils(add_test)
	
	add_tester tester_h;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
endclass