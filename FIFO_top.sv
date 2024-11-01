module FIFO_top ();
	bit clk;

	// Clock generation 
	initial begin
		clk = 0;
		forever 
			#2 clk = ~clk;
	end

	// Instentiate the interface
	FIFO_if FIFO_IF(clk);
	
	// Instentiate the DUT module
	FIFO DUT(FIFO_IF);

	// Instentiate the TEST module
	FIFO_tb TEST(FIFO_IF);

	// Instentiate the MONITOR module
	FIFO_monitor MONITOR(FIFO_IF);

endmodule 