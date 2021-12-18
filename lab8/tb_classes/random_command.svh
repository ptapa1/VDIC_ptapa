
class random_command extends uvm_transaction;
    `uvm_object_utils(random_command)


		rand bit [31:0] A,B;
		rand operation_t operation;
		bit [3:0] crc;
		bit send_error_flag_data,send_error_flag_crc,send_error_flag_op;
		rand bit [1:0] error_trig;
		rand no_ops op_err;
		bit [3:0] flags;
		error_flags error_flag;


	constraint data {
        A dist {32'h00000000:=10, [32'h00000001 : 32'hFFFFFFFE]:/1, 32'hFFFFFFFF:=10};
        B dist {32'h00000000:=10, [32'h00000001 : 32'hFFFFFFFE]:/1, 32'hFFFFFFFF:=10};
    }
    function new (string name = "");
        super.new(name);
    endfunction : new
    
    extern function void do_copy(uvm_object rhs);
    extern function random_command clone_me();
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();

endclass : random_command

    function void random_command::do_copy(uvm_object rhs);
        random_command copied_transaction_h;

        if(rhs == null)
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

        super.do_copy(rhs); // copy all parent class data

        if(!$cast(copied_transaction_h,rhs))
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

        A  = copied_transaction_h.A;
        B  = copied_transaction_h.B;
        operation = copied_transaction_h.operation;
        crc = copied_transaction_h.crc;
        send_error_flag_data = copied_transaction_h.send_error_flag_data;
        send_error_flag_crc = copied_transaction_h.send_error_flag_crc;
        send_error_flag_op = copied_transaction_h.send_error_flag_op;
        error_trig = copied_transaction_h.error_trig;
        op_err = copied_transaction_h.op_err;
        flags = copied_transaction_h.flags;
        error_flag = copied_transaction_h.error_flag;

    endfunction : do_copy


    function random_command random_command::clone_me(); //TODO Possible mistake
        
        random_command clone;
        uvm_object tmp;

        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
        
    endfunction : clone_me


    function bit random_command::do_compare(uvm_object rhs, uvm_comparer comparer);
        
        random_command compared_transaction_h;
        bit same;

        if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
                "Tried to do comparison to a null pointer");

        if (!$cast(compared_transaction_h,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            (compared_transaction_h.A == A) &&
            (compared_transaction_h.B == B) &&
            (compared_transaction_h.operation == operation) &&
            (compared_transaction_h.crc == crc) &&
            (compared_transaction_h.send_error_flag_data == send_error_flag_data) &&
            (compared_transaction_h.send_error_flag_crc == send_error_flag_crc) &&
            (compared_transaction_h.send_error_flag_op == send_error_flag_op) &&
            (compared_transaction_h.error_trig == error_trig) &&
            (compared_transaction_h.op_err == op_err) &&
            (compared_transaction_h.flags == flags) &&
            (compared_transaction_h.error_flag == error_flag);

        return same;
        
    endfunction : do_compare


    function string random_command::convert2string();
        string s;
		 s = $sformatf("A: %8h  B: %8h  op: %s crc: %b \
			data error flag: %b crc error flag: %b op error flag: %b \
			error triggered?: %b op error: %s", A, B, operation.name(), crc, send_error_flag_data, send_error_flag_crc, 
            send_error_flag_op, error_trig, op_err.name());
        return s;
    endfunction : convert2string


    


