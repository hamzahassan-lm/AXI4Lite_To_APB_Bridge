module axi_apb_bridge
	#( parameter c_apb_num_slaves = 1,
       parameter Base_Address   = 32'h00000000,
       parameter memory_size    = 1024,
    //    parameter integer memory_regions [c_apb_num_slaves-1 : 0][1:0],
       parameter division       = memory_size/c_apb_num_slaves
    )
	( 
    input                         s_axi_clk,
    input                         s_axi_aresetn,
    input                         s_axi_awaddr,
    input                         s_axi_awvalid,
    output                        s_axi_awready,
    input                         s_axi_wdata,
    input                         s_axi_wvalid,
    output                        s_axi_wready,
    output [7:0]                  s_axi_bresp,
    output                        s_axi_bvalid,
    input                         s_axi_bready,
    input                         s_axi_araddr,
    input                         s_axi_arvalid,
    output                        s_axi_arready,
    output [7:0]                  s_axi_rresp,
    output                        s_axi_rvalid,
    output                        s_axi_rdata,
    input                         s_axi_rready,
    // input                         m_apb_pclk,
    // input                         m_apb_presetn,
    output [31:0]                 m_apb_paddr,
    output [2:0]                  m_apb_pprot,
    output [c_apb_num_slaves-1:0] m_apb_psel,
    output                        m_apb_penable,
    output                        m_apb_pwrite,
    output [31:0]                 m_apb_pwdata,
    output [3:0]                  m_apb_pstrb,
    input  [c_apb_num_slaves-1:0] m_apb_pready,
    // input  [31:0]                 m_apb_prdata [c_apb_num_slaves-1:0],
    input  [31:0]                 m_apb_prdata,
    input  [31:0]                 m_apb_prdata2,
    input  [31:0]                 m_apb_prdata3,
    input  [31:0]                 m_apb_prdata4,
    input  [31:0]                 m_apb_prdata5,
    input  [31:0]                 m_apb_prdata6,
    input  [31:0]                 m_apb_prdata7,
    input  [31:0]                 m_apb_prdata8,
    input  [31:0]                 m_apb_prdata9,
    input  [31:0]                 m_apb_prdata10,
    input  [31:0]                 m_apb_prdata11,
    input  [31:0]                 m_apb_prdata12,
    input  [31:0]                 m_apb_prdata13,
    input  [31:0]                 m_apb_prdata14,
    input  [31:0]                 m_apb_prdata15,
    input  [31:0]                 m_apb_prdata16,
    input                         m_apb_pslverr
);


parameter [31:0] memory_regions [c_apb_num_slaves-1: 0] [1:0] = '{'{1,2},'{1,2},'{1,2}};

localparam Idle   = 'd 0;
localparam Setup  = 'd 1;
localparam Access = 'd 2;

reg  [31:0]                 captured_addr; 
reg  [31:0]                 m_apb_pwdata;
reg                         reg_pwrite;
reg  [31:0]                 reg_m_apb_pwdata;
reg  [31:0]                 reg_m_apb_prdata;
reg                         reg_axi_bvalid;
reg                         reg_axi_rvalid;
reg  [7:0]                  reg_s_axi_bresp;
reg  [7:0]                  reg_s_axi_rresp;

wire [1:0]                  state;
wire                        SWRT;
wire [c_apb_num_slaves-1:0] SSEL;
wire                        SWDATA;
wire                        SRDATA;
reg  [31:0]                 sel_m_apb_prdata;

apb_master UUT (s_axi_clk, s_axi_aresetn, STREQ, SWRT, SSEL, SADDR, SWDATA, SRDATA, m_apb_paddr, m_apb_pprot, m_apb_psel,
                m_apb_penable, m_apb_pwrite, m_apb_pwdata, m_apb_pstrb, m_apb_pready, m_apb_prdata, m_apb_pslverr, state);

always @(posedge s_axi_clk or negedge s_axi_aresetn) begin
	if(!s_axi_aresetn) begin
		reg_axi_bvalid  <= 0;
		reg_axi_rvalid  <= 0;
		reg_s_axi_bresp <= 0;
		reg_s_axi_rresp <= 0;
	end
	else if((state == Access)&& (m_apb_pready)) begin
		reg_axi_bvalid   <= reg_pwrite  ? 1 : 0;
		reg_axi_rvalid   <= m_apb_pwrite  ? 0 : 1;
		reg_s_axi_bresp  <= m_apb_pslverr ?  m_apb_pwrite ? 2 : 0 : 0;
		reg_s_axi_rresp  <= m_apb_pslverr ? !m_apb_pwrite ? 2 : 0 : 0;
	end
	else begin
		reg_axi_bvalid  <= 0;
		reg_axi_rvalid  <= 0;
		reg_s_axi_bresp <= 0;
		reg_s_axi_rresp <= 0;
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
assign STREQ         = (state==Access) && m_apb_pready && reg_pwrite ? 0 : s_axi_arvalid || s_axi_awvalid ? 1 : 0;
assign SWRT          = reg_pwrite;

