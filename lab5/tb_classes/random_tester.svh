
class random_tester extends base_tester;
	
	`uvm_component_utils(random_tester)
	
	virtual alu_bfm bfm;
	
	function new (string name,uvm_component parent);
		super.new(name, parent);
	endfunction
//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions

	function operation_t get_op();
		bit [2:0] op_choice;
		op_choice = $random;
		case (op_choice)
			3'b000 : return and_op;
			3'b001 : return or_op;
			3'b100 : return add_op;
			3'b101 : return sub_op;
		endcase // case (op_choice)
	endfunction : get_op


//---------------------------------
	function bit [31:0] get_data();
		bit [1:0] zero_ones;
		zero_ones = 2'($random);
		if (zero_ones == 2'b00)
			return 32'h00000000;
		else if (zero_ones == 2'b11)
			return 32'hFFFFFFFF;
		else
			return 32'($random);
	endfunction : get_data


endclass