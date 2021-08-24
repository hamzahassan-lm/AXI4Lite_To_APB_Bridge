//import axi_lite_pkg::*;
module axi_apb_bridge
	#(parameter c_apb_num_slaves = 1,
	  parameter Base_Address   = 32'h00000000,
	  parameter memory_size    = 1024,
	  parameter integer  memory_regions1 [c_apb_num_slaves-1 : 0] = {32'h00000000},
	  parameter integer  memory_regions2 [c_apb_num_slaves-1 : 0] = {32'h00000040},
	  parameter timeout_val       = 10,
      parameter division       = memory_size/c_apb_num_slaves)
	(

      input                         s_axi_clk,
      input                         s_axi_aresetn,

      input [31:0]                  s_axi_awaddr,
      input                         s_axi_awvalid,
      output                        s_axi_awready,
      input  [31:0]                 s_axi_wdata,
      input                         s_axi_wvalid,
      input  [3:0]                  s_axi_wstrb,
      output                        s_axi_wready,
      output [1:0]                  s_axi_bresp,
      output                        s_axi_bvalid,
      input                         s_axi_bready,
      input  [31:0]                 s_axi_araddr,
      input                         s_axi_arvalid,
      output                        s_axi_arready,
      output [1:0]                  s_axi_rresp,
      output                        s_axi_rvalid,
      output [31:0]                 s_axi_rdata,
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
      input [c_apb_num_slaves-1:0]  m_apb_pslverr
	);


// parameter [31:0] memory_regions[c_apb_num_slaves-1: 0][1:0] = '{'{1,2}};

localparam Idle   = 'd 0;
localparam Setup  = 'd 1;
localparam Access = 'd 2;


reg  [31:0]                 captured_addr; 
// reg [31:0]                  m_apb_pwdata;
reg                         reg_pwrite;
reg  [31:0]                 reg_m_apb_pwdata;
reg  [31:0]                 reg_m_apb_prdata;
reg                         reg_axi_bvalid;
reg                         reg_axi_rvalid;
reg  [1:0]                  reg_s_axi_bresp;
reg  [1:0]                  reg_s_axi_rresp;
reg  [31:0]                 timeout_counter;
wire                        apb_reset;
wire [1:0]                  state;
wire                        SWRT;
wire [c_apb_num_slaves-1:0] SSEL;
wire [31:0]                 SWDATA;
wire [31:0]                 SRDATA;
wire [31:0]                 sel_m_apb_prdata;

wire [31:0]                 SADDR;
wire [31:0]                 captured_addr_ns;
wire                        reg_pwrite_ns;
wire [31:0]                 reg_m_apb_pwdata_ns;
wire                        reg_axi_bvalid_ns, reg_axi_rvalid_ns;
wire [1:0]                  reg_s_axi_bresp_ns, reg_s_axi_rresp_ns;


/*
apb_master UUT (s_axi_clk, apb_reset, STREQ, SWRT, SSEL,SADDR,SWDATA,SRDATA, m_apb_paddr, m_apb_pprot, m_apb_psel, m_apb_penable,
                m_apb_pwrite, m_apb_pwdata, m_apb_pstrb, m_apb_pready, m_apb_prdata, m_apb_pslverr, m_apb_prdata2, m_apb_prdata3,
                m_apb_prdata4, m_apb_prdata5, m_apb_prdata6, m_apb_prdata7, m_apb_prdata8, m_apb_prdata9, m_apb_prdata10,
                m_apb_prdata11, m_apb_prdata12, m_apb_prdata13, m_apb_prdata14, m_apb_prdata15, m_apb_prdata16, state);

assign reg_axi_bvalid_ns  = (state == Access)&& (|m_apb_pready) ? (reg_pwrite  ? 1'b1 : 1'b0) : 1'b0;
assign reg_axi_rvalid_ns  = (state == Access)&& (|m_apb_pready) ? (m_apb_pwrite  ? 1'b0 : 1'b1) : 1'b0;
assign reg_s_axi_bresp_ns = (state == Access)&& (|m_apb_pready) ? (m_apb_pslverr ?  (m_apb_pwrite ? 2'b10 : 2'b0) : 2'b0) : 2'b0;
assign reg_s_axi_rresp_ns = (state == Access)&& (|m_apb_pready) ? (m_apb_pslverr ? (!m_apb_pwrite ? 2'b10 : 2'b0) : 2'b0) : 2'b0;

flop #(1) reg_axi_bvalid_ff  (.clk(s_axi_clk), .rst(s_axi_aresetn), .d(reg_axi_bvalid_ns), .q(reg_axi_bvalid));
flop #(1) reg_axi_rvalid_ff  (.clk(s_axi_clk), .rst(s_axi_aresetn), .d(reg_axi_rvalid_ns), .q(reg_axi_rvalid));
flop #(2) reg_s_axi_bresp_ff (.clk(s_axi_clk), .rst(s_axi_aresetn), .d(reg_s_axi_bresp_ns), .q(reg_s_axi_bresp));
flop #(2) reg_s_axi_rresp_ff (.clk(s_axi_clk), .rst(s_axi_aresetn), .d(reg_s_axi_rresp_ns), .q(reg_s_axi_rresp));

assign captured_addr_ns    = ((state == Access)||(state == Idle)) ? (s_axi_arvalid ? s_axi_araddr : (s_axi_awvalid ? s_axi_awaddr : 32'b0)) : captured_addr;
assign reg_m_apb_pwdata_ns = ((state == Access)||(state == Idle)) ? (s_axi_arvalid ? 32'b0 : (s_axi_wdata ? 32'b1 : 32'b0)) : reg_m_apb_pwdata;
assign reg_pwrite_ns       = ((state == Access)||(state == Idle)) ? (s_axi_arvalid ? 32'b0 : (s_axi_awvalid ? 32'b1 : 32'b0)) : reg_pwrite;

flop #(32) captured_addr_ff    (.clk(s_axi_clk), .rst(s_axi_aresetn), .d(captured_addr_ns), .q(captured_addr));
flop #(32) reg_m_apb_pwdata_ff (.clk(s_axi_clk), .rst(s_axi_aresetn), .d(reg_m_apb_pwdata_ns), .q(reg_m_apb_pwdata));
flop #(1)  reg_pwrite_ff       (.clk(s_axi_clk), .rst(s_axi_aresetn), .d(reg_pwrite_ns), .q(reg_pwrite));

always@(posedge s_axi_clk or negedge s_axi_aresetn) begin
	if(!s_axi_aresetn)
		timeout_counter <= timeout_val;
	else if(timeout_counter == 32'h00000000) 
		timeout_counter <= timeout_counter;
	else if((state == Access) && !|m_apb_pready) 
		timeout_counter <= timeout_counter - 1;
	else if((state == Access) && |m_apb_pready)
		timeout_counter <= timeout_val;
	else if((state == Idle))
		timeout_counter <= timeout_val;
	else if((state == Setup))
		timeout_counter <= timeout_val-1;
	else 
		timeout_counter <= timeout_counter;
end


assign s_axi_arready    = (state==Setup) ? s_axi_arvalid ? 1 : 0 : 0;
assign s_axi_awready    = (state==Setup) ? (s_axi_arvalid ? 0 : (s_axi_awvalid ? 1 : 0)) : 0;
assign s_axi_wready     = (state==Setup) ?  s_axi_wvalid ? 1 : 0 : 0; 
assign s_axi_rdata      = (state == Access) && (timeout_counter == 32'h00000000) ? 32'h00000000 : sel_m_apb_prdata;
assign s_axi_bresp      = (state == Access) && (timeout_counter == 32'h00000000) ? 2'b10 : reg_s_axi_bresp;
assign s_axi_rresp      = (state == Access) && (timeout_counter == 32'h00000000) ? 2'b10 : reg_s_axi_rresp; 
assign s_axi_bvalid     = reg_axi_bvalid;
assign s_axi_rvalid     = reg_axi_rvalid;

wire rready = s_axi_rready;
wire [1:0] strb = s_axi_wstrb;
wire bready = s_axi_bready;

	

assign SADDR            = captured_addr; 
assign STREQ            = (state==Access) && |m_apb_pready && reg_pwrite ? 0 : s_axi_arvalid || s_axi_awvalid ? 1 : 0;
assign SWRT             = reg_pwrite;
assign SWDATA           = reg_m_apb_pwdata;

assign apb_reset        = (state == Access) && timeout_counter^32'h00000000 ? 0 : s_axi_aresetn;

*/

genvar i;
generate
	for(i=0;i<c_apb_num_slaves;i=i+1) begin
    		assign SSEL[i] = ((state == Access)|(state == Setup)) & (captured_addr >= memory_regions1[i]) ?  ((state == Access)|(state == Setup)) & (captured_addr <= memory_regions2[i]) ? 1'b1 : 1'b0 : 1'b0;
		//assign SSEL[i] = (captured_addr >= memory_regions1[i]) ? 1'b1 : 1'b0;
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


reg[31:0] axi_write_data_reg;
reg       write_happened;
reg[2:0]  bridge_state;
reg       write_req_reg;
reg       read_valid_reg;
reg       write_resp_valid_reg;
reg[31:0] read_data_reg;
reg[31:0] captured_addr;
reg[1:0]  read_resp ;
reg[1:0]  write_resp;

wire      apb_transfer_req;

      input [31:0]                  s_axi_awaddr,
      input                         s_axi_awvalid,
      output                        s_axi_awready,
      input  [31:0]                 s_axi_wdata,
      input                         s_axi_wvalid,


wire condition1_state_Idle  = (bridge_state == Bridge_Idle) & ((write_happened && s_axi_bready)||(!write_happened));
wire condition2_state_Idle  = (bridge_state == Bridge_Idle) & (write_happened && !axi_bready);
wire condition3_state_Idle  = (bridge_state == Bridge_Idle) ;

wire condition11_state_Idle = condition1_state_Idle & (s_axi_arvalid) && ((state == Idle) | (state == Access));
wire condition12_state_Idle = condition1_state_Idle & (s_axi_awvalid) && (s_axi_wvalid) && (state == Idle);
wire condition13_state_Idle = condition1_state_Idle & (!(s_axi_awvalid) && (s_axi_wvalid) && (state == Idle));
wire condition14_state_Idle = condition1_state_Idle & ((s_axi_awvalid) && !(s_axi_wvalid) && (state == Idle));

wire condition1_state_axi_read  = (bridge_state == axi_read) & ((state == Access) && (|m_apb_pready));
wire condition2_state_axi_read  = (bridge_state == axi_read) & ((state == Access) && (!|m_apb_pready));
wire condition3_state_axi_read  = (bridge_state == axi_read) ;

wire condition11_state_axi_read = condition1_state_axi_read & (s_axi_rready);
wire condition12_state_axi_read = condition1_state_axi_read & !(s_axi_rready);


wire condition111_state_axi_read = condition11_state_axi_read & (s_axi_arvalid);
wire condition112_state_axi_read = condition11_state_axi_read & ((s_axi_awvalid) && (s_axi_wvalid));
wire condition113_state_axi_read = condition11_state_axi_read & ((s_axi_awvalid) && (!s_axi_wvalid));
wire condition114_state_axi_read = condition11_state_axi_read & ((!s_axi_awvalid) && (s_axi_wvalid));

wire condition1_state_axi_read_response_wait  = (bridge_state == read_response_wait) & (s_axi_rready);
wire condition2_state_axi_read_response_wait  = (bridge_state == read_response_wait) & (!s_axi_rready);
wire condition11_state_axi_read_response_wait  = condition1_state_axi_read_response_wait & (s_axi_arvalid);
wire condition12_state_axi_read_response_wait  = condition1_state_axi_read_response_wait & ((s_axi_awvalid) && (s_axi_wvalid));
wire condition13_state_axi_read_response_wait  = condition1_state_axi_read_response_wait & ((s_axi_awvalid) && (!s_axi_wvalid));
wire condition14_state_axi_read_response_wait  = condition1_state_axi_read_response_wait & ((!s_axi_awvalid) && (s_axi_wvalid));


wire condition1_state_axi_write_address_wait  = (bridge_state == axi_write_address_wait) & (s_axi_awvalid);
wire condition2_state_axi_write_address_wait  = (bridge_state == axi_write_address_wait) & (!s_axi_awvalid);

assign apb_transfer_req = (condition11_state_Idle | condition12_state_Idle) | (condition111_state_axi_read | condition112_state_axi_read) |
			  
				;

assign s_axi_arready    = condition11_state_Idle      | condition111_state_axi_read | condition11_state_axi_read_response_wait ;


assign s_axi_awready    = condition12_state_Idle      | condition14_state_Idle      | 
			  condition112_state_axi_read | condition113_state_axi_read |
			  (bridge_state == axi_write_address_wait)                  | 
			  (condition12_state_axi_read_response_wait)                | condition13_state_axi_read_response_wait ;


assign s_axi_wready     = condition12_state_Idle | condition13_state_Idle | 
			  (bridge_state == axi_write_data_wait)           |
			  (condition12_state_axi_read_response_wait)      | condition14_state_axi_read_response_wait ;	  
	
wire Bridge_Idle_state  = bridge_state == Bridge_Idle;


if(bridge_state == Bridge_Idle) begin
	if(condition1_state_Idle) begin
		if ((s_axi_arvalid) && ((state == Idle) || (state == Access))) begin	//condition11_state_Idle
			bridge_state         <= axi_read;
			captured_addr        <= s_axi_araddr;
			axi_write_data_reg   <= 32'h00000000;
			write_req_reg        <= 1'b0;

		end
		else if((s_axi_awvalid) && (s_axi_wvalid) && (state == Idle))			//condition12_state_Idle
			bridge_state 	     <= axi_write;
			captured_addr        <= s_axi_awaddr;
			axi_write_data_reg   <= s_axi_wdata;
			write_req_reg        <= 1'b1;

		else if(!(s_axi_awvalid) && (s_axi_wvalid) && (state == Idle))			//condition13_state_Idle
			bridge_state         <= axi_write_address_wait;
			captured_addr        <= 32'h00000000;
			axi_write_data_reg   <= s_axi_wdata;
			write_req_reg        <= 1'b0;

		else if((s_axi_awvalid) && !(s_axi_wvalid) && (state == Idle))			//condition14_state_Idle
			bridge_state         <= axi_write_data_wait;
			captured_addr        <= s_axi_awaddr;
			axi_write_data_reg   <= 32'h00000000;
			write_req_reg        <= 1'b0;

		write_happened <= 1'b0;
		write_resp_valid_reg <= 1'b0;
	end
	else if(condition2_state_Idle) begin

		bridge_state 	     <= Bridge_Idle;
		axi_write_data_reg   <= 32'h00000000;
		write_req_reg        <= 1'b0;
		captured_addr        <= 32'h00000000;
		write_happened       <= write_happened;
		write_resp_valid_reg <= 1'b1;
	end
	else begin
		bridge_state 	     <= Bridge_Idle;
		axi_write_data_reg   <= 32'h00000000;
		write_req_reg        <= 1'b0;
		captured_addr        <= 32'h00000000;
		write_happened       <= write_happened;
		write_resp_valid_reg <= 1'b0;
       
	end
	read_valid_reg       <= 1'b0;
	read_data_reg        <= 32'h00000000;
	read_resp            <= read_resp;
	write_resp           <= write_resp;
end
if(bridge_state == axi_read) begin
	if (condition1_state_axi_read)begin 				//condition1_state_axi_read
		if (s_axi_rready) begin  				//condition11_state_axi_read
			if (s_axi_arvalid)  begin			//condition111_state_axi_read
				bridge_state         <= axi_read;
				captured_addr        <= s_axi_araddr;
				axi_write_data_reg   <= 32'h00000000;
				write_req_reg        <= 1'b0;	

			end
			else if ((s_axi_awvalid) && (s_axi_wvalid))  begin	//condition112_state_axi_read
				bridge_state         <= axi_write;
				captured_addr        <= s_axi_awaddr;
				axi_write_data_reg   <= s_axi_wdata;
				write_req_reg        <= 1'b1;
			end
			else if ((s_axi_awvalid) && (!s_axi_wvalid)) begin	//condition113_state_axi_read				
				bridge_state         <= axi_write_data_wait;
				captured_addr        <= s_axi_awaddr;
				axi_write_data_reg   <= 32'h00000000;
				write_req_reg        <= 1'b0;
					
			end
			else if ((!s_axi_awvalid) && (s_axi_wvalid)) begin	//condition114_state_axi_read
				bridge_state         <= axi_write_address_wait;
				captured_addr        <= 32'h00000000;
				axi_write_data_reg   <= s_axi_wdata;
				write_req_reg        <= 1'b0;
			end
		
		end
		else begin						//condition12_state_axi_read
			bridge_state         <= axi_read_response_wait;
			captured_addr        <= 32'h00000000;
			axi_write_data_reg   <= 32'h00000000;
			write_req_reg        <= 1'b0;
		end
		read_valid_reg       <= 1'b1;
		read_data_reg  	     <= sel_m_apb_prdata;
		read_resp            <= |m_apb_pslverr;

	end
	else if (condition2_state_axi_read) begin
		if(wait_counter<max_count) begin
			bridge_state    <= axi_read;
			read_resp       <= read_resp;
		end		
		else begin
			bridge_state    <= Bridge_Idle;
			//send error respone through axi read response channel
			read_resp       <= Error_resp; 
			
		end
		captured_addr        <= 32'h00000000;
		axi_write_data_reg   <= 32'h00000000;
		write_req_reg        <= 1'b0;
		read_valid_reg       <= 1'b0;
		read_data_reg        <= 32'h00000000;
	end

	write_happened       <= 1'b0;
	write_resp_valid_reg <= 1'b0;
	write_resp           <= write_resp;
end
if(bridge_state == axi_write) begin
	if ((state == Access) && (|m_apb_pready))	
		To DO:
			capture_write_data_response
			assert write valid response

		axi_write_data_reg   <= axi_write_data_reg;
		write_happened       <= 1'b1;
		bridge_state         <= Bridge_Idle;
		write_req_reg        <= 1'b0;
		read_valid_reg       <= 1'b0;
		write_resp_valid_reg <= 1'b0;
		read_data_reg        <= 32'h00000000;
		captured_addr        <= 32'h00000000;
		write_resp           <= |m_apb_pslverr;;

	else if ((state == Access) && (!|m_apb_pready))
		if(wait_counter<max_count)
			bridge_state = axi_write;
			To Do:
		else 
			bridge_state = Idle;
			To Do:
				send error respone through axi write response channel
	else:
		bridge_state = axi_write;

	read_valid_reg  <= 1'b0;
	read_data_reg   <= 32'h00000000;
	write_happened  <= 1'b1;
end
if(bridge_state == axi_write_data_wait) begin
	if(s_axi_wvalid)
		bridge_state = axi_write;
		To Do:
			capture write data
	else:
		bridge_state = axi_write_data_wait;

	read_valid_reg  <= 1'b0;
	read_data_reg   <= 32'h00000000;
end
if(bridge_state == axi_write_address_wait) begin
	if(s_axi_awvalid)
		bridge_state = axi_write;
		To Do:
			capture write address
	else:
		bridge_state = axi_write_address_wait;
end
if(bridge_state == axi_read_response_wait) begin
	if (s_axi_rready)
		if (s_axi_arvalid)  begin			//condition111_state_axi_read
			bridge_state         <= axi_read;
			captured_addr        <= s_axi_araddr;
			axi_write_data_reg   <= 32'h00000000;
			write_req_reg        <= 1'b0;	
		end
		else if ((s_axi_awvalid) && (s_axi_wvalid))
				bridge_state = axi_write		
			To DO:
				capture address
				capture data
				initiate transfer on apb master

		else if ((s_axi_awvalid) && (!s_axi_wvalid))
				bridge_state = axi_write_data_wait				
			To DO:
				capture address	

		else if ((!s_axi_awvalid) && (s_axi_wvalid))
				bridge_state = axi_write_address_wait				
		To DO:
			send read data response
			send read data back to axi master
			assert read valid signal
	else 
		bridge_state = axi_read_response_wait

	read_valid_reg  <= 1'b1;
	read_data_reg <= read_data_reg;
end
endmodule
