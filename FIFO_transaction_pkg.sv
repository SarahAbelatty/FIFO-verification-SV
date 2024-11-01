package FIFO_transaction_pkg;
	class FIFO_transaction;
		// Parameters
		localparam FIFO_WIDTH = 16;
		localparam FIFO_DEPTH = 8;

		// Randomize input signals
		rand logic [FIFO_WIDTH-1:0] data_in;
		rand logic clk, rst_n, wr_en, rd_en;

		// output ports
		logic [FIFO_WIDTH-1:0] data_out; 
		logic wr_ack, overflow, underflow;
		logic full, empty, almostfull, almostempty;

		// Added dignals
		integer RD_EN_ON_DIST, WR_EN_ON_DIST;

		// constructor override the values of RD_EN_ON_DIST and WR_EN_ON_DIST
		function new(integer RD_EN_ON_DIST = 30, integer WR_EN_ON_DIST = 70);
			this.RD_EN_ON_DIST = RD_EN_ON_DIST;
			this.WR_EN_ON_DIST = WR_EN_ON_DIST;
		endfunction 

		//  Constraint to assert reset less often
		constraint reset {
			rst_n dist {0:=5, 1:=95};
		}

		// Constraint the wr_en to be high with distribution of the value WR_EN_ON_DIST 
		constraint Write_enable {
			wr_en dist {1:/WR_EN_ON_DIST, 0:/(100-WR_EN_ON_DIST)};
		}

		// Constraint the rd_en to be high with distribution of the value RD_EN_ON_DIST 
		constraint Read_enable {
			rd_en dist {1:/RD_EN_ON_DIST, 0:/(100-RD_EN_ON_DIST)};
		}
	endclass 
endpackage