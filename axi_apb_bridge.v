module axi_apb_bridge
	#(parameter c_apb_num_slaves = 1,
	  parameter Base_Address   = 32'h00000000,
	  parameter memory_size    = 1024,
	//   parameter integer memory_regions[c_apb_num_slaves-1 : 0][1:0],
	  parameter timeout_val       = 10,
      parameter division       = memory_size/c_apb_num_slaves)
	(
      input                         s_axi_clk,
      input                         s_axi_aresetn,
      input                         s_axi_awaddr,
      input                         s_axi_awvalid,
      output                        s_axi_awready,
      input                         s_axi_wdata,
      input                         s_axi_wvalid,
      output                        s_axi_wready,
      output [1:0]                  s_axi_bresp,
      output                        s_axi_bvalid,
      input                         s_axi_bready,
      input                         s_axi_araddr,
      input                         s_axi_arvalid,
      output                        s_axi_arready,
      output [1:0]                  s_axi_rresp,
      output                        s_axi_rvalid,
      output                        s_axi_rdata,
      input                         s_axi_rready,
    //   input                         m_apb_pclk,
    //   input                         m_apb_presetn,
      output [31:0]                 m_apb_paddr,
      output [2:0]                  m_apb_pprot,
      output [c_apb_num_slaves-1:0] m_apb_psel,
      output                        m_apb_penable,
      output                        m_apb_pwrite,
      output [31:0]                 m_apb_pwdata,
      output [3:0]                  m_apb_pstrb,
      
      input [c_apb_num_slaves-1:0]  m_apb_pready,
    //   input [31:0]                  m_apb_prdata [c_apb_num_slaves-1:0];
      
      input [31:0]                  m_apb_prdata,
      input [31:0]                  m_apb_prdata2,
      input [31:0]                  m_apb_prdata3,
      input [31:0]                  m_apb_prdata4,
      input [31:0]                  m_apb_prdata5,
      input [31:0]                  m_apb_prdata6,
      input [31:0]                  m_apb_prdata7,
      input [31:0]                  m_apb_prdata8,
      input [31:0]                  m_apb_prdata9,
      input [31:0]                  m_apb_prdata10,
      input [31:0]                  m_apb_prdata11,
      input [31:0]                  m_apb_prdata12,
      input [31:0]                  m_apb_prdata13,
      input [31:0]                  m_apb_prdata14,
      input [31:0]                  m_apb_prdata15,
      input [31:0]                  m_apb_prdata16,
      input                         m_apb_pslverr
	);


parameter [31:0] memory_regions[c_apb_num_slaves-1: 0][1:0] = '{'{1,2},'{1,2},'{1,2}};

localparam Idle   = 'd 0;
localparam Setup  = 'd 1;
localparam Access = 'd 2;

reg [31:0]                  captured_addr; 
reg [31:0]                  m_apb_pwdata;
reg                         reg_pwrite;
reg [31:0]                  reg_m_apb_pwdata;
reg [31:0]                  reg_m_apb_prdata;
reg                         reg_axi_bvalid;
reg                         reg_axi_rvalid;
reg [1:0]                   reg_s_axi_bresp;
reg [1:0]                   reg_s_axi_rresp;

wire                        apb_reset;
wire [1:0]                  state;
wire                        SWRT;
wire [c_apb_num_slaves-1:0] SSEL;
wire                        SWDATA;
wire                        SRDATA;
wire [31:0]                 sel_m_apb_prdata;
reg  [31:0]                 timeout_counter;
wire [31:0]                 timeout_counter_nxt;

apb_master UUT (s_axi_clk, apb_reset, STREQ, SWRT, SSEL,SADDR,SWDATA,SRDATA, m_apb_paddr, m_apb_pprot, m_apb_psel, m_apb_penable,
                m_apb_pwrite, m_apb_pwdata, m_apb_pstrb, m_apb_pready, m_apb_prdata, m_apb_pslverr, m_apb_prdata2, m_apb_prdata3,
                m_apb_prdata4, m_apb_prdata5, m_apb_prdata6, m_apb_prdata7, m_apb_prdata8, m_apb_prdata9, m_apb_prdata10,
                m_apb_prdata11, m_apb_prdata12, m_apb_prdata13, m_apb_prdata14, m_apb_prdata15, m_apb_prdata16, state);


