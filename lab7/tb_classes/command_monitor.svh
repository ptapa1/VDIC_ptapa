
class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

	virtual alu_bfm bfm;
	uvm_analysis_port #(command_transaction) ap;
	
	function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("COMMAND MONITOR", "Failed to get BFM")   
        bfm.command_monitor_h = this;
        ap = new("ap",this);
    endfunction : build_phase

    function void write_to_monitor(bit [31:0] A, bit [31:0] B, bit [2:0] operation, 
	    bit [3:0] crc, bit send_error_flag_data, bit send_error_flag_crc, 
	    bit send_error_flag_op, bit [1:0] error_trig, no_ops op_err, bit [3:0] flags, error_flags error_flag);
	    
	    command_transaction cmd;
	    
	    `uvm_info("COMMAND MONITOR",$sformatf("MONITOR: A: %8h  B: %8h  op: %s crc: %s \
					data error flag: %s crc error flag: %s op error flag: %s \
					error triggered?: %s op error: %s",
                A, B, operation, crc, send_error_flag_data, send_error_flag_crc, 
                send_error_flag_op, error_trig, op_err), UVM_HIGH);
	    
	    cmd    = new("cmd");
        cmd.A  = A;
        cmd.B  = B;
        cmd.operation = operation;
	    cmd.crc = crc;
	    cmd.send_error_flag_data = send_error_flag_data;
	    cmd.send_error_flag_crc = send_error_flag_crc;
	    cmd.send_error_flag_op = send_error_flag_op;
	    cmd.error_trig = error_trig;
	    cmd.op_err = op_err;
        ap.write(cmd);
    endfunction : write_to_monitor

    

endclass : command_monitor

