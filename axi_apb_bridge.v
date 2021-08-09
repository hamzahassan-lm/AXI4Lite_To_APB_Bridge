module axi_apb_bridge
	( 
	  s_axi_clk,s_axi_aresetn,
	  s_axi_awaddr,s_axi_awvalid,s_axi_awready,s_axi_wdata,s_axi_wvalid,s_axi_wready,
	  s_axi_bresp,s_axi_bvalid,s_axi_bready,
	  s_axi_araddr,s_axi_arvalid,s_axi_arready,
	  s_axi_rresp,s_axi_rvalid,s_axi_rdata,s_axi_rready,

	  m_apb_paddr,m_apb_pwrite,m_apb_psel,m_apb_penable,
	  m_apb_pwdata,m_apb_prdata,m_apb_pready,m_apb_pslverr,
          m_apb_pstrb,m_apb_pprot,
	);

parameter Idle   = 'd 0;
parameter Setup  = 'd 1;
parameter Access = 'd 2;

input s_axi_clk;
input s_axi_aresetn;
input s_axi_awaddr;
input s_axi_awvalid;
output s_axi_awready;
input s_axi_wdata;
input s_axi_wvalid;
output s_axi_wready;
output[7:0] s_axi_bresp;
output s_axi_bvalid;
input s_axi_bready;
input s_axi_araddr;
input s_axi_arvalid;
output s_axi_arready;
output[7:0] s_axi_rresp;
output s_axi_rvalid;
output s_axi_rdata;
input s_axi_rready;
//input m_apb_pclk;
//input m_apb_presetn;
output[31:0] m_apb_paddr;
output[2:0] m_apb_pprot;
output m_apb_psel;
output m_apb_penable;
output m_apb_pwrite;
output[31:0] m_apb_pwdata;
output[3:0] m_apb_pstrb;

input m_apb_prdata;
input m_apb_pready;
input m_apb_pslverr;

reg[31:0] captured_addr; 
reg[31:0] m_apb_pwdata;
reg       reg_pwrite;
reg[31:0] reg_m_apb_pwdata;
reg[31:0] reg_m_apb_prdata;
reg reg_axi_bvalid;
reg reg_axi_rvalid;
reg[7:0] reg_s_axi_bresp;
reg[7:0] reg_s_axi_rresp;

wire[1:0] state;
wire SWRT;
wire SSEL;
wire SWDATA;
wire SRDATA;

    apb_master UUT (s_axi_clk ,  s_axi_aresetn, STREQ, SWRT, SSEL,SADDR,SWDATA,SRDATA,
		    m_apb_paddr,  m_apb_pprot  , m_apb_psel, m_apb_penable,m_apb_pwrite,m_apb_pwdata,m_apb_pstrb,
		    m_apb_pready, m_apb_prdata, m_apb_pslverr,
		    state);


always@(posedge s_axi_clk or negedge s_axi_aresetn) begin
	if(!s_axi_aresetn) begin
		reg_axi_bvalid  <= 0;
		reg_axi_rvalid  <= 0;
		reg_s_axi_bresp <= 0;
		reg_s_axi_rresp <= 0;
		reg_m_apb_prdata<= 0;
	end
	else if((state == Access)&& (m_apb_pready)) begin
		reg_axi_bvalid   <= m_apb_pwrite  ? 1 : 0;
		reg_axi_rvalid   <= m_apb_pwrite  ? 0 : 1;
		reg_s_axi_bresp  <= m_apb_pslverr ?  m_apb_pwrite ? 2 : 0 : 0;
		reg_s_axi_rresp  <= m_apb_pslverr ? !m_apb_pwrite ? 2 : 0 : 0;
		reg_m_apb_prdata <= m_apb_prdata;
	end
	else begin
		
		reg_axi_bvalid  <= 0;
		reg_axi_rvalid  <= 0;
		reg_s_axi_bresp <= 0;
		reg_s_axi_rresp <= 0;
		reg_m_apb_prdata<= 0;
	end
	if(!s_axi_aresetn) begin
 		captured_addr     <= 0;
 		reg_m_apb_pwdata  <= 0;
 		reg_pwrite        <= 0;
	end
	else if ((state == Access)||(state == Idle))begin
 		captured_addr     <= s_axi_arvalid?s_axi_araddr:s_axi_awvalid?s_axi_awaddr:0;
 		reg_m_apb_pwdata  <= s_axi_arvalid?0:s_axi_wdata?1:0;
 		reg_pwrite        <= s_axi_arvalid?0:s_axi_awvalid?1:0;
	end
	else begin
 		captured_addr     <= captured_addr;
 		reg_m_apb_pwdata  <= reg_m_apb_pwdata;
 		reg_pwrite        <= reg_pwrite;
	end

end


assign s_axi_arready = (state==Setup)?s_axi_arvalid?1:0:0;
assign s_axi_awready = (state==Setup)?s_axi_arvalid?0:s_axi_awvalid?1:0:0;
assign s_axi_wready  = (state==Setup)? s_axi_wvalid ? 1:0:0; 
assign s_axi_rdata   = reg_m_apb_prdata;

assign SADDR         = captured_addr; 
assign STREQ         = s_axi_arvalid||s_axi_awvalid ? 1 : 0;
assign SWRT          = reg_pwrite;
assign SSEL          = (state == Access) || (state == Setup) ? 1 : 0;
assign SWDATA        = reg_m_apb_pwdata;


endmodule