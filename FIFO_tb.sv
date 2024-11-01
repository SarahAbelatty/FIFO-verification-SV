import FIFO_transaction_pkg::*;
import FIFO_scoreboard_pkg::*;
import FIFO_coverage_pkg::*;
import FIFO_shared_pkg::*;

module FIFO_tb (FIFO_if.TEST FIFO_IF);
	
	FIFO_transaction trans_obj_test = new();

	initial begin
		// initialize data and test reset
		FIFO_IF.rst_n = 1; FIFO_IF.rd_en = 0;
		FIFO_IF.wr_en = 0; FIFO_IF.data_in = 0;
		@(negedge FIFO_IF.clk);
		FIFO_IF.rst_n = 0;
		@(negedge FIFO_IF.clk);
		FIFO_IF.rst_n = 1;
		@(negedge FIFO_IF.clk);

		repeat(10000) begin
			assert(trans_obj_test.randomize());
			FIFO_IF.rst_n = trans_obj_test.rst_n;
			FIFO_IF.rd_en = trans_obj_test.rd_en;
			FIFO_IF.wr_en = trans_obj_test.wr_en; 
			FIFO_IF.data_in = trans_obj_test.data_in;
			@(negedge FIFO_IF.clk);
		end

		test_finished = 1;
	end
endmodule