class result_transaction extends uvm_transaction;
	
	bit [31:0] C;
	
	function new(string name = "");
		super.new(name);
	endfunction : new
	
	extern function void do_copy(uvm_object rhs);
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();
	
endclass : result_transaction

	 function void result_transaction::do_copy(uvm_object rhs);
		result_transaction copied_transaction_h;
        assert(rhs != null) else
            `uvm_fatal("RESULT TRANSACTION","Tried to copy null transaction");
        super.do_copy(rhs);
        assert($cast(copied_transaction_h,rhs)) else
            `uvm_fatal("RESULT TRANSACTION","Failed cast in do_copy");
        C = copied_transaction_h.C;
	endfunction : do_copy
	
	function string result_transaction::convert2string();
		string s;
        s = $sformatf("result: %8h",C);
        return s;
	endfunction : convert2string
	
	function bit result_transaction::do_compare(uvm_object rhs, uvm_comparer comparer);
		result_transaction RHS;
        bit same;
        assert(rhs != null) else
            `uvm_fatal("RESULT TRANSACTION","Tried to compare null transaction");

        same = super.do_compare(rhs, comparer);

        $cast(RHS, rhs);
        same = (C == RHS.C) && same;
        return same;
	endfunction : do_compare

