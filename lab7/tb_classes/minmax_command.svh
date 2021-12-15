
class minmax_command extends random_command;
	
	`uvm_object_utils(minmax_command)
	
	constraint data {
        A dist {32'h00000000:=1, 32'hFFFFFFFF:=1};
        B dist {32'h00000000:=1, 32'hFFFFFFFF:=1};
    }
	
	function new(string name="");
		super.new(name);
	endfunction
	
endclass 