import axi_lite_pkg::*;

interface axi_lite_if;

	// Read Address Channel
	addr_t s_axi_araddr;
	wire s_axi_arvalid;
	wire s_axi_arready;

	// Read Data Channel
	data_t s_axi_rdata;
	resp_t s_axi_rresp;
	wire s_axi_rvalid;
	wire s_axi_rready;

	// Write Address Channel
	addr_t s_axi_awaddr;
	wire s_axi_awvalid;
	wire s_axi_awready;

	// Write Data Channel
	data_t s_axi_wdata;
	strb_t s_axi_wstrb;
	wire s_axi_wvalid;
	wire s_axi_wready;

	// Write Response Channel
	resp_t s_axi_bresp;
	wire s_axi_bvalid;
	wire s_axi_bready;
	
	wire [2:0] s_axi_arprot;
	wire [2:0] s_axi_awprot;

	modport master (
		output s_axi_araddr, s_axi_arvalid, input s_axi_arready,
		input s_axi_rdata, s_axi_rresp, s_axi_rvalid, output s_axi_rready,
		output s_axi_awaddr, s_axi_awvalid, input s_axi_awready,
		output 	s_axi_wdata, s_axi_wstrb, s_axi_wvalid, input s_axi_wready,
		input s_axi_bresp, s_axi_bvalid, output s_axi_bready,
		output s_axi_arprot,s_axi_awprot
	);

	modport slave (
		
		/*input s_axi_araddr, s_axi_arvalid,*/output s_axi_arready
		/*
		output s_axi_rdata, s_axi_rresp, s_axi_rvalid, input s_axi_rready,
		input s_axi_awaddr, s_axi_awvalid, output s_axi_awready,
		input s_axi_wdata, s_axi_wstrb, s_axi_wvalid, output s_axi_wready,
		output s_axi_bresp, s_axi_bvalid, input s_axi_bready
		*/
	);
  

endinterface
