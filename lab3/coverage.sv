
module coverage(alu_bfm bfm);
	import alu_pkg::*;

	bit                  [31:0] A;
	bit                  [31:0] B;
	bit					 [3:0] flags;
	operation_t                operation;
	error_flags                error_flag;



//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

	covergroup op_cov;

		option.name = "cg_op_cov";

		coverpoint operation {

			bins A1_all_ops[] = {[and_op : sub_op]};

		}

	endgroup

	covergroup zeros_or_ones_on_ops;

		option.name = "cg_zeros_or_ones_on_ops";

		all_ops : coverpoint operation {
		}

		a_leg: coverpoint A {
			bins zeros = {'h00000000};
			bins others= {['h01:'hFFFFFFFE]};
			bins ones  = {'hFFFFFFFF};
		}

		b_leg: coverpoint B {
			bins zeros = {'h00000000};
			bins others= {['h01:'hFFFFFFFE]};
			bins ones  = {'hFFFFFFFF};
		}

		B_op_00_FF: cross a_leg, b_leg, all_ops {

			bins A2_zeros_add_00          = binsof (all_ops) intersect {add_op} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins A2_zeros_and_00          = binsof (all_ops) intersect {and_op} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins A2_zeros_or_00          = binsof (all_ops) intersect {or_op} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins A2_zeros_sub_00          = binsof (all_ops) intersect {sub_op} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins A2_ones_add_FF          = binsof (all_ops) intersect {add_op} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins A2_ones_and_FF          = binsof (all_ops) intersect {and_op} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins A2_ones_or_FF          = binsof (all_ops) intersect {or_op} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins A2_ones_sub_FF          = binsof (all_ops) intersect {sub_op} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));


			ignore_bins others_only =
			binsof(a_leg.others) && binsof(b_leg.others);
		}

	endgroup

	covergroup output_flags;

		option.name = "cg_output_flags";

		coverpoint flags {
			bins A3_flag_carry = {'h8};
			bins A3_flag_overflow= {'h4};
			bins A3_flag_zero  = {'h2};
			bins A3_flag_negative  = {'h1};
		}

	endgroup

	covergroup err_flags;

		option.name = "cg_error_flags";

		coverpoint error_flag {
			bins A4_err_flag_data = {'h24};
			bins A4_err_flag_crc= {'h12};
			bins A4_err_flag_op  = {'h9};
		}

	endgroup

	op_cov                      oc;
	zeros_or_ones_on_ops        c_00_FF;
	output_flags                out_flags;
	err_flags                   flags_errors;

	initial begin : coverage
		oc      = new();
		c_00_FF = new();
		out_flags = new();
		flags_errors = new();
		forever begin : sample_cov
			@(posedge bfm.clk);
			A      = bfm.A;
			B      = bfm.B;
			operation = bfm.operation;
			flags = bfm.flags;
			error_flag = bfm.error_flag;
			oc.sample();
			c_00_FF.sample();
			out_flags.sample();
			flags_errors.sample();
		end
	end : coverage


endmodule : coverage