always@(posedge s_axi_clk or negedge s_axi_aresetn) begin
	if(!s_axi_aresetn) begin
		reg_axi_bvalid  <= 0;
		reg_axi_rvalid  <= 0;
		reg_s_axi_bresp <= 0;
		reg_s_axi_rresp <= 0; 
		
	end
	else if((state == Access)&& (m_apb_pready)) begin
		reg_axi_bvalid      <= reg_pwrite  ? 1 : 0;
		reg_axi_rvalid      <= m_apb_pwrite  ? 0 : 1;
		reg_s_axi_bresp  <= m_apb_pslverr ?  m_apb_pwrite ? 2'b10 : 0 : 0;
		reg_s_axi_rresp  <= m_apb_pslverr ? !m_apb_pwrite ? 2'b10 : 0 : 0;
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
	if(!s_axi_aresetn)
		timeout_counter <= timeout_val;
	else if(timeout_counter^32'h00000000) 
		timeout_counter <= timeout_counter;
	else if((state == Access) && !m_apb_pready) 
		timeout_counter <= timeout_counter - 1;
	else if((state == Access) && m_apb_pready)
		timeout_counter <= timeout_val;
	else if((state == Idle))
		timeout_counter <= timeout_val;
	else if((state == Setup))
		timeout_counter <= timeout_val-1;
	else 
		timeout_counter <= timeout_counter;
end

 

assign s_axi_arready    = (state==Setup)?s_axi_arvalid?1:0:0;
assign s_axi_awready    = (state==Setup)?s_axi_arvalid?0:s_axi_awvalid?1:0:0;
assign s_axi_wready     = (state==Setup)? s_axi_wvalid ? 1:0:0; 
assign s_axi_rdata      = (state == Access) && timeout_counter^32'h00000000 ? 32'h00000000 : sel_m_apb_prdata;
assign s_axi_bresp      = (state == Access) && timeout_counter^32'h00000000 ? 2'b10 : reg_s_axi_bresp;
assign s_axi_rresp      = (state == Access) && timeout_counter^32'h00000000 ? 2'b10 : reg_s_axi_rresp; 

assign SADDR            = captured_addr; 
assign STREQ            = (state==Access) && m_apb_pready && reg_pwrite ? 0 : s_axi_arvalid || s_axi_awvalid ? 1 : 0;
assign SWRT             = reg_pwrite;
assign SWDATA           = reg_m_apb_pwdata;

assign apb_reset        = (state == Access) && timeout_counter^32'h00000000 ? 0 : s_axi_aresetn;

genvar i ;
generate
	for(i=1;i<=c_apb_num_slaves;i=i+1) begin
    		assign SSEL[i-1] = (memory_regions[i][0] <=captured_addr) & (memory_regions[i][1]>=captured_addr);
  	end
endgenerate

assign sel_m_apb_prdata = {32{(m_apb_psel == 16'h0001)}} & m_apb_prdata   |
                          {32{(m_apb_psel == 16'h0002)}} & m_apb_prdata2  |
                          {32{(m_apb_psel == 16'h0004)}} & m_apb_prdata3  |
                          {32{(m_apb_psel == 16'h0008)}} & m_apb_prdata4  |
                          {32{(m_apb_psel == 16'h0010)}} & m_apb_prdata5  |
                          {32{(m_apb_psel == 16'h0020)}} & m_apb_prdata6  |
                          {32{(m_apb_psel == 16'h0040)}} & m_apb_prdata7  |
                          {32{(m_apb_psel == 16'h0080)}} & m_apb_prdata8  |
                          {32{(m_apb_psel == 16'h0100)}} & m_apb_prdata9  |
                          {32{(m_apb_psel == 16'h0200)}} & m_apb_prdata10 |
                          {32{(m_apb_psel == 16'h0400)}} & m_apb_prdata11 |
                          {32{(m_apb_psel == 16'h0800)}} & m_apb_prdata12 |
                          {32{(m_apb_psel == 16'h1000)}} & m_apb_prdata13 |
                          {32{(m_apb_psel == 16'h2000)}} & m_apb_prdata14 |
                          {32{(m_apb_psel == 16'h4000)}} & m_apb_prdata15 |
                          {32{(m_apb_psel == 16'h8000)}} & m_apb_prdata16;

endmodule
