class testbench;
	virtual alu_bfm bfm;
	
	protected tester tester_h;
	protected coverage coverage_h;
	protected scoreboard scoreboard_h;
	
	function new (virtual alu_bfm b);
		bfm = b;
	endfunction

	task execute();
		tester_h = new(bfm);
		coverage_h = new(bfm);
		scoreboard_h = new(bfm);
		fork
			tester_h.execute();
			coverage_h.execute();
			scoreboard_h.execute();
		join_none
	endtask


endclass