/*
genvar i ;
generate
	for(i=1;i<=c_apb_num_slaves;i=i+1) begin
    		assign SSEL[i-1] = (Base_Address+(i)*division)<=captured_addr ? (Base_Address+(i+1)*division)>captured_addr ?
		1'b1 :1'b0 : 1'b0;
  	end
endgenerate
*/
genvar i ;
generate
	for(i=1;i<=c_apb_num_slaves;i=i+1) begin
    		assign SSEL[i-1] = memory_regions[i][0] <=captured_addr ? memory_regions[i][1]>=captured_addr ?
		1'b1 :1'b0 : 1'b0;
  	end
endgenerate

//assign SSEL          = (state == Access) || (state == Setup) ? 1 : 0;
assign SWDATA        = reg_m_apb_pwdata;

// always@* begin
// 	case(m_apb_psel)  
//       		16'h0001  : sel_m_apb_prdata = m_apb_prdata;       // If sel=0, output can be a  
//       		16'h0002  : sel_m_apb_prdata = m_apb_prdata2;       // If sel=0, output can be a
//       		16'h0004  : sel_m_apb_prdata = m_apb_prdata3;       // If sel=0, output can be a  
//       		16'h0008  : sel_m_apb_prdata = m_apb_prdata4;       // If sel=0, output can be a
//       		16'h0010  : sel_m_apb_prdata = m_apb_prdata5;       // If sel=0, output can be a  
//       		16'h0020  : sel_m_apb_prdata = m_apb_prdata6;       // If sel=0, output can be a
//       		16'h0040  : sel_m_apb_prdata = m_apb_prdata7;       // If sel=0, output can be a  
//       		16'h0080  : sel_m_apb_prdata = m_apb_prdata8;       // If sel=0, output can be a
//       		16'h0100  : sel_m_apb_prdata = m_apb_prdata9;       // If sel=0, output can be a  
//       		16'h0200  : sel_m_apb_prdata = m_apb_prdata10;       // If sel=0, output can be a
//       		16'h0400  : sel_m_apb_prdata = m_apb_prdata11;       // If sel=0, output can be a  
//       		16'h0800  : sel_m_apb_prdata = m_apb_prdata12;       // If sel=0, output can be a
//       		16'h1000  : sel_m_apb_prdata = m_apb_prdata13;       // If sel=0, output can be a  
//       		16'h2000  : sel_m_apb_prdata = m_apb_prdata14;       // If sel=0, output can be a
//       		16'h4000  : sel_m_apb_prdata = m_apb_prdata15;       // If sel=0, output can be a  
//       		16'h8000  : sel_m_apb_prdata = m_apb_prdata16;       // If sel=0, output can be a   
//       		default  : sel_m_apb_prdata = 0;       // If sel is something, out is commonly zero  
// 	endcase
// end

assign sel_m_apb_prdata = (m_apb_psel == 16'h0001) & m_apb_prdata   |
                          (m_apb_psel == 16'h0002) & m_apb_prdata2  |
                          (m_apb_psel == 16'h0004) & m_apb_prdata3  |
                          (m_apb_psel == 16'h0008) & m_apb_prdata4  |
                          (m_apb_psel == 16'h0010) & m_apb_prdata5  |
                          (m_apb_psel == 16'h0020) & m_apb_prdata6  |
                          (m_apb_psel == 16'h0040) & m_apb_prdata7  |
                          (m_apb_psel == 16'h0080) & m_apb_prdata8  |
                          (m_apb_psel == 16'h0100) & m_apb_prdata9  |
                          (m_apb_psel == 16'h0200) & m_apb_prdata10 |
                          (m_apb_psel == 16'h0400) & m_apb_prdata11 |
                          (m_apb_psel == 16'h0800) & m_apb_prdata12 |
                          (m_apb_psel == 16'h1000) & m_apb_prdata13 |
                          (m_apb_psel == 16'h2000) & m_apb_prdata14 |
                          (m_apb_psel == 16'h4000) & m_apb_prdata15 |
                          (m_apb_psel == 16'h8000) & m_apb_prdata16;

endmodule
