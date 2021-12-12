
class command_transaction extends uvm_transaction;
    `uvm_object_utils(command_transaction)

//    rand byte unsigned A;
//    rand byte unsigned B;
//    rand operation_t op;

		rand bit [31:0] A,B;
		rand operation_t operation;
		bit [3:0] crc;
		bit send_error_flag_data,send_error_flag_crc,send_error_flag_op;
		bit [1:0] error_trig;
		no_ops op_err;
		//bit [31:0] C;
		bit [3:0] flags;
		bit [2:0] crc_out;
		error_flags error_flag;

    constraint data {
        A dist {32'h00000000:=1, [32'h00000001 : 32'hFFFFFFFE]:=1, 32'hFFFFFFFF:=1};
        B dist {32'h00000000:=1, [32'h00000001 : 32'hFFFFFFFE]:=1, 32'hFFFFFFFF:=1};
    }

    function void do_copy(uvm_object rhs);
        command_transaction copied_transaction_h;

        if(rhs == null)
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

        super.do_copy(rhs); // copy all parent class data

        if(!$cast(copied_transaction_h,rhs))
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

        A  = copied_transaction_h.A;
        B  = copied_transaction_h.B;
        //C  = copied_transaction_h.C;
        operation = copied_transaction_h.operation;
        crc = copied_transaction_h.crc;
        send_error_flag_data = copied_transaction_h.send_error_flag_data;
        send_error_flag_crc = copied_transaction_h.send_error_flag_crc;
        send_error_flag_op = copied_transaction_h.send_error_flag_op;
        error_trig = copied_transaction_h.error_trig;
        op_err = copied_transaction_h.op_err;
        flags = copied_transaction_h.flags;
       // crc_out = copied_transaction_h.crc_out;
        error_flag = copied_transaction_h.error_flag;

    endfunction : do_copy


    function command_transaction clone_me();
        
        command_transaction clone;
        uvm_object tmp;

        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
        
    endfunction : clone_me


    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        
        command_transaction compared_transaction_h;
        bit same;

        if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
                "Tried to do comparison to a null pointer");

        if (!$cast(compared_transaction_h,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            (compared_transaction_h.A == A) &&
            (compared_transaction_h.B == B) &&
            //(compared_transaction_h.C == C) &&
            (compared_transaction_h.operation == operation) &&
            (compared_transaction_h.crc == crc) &&
            (compared_transaction_h.send_error_flag_data == send_error_flag_data) &&
            (compared_transaction_h.send_error_flag_crc == send_error_flag_crc) &&
            (compared_transaction_h.send_error_flag_op == send_error_flag_op) &&
            (compared_transaction_h.error_trig == error_trig) &&
            (compared_transaction_h.op_err == op_err) &&
            (compared_transaction_h.flags == flags) &&
            //(compared_transaction_h.crc_out == crc_out) &&
            (compared_transaction_h.error_flag == error_flag);

        return same;
        
    endfunction : do_compare


    function string convert2string();
        string s;
       // s = $sformatf("A: %8h  B: %8h  op: %s crc: %s \
		//	data error flag: %s crc error flag: %s op error flag: %s \
		//	error triggered?: %s op error: %s", A, B, operation, crc, send_error_flag_data,
		//	send_error_flag_crc, send_error_flag_op, error_trig, op_err);
		 s = $sformatf("A: %32h  B: %32h  op: %b crc: %b \
			data error flag: %b crc error flag: %b op error flag: %b \
			error triggered?: %b op error: %b", A, B, operation, crc, send_error_flag_data, send_error_flag_crc, 
            send_error_flag_op, error_trig, op_err);
        return s;
    endfunction : convert2string


    function new (string name = "");
        super.new(name);
    endfunction : new

endclass : command_transaction
