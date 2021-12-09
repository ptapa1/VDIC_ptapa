
class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

    uvm_analysis_port #(alu_input) ap;

    function void build_phase(uvm_phase phase);
        virtual alu_bfm bfm;

        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1, "Failed to get BFM");

        bfm.command_monitor_h = this;

        ap = new("ap",this);

    endfunction : build_phase

    function void write_to_monitor(alu_input cmd);
        ap.write(cmd);
    endfunction : write_to_monitor

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

endclass : command_monitor

