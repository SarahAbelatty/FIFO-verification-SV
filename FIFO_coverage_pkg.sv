package FIFO_coverage_pkg;
	import FIFO_transaction_pkg::*;
	class FIFO_coverage;
		FIFO_transaction F_cvg_txn = new();

		// Covergroup
		covergroup fifo_cvr;
			// Cover points
			full_cp: coverpoint F_cvg_txn.full;
			empty_cp: coverpoint F_cvg_txn.empty;
			wr_en_cp: coverpoint F_cvg_txn.wr_en;
			rd_en_cp: coverpoint F_cvg_txn.rd_en;
			wr_ack_cp: coverpoint F_cvg_txn.wr_ack;
			overflow_cp: coverpoint F_cvg_txn.overflow;
			underflow_cp: coverpoint F_cvg_txn.underflow;
			almostfull_cp: coverpoint F_cvg_txn.almostfull;
			almostempty_cp: coverpoint F_cvg_txn.almostempty;

			// Crosses
			cross wr_en_cp, rd_en_cp, full_cp{
				ignore_bins Write1_Read1_Full = binsof(wr_en_cp) intersect{1} && binsof(rd_en_cp) intersect{1} 
				&& binsof(full_cp) intersect{1};

				ignore_bins Write0_Read1_Full = binsof(wr_en_cp) intersect{0} && binsof(rd_en_cp) intersect{1} 
				&& binsof(full_cp) intersect{1};
			}
			cross wr_en_cp, rd_en_cp, overflow_cp {
				ignore_bins Write0_Read1_Overflow = binsof(wr_en_cp) intersect{0} && binsof(rd_en_cp) intersect{1} 
				&& binsof(overflow_cp) intersect{1};

				ignore_bins Write0_Read0_Overflow = binsof(wr_en_cp) intersect{0} && binsof(rd_en_cp) intersect{0} 
				&& binsof(overflow_cp) intersect{1};
			}
			cross wr_en_cp, rd_en_cp, underflow_cp {
				ignore_bins Write1_Read0_Underflow = binsof(wr_en_cp) intersect{1} && binsof(rd_en_cp) intersect{0} 
				&& binsof(underflow_cp) intersect{1};

				ignore_bins Write0_Read0_Underflow = binsof(wr_en_cp) intersect{0} && binsof(rd_en_cp) intersect{0} 
				&& binsof(underflow_cp) intersect{1};
			}
			cross wr_en_cp, rd_en_cp, wr_ack_cp {
				ignore_bins Write0_Read1_wrack = binsof(wr_en_cp) intersect{0} && binsof(rd_en_cp) intersect{1} 
				&& binsof(wr_ack_cp) intersect{1};

				ignore_bins Write0_Read0_wrack = binsof(wr_en_cp) intersect{0} && binsof(rd_en_cp) intersect{0} 
				&& binsof(wr_ack_cp) intersect{1};
			}
			cross wr_en_cp, rd_en_cp, empty_cp;
			cross wr_en_cp, rd_en_cp, almostempty_cp;
			cross wr_en_cp, rd_en_cp, almostfull_cp;
		endgroup 

		// Sample data
		function void sample_data(input FIFO_transaction F_txn);
			F_cvg_txn = F_txn;
			fifo_cvr.sample();
		endfunction 

		function new();
			fifo_cvr = new();
		endfunction 
	endclass
endpackage 