
class minmax_sequence extends uvm_sequence #(sequence_item);
	
	`uvm_object_utils(minmax_sequence)
	
	
	function new(string name="minmax_sequence");
		super.new(name);
	endfunction
	
	task body();
        `uvm_info("SEQ_MINMAX","",UVM_MEDIUM)
        
        `uvm_do_with(req, {operation == rst_op;})
        
        repeat (1000) begin
            `uvm_do_with(req,{ A dist {32'h00000000:=1, 32'hFFFFFFFF:=1}; B dist {32'h00000000:=1, 32'hFFFFFFFF:=1};});
        end
    endtask
	
endclass 