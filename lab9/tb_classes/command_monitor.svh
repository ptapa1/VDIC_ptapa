
class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

	local virtual alu_bfm bfm;
	uvm_analysis_port #(sequence_item) ap;
	
	function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("COMMAND MONITOR", "Failed to get BFM")   
        //bfm.command_monitor_h = this;
        ap = new("ap",this);
    endfunction : build_phase
    
    function void connect_phase(uvm_phase phase);
        bfm.command_monitor_h = this;
    endfunction : connect_phase

    function void write_to_monitor(bit [31:0] A, bit [31:0] B, bit [2:0] operation, 
	    bit [3:0] crc, bit send_error_flag_data, bit send_error_flag_crc, 
	    bit send_error_flag_op, bit [1:0] error_trig, no_ops op_err, bit [3:0] flags, error_flags error_flag);
	    
	    sequence_item cmd;
	    
	    `uvm_info("COMMAND MONITOR",$sformatf("MONITOR: A: %8h \n B: %8h \n op: %h \ncrc: %h \
					\ndata error flag: %h \ncrc error flag: %h \nop error flag: %h \
					\nerror triggered?: %h \nop error: %h \n error_flag: %h",
                A, B, operation, crc, send_error_flag_data, send_error_flag_crc, 
                send_error_flag_op, error_trig, op_err, error_flag), UVM_HIGH);
	    
	    cmd    = new("cmd");
        cmd.A  = A;
        cmd.B  = B;
        cmd.operation = operation_t'(operation);
	    cmd.crc = crc;
	    cmd.send_error_flag_data = send_error_flag_data;
	    cmd.send_error_flag_crc = send_error_flag_crc;
	    cmd.send_error_flag_op = send_error_flag_op;
	    cmd.error_trig = error_trig;
	    cmd.op_err = op_err;
	    cmd.flags = flags;
	    cmd.error_flag = error_flag;
        ap.write(cmd);
    endfunction : write_to_monitor

    

endclass : command_monitor

