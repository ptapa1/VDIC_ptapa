
class sequence_item extends uvm_sequence_item;

//------------------------------------------------------------------------------
// sequence item variables
//------------------------------------------------------------------------------

    rand bit [31:0] A;
    rand bit [31:0] B;
    rand operation_t operation;
    bit [31:0] result;
	rand bit [1:0] error_trig;
	rand no_ops op_err;
	bit [3:0] crc;
	bit send_error_flag_data,send_error_flag_crc,send_error_flag_op;
	bit [3:0] flags;
	error_flags error_flag;

//------------------------------------------------------------------------------
// Macros providing copy, compare, pack, record, print functions.
// Individual functions can be enabled/disabled with the last
// `uvm_field_*() macro argument.
// Note: this is an expanded version of the `uvm_object_utils with additional
//       fields added. DVT has a dedicated editor for this (ctrl-space).
//------------------------------------------------------------------------------

    `uvm_object_utils_begin(sequence_item)
        `uvm_field_int(A, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(B, UVM_ALL_ON | UVM_DEC)
        `uvm_field_enum(operation_t, operation, UVM_ALL_ON)
        `uvm_field_enum(no_ops, op_err, UVM_ALL_ON)
        `uvm_field_int(result, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(error_trig, UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint op_con {operation dist { add_op := 5, and_op:=5,
            or_op:=5,sub_op:=5, rst_op:=1};}
    
    constraint no_op_con {op_err dist { no_op1 := 1, no_op2:=1,
            no_op3:=1};}
    
    constraint data {
        A dist {[32'h00000001 : 32'hFFFFFFFE]:=1};
        B dist {[32'h00000001 : 32'hFFFFFFFE]:=1};
    }

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "sequence_item");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// convert2string 
//------------------------------------------------------------------------------

    function string convert2string();
        return {super.convert2string(),
            $sformatf("A: %8h  B: %8h   op: %s = %8h", A, B, operation.name(), result)
        };
    endfunction : convert2string

endclass : sequence_item