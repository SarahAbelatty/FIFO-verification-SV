////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(FIFO_if.DUT FIFO_IF);

logic [FIFO_IF.FIFO_WIDTH-1:0] data_in;
logic clk, rst_n, wr_en, rd_en;
logic [FIFO_IF.FIFO_WIDTH-1:0] data_out; 
logic wr_ack, overflow, underflow;
logic full, empty, almostfull, almostempty;
 
assign data_in = FIFO_IF.data_in;
assign clk = FIFO_IF.clk;
assign FIFO_IF.data_out = data_out;
assign rst_n = FIFO_IF.rst_n;
assign wr_en = FIFO_IF.wr_en;
assign rd_en = FIFO_IF.rd_en;
assign FIFO_IF.wr_ack = wr_ack;
assign FIFO_IF.overflow = overflow;
assign FIFO_IF.underflow = underflow;
assign FIFO_IF.full = full;
assign FIFO_IF.empty = empty;
assign FIFO_IF.almostfull = almostfull;
assign FIFO_IF.almostempty = almostempty;

reg [FIFO_IF.FIFO_WIDTH-1:0] mem [FIFO_IF.FIFO_DEPTH-1:0];

reg [FIFO_IF.max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [FIFO_IF.max_fifo_addr:0] count;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		wr_ptr <= 0;
		// Bug detected: sequential output neaded to be zero when reset asserted 
		wr_ack <= 0;
		// Bug detected: sequential output neaded to be zero when reset asserted 
		overflow <= 0;
	end
	else if (wr_en && count < FIFO_IF.FIFO_DEPTH) begin
		mem[wr_ptr] <= data_in;
		wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end
	else begin 
		wr_ack <= 0; 
		if (full & wr_en)
			overflow <= 1;
		else
			overflow <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rd_ptr <= 0;
		// Bug detected: sequential output neaded to be zero when reset asserted 
		underflow <= 0;
	end
	else if (rd_en && count != 0) begin
		data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
	else begin 
		// Bug detected: sequential output underflow needed to be triggered with clk
		if (empty & rd_en)
			underflow <= 1;
		else
			underflow <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({wr_en, rd_en} == 2'b10) && !full) 
			count <= count + 1;
		else if ( ({wr_en, rd_en} == 2'b01) && !empty)
			count <= count - 1;
		// Bug detected: uncover case for If rd_en && wr_en high & FIFO empty,writing take place 
		else if (({wr_en, rd_en} == 2'b11) && empty)
			count <= count + 1;
		// Bug detected: uncover case for If rd_en && wr_en high & FIFO full,reading take place 
		else if (({wr_en, rd_en} == 2'b11) && full) 
			count <= count - 1;
	end
end

assign full = (count == FIFO_IF.FIFO_DEPTH)? 1 : 0;
assign empty = (count == 0)? 1 : 0;
// Bug detected: almostfull high when fifo has one place empty 
assign almostfull = (count == FIFO_IF.FIFO_DEPTH-1)? 1 : 0; 
assign almostempty = (count == 1)? 1 : 0;

// Generate assertions
`ifdef SIM
	always_comb begin
		if (!rst_n) 
			reset_assertion: assert final ((!wr_ack) && (!overflow) && (!underflow) && (!count) && (!rd_ptr) && (!wr_ptr));
			reset_cover: cover final ((!wr_ack) && (!overflow) && (!underflow) && (!count) && (!rd_ptr) && (!wr_ptr));
	end

	always_comb begin
		if((rst_n)&&(count == FIFO_IF.FIFO_DEPTH))
			full_assertion: assert final (full);
			full_cover: cover final (full);
	end

	always_comb begin
		if((rst_n)&&(count == 0))
			empty_assertion: assert final (empty);
			empty_cover: cover final (empty);
	end

	always_comb begin
		if((rst_n)&&(count == FIFO_IF.FIFO_DEPTH-1))
			almostfull_assertion: assert final (almostfull);
			almostfull_cover: cover final (almostfull);
	end

	always_comb begin
		if((rst_n)&&(count == 1))
		almostempty_assertion: assert final (almostempty);
		almostempty_cover: cover final (almostempty);
	end

	property p1;
		@(posedge clk) disable iff(!rst_n)
		(wr_en && !full) |=> (((wr_ack) && (wr_ptr == $past(wr_ptr)+1)) || ((!wr_ptr) && $past(wr_ptr)+1 == 8));
	endproperty

	property p2;
		@(posedge clk) disable iff(!rst_n)
		(wr_en && full) |=> (overflow);
	endproperty

	property p3;
		@(posedge clk) disable iff(!rst_n)
		(rd_en && !empty) |=> ((rd_ptr == $past(rd_ptr)+1) || ((!rd_ptr) && $past(rd_ptr)+1 == 8));
	endproperty

	property p4;
		@(posedge clk) disable iff(!rst_n)
		(rd_en && empty) |=> (underflow);
	endproperty

	property p5;
		@(posedge clk) disable iff(!rst_n)
		(({wr_en, rd_en} == 2'b10) && !full) |=> (count == $past(count) + 1);
	endproperty

	property p6;
		@(posedge clk) disable iff(!rst_n)
		( ({wr_en, rd_en} == 2'b01) && !empty) |=> (count == $past(count) - 1);
	endproperty

	property p7;
		@(posedge clk) disable iff(!rst_n)
		(({wr_en, rd_en} == 2'b11) && full)  |=> (count == $past(count) - 1);
	endproperty

	property p8;
		@(posedge clk) disable iff(!rst_n)
		(({wr_en, rd_en} == 2'b11) && empty) |=> (count == $past(count) + 1);
	endproperty

	write_assertion: assert property(p1);
	write_cover: cover property(p1);

	overflow_assertion: assert property(p2);
	overflow_cover: cover property(p2);

	read_assertion: assert property(p3);
	read_cover: cover property(p3);

	underflow_assertion: assert property(p4);
	underflow_cover: cover property(p4);

	write_notfull_assertion: assert property(p5);
	write_notfull_cover: cover property(p5);

	read_notempty_assertion: assert property(p6);
	read_notempty_cover: cover property(p6);

	write_read_full_assertion: assert property(p7);
	write_read_full_cover: cover property(p7);

	write_read_empty_assertion: assert property(p8);
	write_read_empty_cover: cover property(p8);

`endif
endmodule

