package FIFO_scoreboard_pkg;
	import FIFO_transaction_pkg::*;
	import FIFO_shared_pkg::*;
	FIFO_transaction F_score_txn = new();
	
	class FIFO_scoreboard;

		logic [F_score_txn.FIFO_WIDTH-1:0] fifo_ref [$];
		integer fifo_count = 0;

		logic [F_score_txn.FIFO_WIDTH-1:0] data_out_ref; 
		logic wr_ack_ref, overflow_ref, underflow_ref;
		logic full_ref, empty_ref, almostfull_ref, almostempty_ref;

		function void check_data(input FIFO_transaction F_txn1);
			reference_model(F_txn1);
			if (F_txn1.data_out != data_out_ref) begin
				$display("ERROR!! unmatched output, data_out = 0x%0h, data_out_ref = 0x%0h", F_txn1.data_out, data_out_ref);
				error_count++;
			end
			else begin
				$display("SUCCESS, data_out = 0x%0h, data_out_ref = 0x%0h", F_txn1.data_out, data_out_ref);
				correct_count++;
			end
			endfunction 

		function void reference_model(input FIFO_transaction F_txn2);
			if (!F_txn2.rst_n) begin
				fifo_ref <= {};
				fifo_count = 0;
			end
			else begin
				if (F_txn2.wr_en && fifo_count < F_txn2.FIFO_DEPTH) begin
					fifo_ref.push_back(F_txn2.data_in);
					fifo_count <= fifo_ref.size();
				end 

				if (F_txn2.rd_en && fifo_count != 0) begin
					data_out_ref <= fifo_ref.pop_front();
					fifo_count <= fifo_ref.size();
				end 
			end
		endfunction 
	endclass 
endpackage 


