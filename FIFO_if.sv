interface FIFO_if (clk);
	// Parameters
	parameter FIFO_WIDTH = 16;
	parameter FIFO_DEPTH = 8;

	// Local Parameters
	localparam max_fifo_addr = $clog2(FIFO_DEPTH);

	// SIGNALS (inputs & outputs)
	input clk;
	logic [FIFO_WIDTH-1:0] data_in;
	logic rst_n, wr_en, rd_en;
	logic [FIFO_WIDTH-1:0] data_out; 
	logic wr_ack, overflow, underflow;
	logic full, empty, almostfull, almostempty;

	// Modport for DUT module(Design)
	modport DUT (input data_in, rst_n, wr_en, rd_en, clk,
	output data_out, wr_ack, overflow, underflow, full, empty, almostfull, almostempty);

	// Modport for testbench module
	modport TEST (output data_in, rst_n, wr_en, rd_en, 
	input data_out, wr_ack, overflow, underflow, full, empty, almostfull, almostempty, clk);

	// Modport for monitor module
	modport MONITOR (input data_in, rst_n, wr_en, rd_en, data_out, wr_ack, clk,
	overflow, underflow, full, empty, almostfull, almostempty);
endinterface 


