
class random_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(random_sequence)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

// not necessary, req is inherited
//    sequence_item req;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "random_sequence");
        super.new(name);
    endfunction : new





//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------

    task body();
        `uvm_info("SEQ_RANDOM","",UVM_MEDIUM)

//       req = sequence_item::type_id::create("req");
		`uvm_do_with(req, {operation == rst_op;})
        `uvm_create(req);

        repeat (1000) begin : random_loop
//         start_item(req);
//         assert(req.randomize());
//         finish_item(req);
            `uvm_rand_send(req)
            
        end : random_loop
    endtask : body


endclass : random_sequence