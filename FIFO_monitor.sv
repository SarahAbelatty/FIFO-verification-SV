import FIFO_transaction_pkg::*;
import FIFO_scoreboard_pkg::*;
import FIFO_coverage_pkg::*;
import FIFO_shared_pkg::*;

module FIFO_monitor (FIFO_if.MONITOR FIFO_IF);
	
	FIFO_transaction trans_obj;
	FIFO_scoreboard score_obj;
	FIFO_coverage cvr_obj;

	initial begin
		// creat an object
		trans_obj = new();
		score_obj = new();
		cvr_obj = new();

		forever begin
			@(negedge FIFO_IF.clk);
			// assign interface inputs to transactions class ports
			trans_obj.rd_en = FIFO_IF.rd_en;
			trans_obj.full = FIFO_IF.full;
			trans_obj.empty = FIFO_IF.empty;
			trans_obj.rst_n = FIFO_IF.rst_n;
			trans_obj.wr_en = FIFO_IF.wr_en;
			trans_obj.wr_ack = FIFO_IF.wr_ack;
			trans_obj.clk = FIFO_IF.clk;
			trans_obj.data_in =FIFO_IF.data_in;
			trans_obj.data_out = FIFO_IF.data_out;
			trans_obj.overflow = FIFO_IF.overflow;
			trans_obj.underflow = FIFO_IF.underflow;
			trans_obj.almostfull = FIFO_IF.almostfull;
			trans_obj.almostempty = FIFO_IF.almostempty;

			fork
				// 1st process
				begin
					cvr_obj.sample_data(trans_obj);
				end
				// 2nd process
				begin
					score_obj.check_data(trans_obj);
				end
			join

			if (test_finished) begin
				$display("FIFo is finished correct_count = %d, error_count = %d",correct_count, error_count);
				$stop;
			end
		end
	end
endmodule 


