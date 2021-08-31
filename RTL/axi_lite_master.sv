import axi_lite_pkg::*;

module axi_lite_master#(
	parameter int ADDR = 32'h4
)(
	input logic aclk,
	input logic areset_n,
	axi_lite_if.master m_axi_lite,
	input logic start_read,
	input logic start_write,
	input logic [31:0] write_data,
	input logic [31:0] write_read_address
);

	typedef enum logic [2 : 0] {IDLE, RADDR, RDATA, WADDR, WDATA, WRESP} state_type;
	state_type state, next_state;

	addr_t addr = ADDR;
	data_t data = 32'hdeadbeef, rdata;
	logic start_read_delay, start_write_delay;

	// AR
	assign m_axi_lite.s_axi_araddr  = (state == RADDR) ? write_read_address : 32'h0;
	assign m_axi_lite.s_axi_arvalid = (state == RADDR) ? 1 : 0;

	// R
	assign m_axi_lite.s_axi_rready = (state == RDATA) ? 1 : 0;

	// AW
	assign m_axi_lite.s_axi_awvalid = (state == WADDR) ? 1 : 0;
	assign m_axi_lite.s_axi_awaddr  = (state == WADDR) ? write_read_address : 32'h0;

	// W
	assign m_axi_lite.s_axi_wvalid = (state == WDATA) ? 1 : 0;
	assign m_axi_lite.s_axi_wdata  = (state == WDATA) ? write_data : 32'h0;
	assign m_axi_lite.s_axi_wstrb  = 4'b0000;

	// B
	assign m_axi_lite.s_axi_bready = (state == WRESP) ? 1 : 0;


	always_ff @(posedge aclk) begin
		if (~areset_n) begin
			rdata <= 0;
		end else begin
			if (state == RDATA) rdata <= m_axi_lite.s_axi_rdata;
		end
	end

	always_ff @(posedge aclk) begin
		if (~areset_n) begin
			start_read_delay  <= 0;
			start_write_delay <= 0;
		end else begin
			start_read_delay  <= start_read;
			start_write_delay <= start_write;
		end
	end

	always_comb begin
		case (state)
			IDLE : next_state = (start_read_delay) ? RADDR : ((start_write_delay) ? WADDR : IDLE);
			RADDR : if (m_axi_lite.s_axi_arvalid && m_axi_lite.s_axi_arready) next_state = RDATA;
			RDATA : if (m_axi_lite.s_axi_rvalid  && m_axi_lite.s_axi_rready ) next_state = IDLE;
			WADDR : if (m_axi_lite.s_axi_awvalid && m_axi_lite.s_axi_awready) next_state = WDATA;
			WDATA : if (m_axi_lite.s_axi_wvalid  && m_axi_lite.s_axi_wready ) next_state = WRESP;
			WRESP : if (m_axi_lite.s_axi_bvalid  && m_axi_lite.s_axi_bready ) next_state = IDLE;
			default : next_state = IDLE;
		endcase
	end

	always_ff @(posedge aclk) begin
		if (~areset_n) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end

endmodule // axi_lite_master

