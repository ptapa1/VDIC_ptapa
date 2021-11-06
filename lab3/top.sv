module top;
	alu_bfm bfm();

	coverage 	cov(bfm);
	tester 		test(bfm);
	scoreboard 	score(bfm);

	mtm_Alu DUT(
		.clk(bfm.clk),
		.rst_n(bfm.rst_n),
		.sin(bfm.sin),
		.sout(bfm.sout)
		); 



endmodule :top
