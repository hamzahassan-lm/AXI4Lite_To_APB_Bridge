module axi_apb_bridge
	( 
	  s_axi_clk,s_axi_aresetn,
	  s_axi_awaddr,s_axi_awvalid,s_axi_awready,s_axi_wdata,s_axi_wvalid,s_axi_wready,
	  s_axi_bresp,s_axi_bvalid,s_axi_bready,
	  s_axi_araddr,s_axi_arvalid,s_axi_arready,
	  s_axi_rresp,s_axi_rvalid,s_axi_rdata,s_axi_rready,

	  m_apb_paddr,m_apb_pwrite,m_apb_psel,m_apb_penable,
	  m_apb_pwdata,m_apb_prdata,m_apb_pready,m_apb_pslverr,
	  m_apb_prdata2,m_apb_prdata3,m_apb_prdata4,m_apb_prdata5,m_apb_prdata6,m_apb_prdata7,
	  m_apb_prdata8,m_apb_prdata9,m_apb_prdata10,m_apb_prdata11,m_apb_prdata12,m_apb_prdata13,
	  m_apb_prdata14,m_apb_prdata15,m_apb_prdata16,
          m_apb_pstrb,m_apb_pprot,
	);
parameter c_apb_num_slaves = 1;


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
output[c_apb_num_slaves:0] m_apb_psel;
output m_apb_penable;
output m_apb_pwrite;
output[31:0] m_apb_pwdata;
output[3:0] m_apb_pstrb;

input[c_apb_num_slaves:0] m_apb_pready;
input[31:0] m_apb_prdata;
input[31:0] m_apb_prdata2;
input[31:0] m_apb_prdata3;
input[31:0] m_apb_prdata4;
input[31:0] m_apb_prdata5;
input[31:0] m_apb_prdata6;
input[31:0] m_apb_prdata7;
input[31:0] m_apb_prdata8;
input[31:0] m_apb_prdata9;
input[31:0] m_apb_prdata10;
input[31:0] m_apb_prdata11;
input[31:0] m_apb_prdata12;
input[31:0] m_apb_prdata13;
input[31:0] m_apb_prdata14;
input[31:0] m_apb_prdata15;
input[31:0] m_apb_prdata16;


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
reg[31:0] sel_m_apb_prdata;

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
		//reg_m_apb_prdata<= 0;
	end
	else if((state == Access)&& (m_apb_pready)) begin
		reg_axi_bvalid   <= m_apb_pwrite  ? 1 : 0;
		reg_axi_rvalid   <= m_apb_pwrite  ? 0 : 1;
		reg_s_axi_bresp  <= m_apb_pslverr ?  m_apb_pwrite ? 2 : 0 : 0;
		reg_s_axi_rresp  <= m_apb_pslverr ? !m_apb_pwrite ? 2 : 0 : 0;
		//reg_m_apb_prdata <= sel_m_apb_prdata;
	end
	else begin
		
		reg_axi_bvalid  <= 0;
		reg_axi_rvalid  <= 0;
		reg_s_axi_bresp <= 0;
		reg_s_axi_rresp <= 0;
		//reg_m_apb_prdata<= 0;
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
assign s_axi_rdata   = sel_m_apb_prdata;

assign SADDR         = captured_addr; 
assign STREQ         = s_axi_arvalid||s_axi_awvalid ? 1 : 0;
assign SWRT          = reg_pwrite;
assign SSEL          = (state == Access) || (state == Setup) ? 1 : 0;
assign SWDATA        = reg_m_apb_pwdata;

always@* begin
	case(m_apb_psel)  
      		4'b0000  : sel_m_apb_prdata = m_apb_prdata;       // If sel=0, output can be a  
      		4'b0001  : sel_m_apb_prdata = m_apb_prdata2;       // If sel=0, output can be a
      		4'b0010  : sel_m_apb_prdata = m_apb_prdata3;       // If sel=0, output can be a  
      		4'b0011  : sel_m_apb_prdata = m_apb_prdata4;       // If sel=0, output can be a
      		4'b0100  : sel_m_apb_prdata = m_apb_prdata5;       // If sel=0, output can be a  
      		4'b0101  : sel_m_apb_prdata = m_apb_prdata6;       // If sel=0, output can be a
      		4'b0110  : sel_m_apb_prdata = m_apb_prdata7;       // If sel=0, output can be a  
      		4'b0111  : sel_m_apb_prdata = m_apb_prdata8;       // If sel=0, output can be a
      		4'b1000  : sel_m_apb_prdata = m_apb_prdata9;       // If sel=0, output can be a  
      		4'b1001  : sel_m_apb_prdata = m_apb_prdata10;       // If sel=0, output can be a
      		4'b1010  : sel_m_apb_prdata = m_apb_prdata11;       // If sel=0, output can be a  
      		4'b1011  : sel_m_apb_prdata = m_apb_prdata12;       // If sel=0, output can be a
      		4'b1100  : sel_m_apb_prdata = m_apb_prdata13;       // If sel=0, output can be a  
      		4'b1101  : sel_m_apb_prdata = m_apb_prdata14;       // If sel=0, output can be a
      		4'b1110  : sel_m_apb_prdata = m_apb_prdata15;       // If sel=0, output can be a  
      		4'b1111  : sel_m_apb_prdata = m_apb_prdata16;       // If sel=0, output can be a   
      		default  : sel_m_apb_prdata = 0;       // If sel is something, out is commonly zero  
	endcase
end

endmodule