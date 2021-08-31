`include "apb_master.v"
`include "flop.v"

module axi_apb_bridge
	#(parameter c_apb_num_slaves = 1,
	  parameter [32*c_apb_num_slaves-1 : 0] memory_regions1 = 0,
	  parameter [32*c_apb_num_slaves-1 : 0] memory_regions2  = 64,
	  parameter timeout_val       = 1,
	  parameter APB_Protocol      = 3,
	)
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

		input  [2:0]                  s_axi_arprot,
		input  [2:0]                  s_axi_awprot,

		output [31:0]                 m_apb_paddr,
		output [2:0]                  m_apb_pprot,
		output [c_apb_num_slaves-1:0] m_apb_psel,
		output                        m_apb_penable,
		output                        m_apb_pwrite,
		output [31:0]                 m_apb_pwdata,
		output [3:0]                  m_apb_pstrb,
		input [c_apb_num_slaves-1:0]  m_apb_pready,
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

localparam Idle   = 'd 0;
localparam Setup  = 'd 1;
localparam Access = 'd 2;

localparam Bridge_Idle              = 'd 0;
localparam axi_read  	            = 'd 1;
localparam axi_write                = 'd 2;
localparam axi_write_data_wait      = 'd 3;
localparam axi_write_address_wait   = 'd 4;
localparam axi_read_response_wait   = 'd 5;


wire[31:0] axi_write_data_reg;
wire[31:0] axi_write_data_reg_nxt;

flop#(.width(32))
 axi_write_data_ff(s_axi_clk,s_axi_aresetn,axi_write_data_nxt,axi_write_data_reg);

wire       write_happened;
wire       write_happened_nxt;
flop#(.width(1))
 write_happened_ff(s_axi_clk,s_axi_aresetn,write_happened_nxt,write_happened);

wire       read_valid_reg;
wire	   read_valid_nxt;
flop#(.width(1))
 read_valid_ff(s_axi_clk,s_axi_aresetn,read_valid_nxt,read_valid_reg);

wire       write_resp_valid_reg;
wire	   write_resp_valid_nxt;
flop#(.width(1))
 write_resp_valid_ff(s_axi_clk,s_axi_aresetn,write_resp_valid_nxt,write_resp_valid_reg);

wire[31:0] read_data_reg;
wire[31:0] read_data_nxt;
flop#(.width(32))
 read_data_ff(s_axi_clk,s_axi_aresetn,read_data_nxt,read_data_reg);


wire[31:0] captured_addr;
wire[31:0] captured_addr_nxt;
flop#(.width(32))
 captured_addr_ff(s_axi_clk,s_axi_aresetn,captured_addr_nxt,captured_addr);

wire[1:0] read_resp;
wire[1:0] read_resp_nxt;
flop#(.width(2))
 read_resp_ff(s_axi_clk,s_axi_aresetn,read_resp_nxt,read_resp);

wire[1:0] write_resp;
wire[1:0] write_resp_nxt;
flop#(.width(2))
 write_resp_ff(s_axi_clk,s_axi_aresetn,write_resp_nxt,write_resp);

wire[31:0] timeout_counter;
wire[31:0] timeout_counter_nxt;
flop#(.width(32))
 timeout_counter_ff(s_axi_clk,s_axi_aresetn,timeout_counter_nxt,timeout_counter);



reg[2:0]  bridge_state;
wire      apb_transfer_req;

wire [1:0] strb = s_axi_wstrb;
wire [c_apb_num_slaves-1:0] SSEL;
wire [1:0]                  state;
wire                        SWRT;
wire [31:0]                 SWDATA;
wire [31:0]                 SRDATA;
wire [31:0]                 sel_m_apb_prdata;
wire [31:0]                 SADDR;
wire                        apb_reset;
wire                        STREQ;

apb_master #(.c_apb_num_slaves(c_apb_num_slaves))
		UUT (s_axi_clk, apb_reset, STREQ, SWRT, SSEL,SADDR,SWDATA,SRDATA, m_apb_paddr, m_apb_pprot, m_apb_psel, m_apb_penable,
                m_apb_pwrite, m_apb_pwdata, m_apb_pstrb, m_apb_pready, m_apb_prdata, m_apb_pslverr, m_apb_prdata2, m_apb_prdata3,
                m_apb_prdata4, m_apb_prdata5, m_apb_prdata6, m_apb_prdata7, m_apb_prdata8, m_apb_prdata9, m_apb_prdata10,
                m_apb_prdata11, m_apb_prdata12, m_apb_prdata13, m_apb_prdata14, m_apb_prdata15, m_apb_prdata16, state);



wire condition1_state_Idle  = (bridge_state == Bridge_Idle) & ((write_happened && s_axi_bready)||(!write_happened));
wire condition2_state_Idle  = (bridge_state == Bridge_Idle) & (write_happened && !s_axi_bready);
wire condition3_state_Idle  = (bridge_state == Bridge_Idle) ;

wire condition11_state_Idle = condition1_state_Idle & (s_axi_arvalid) && ((state == Idle) | (state == Access));
wire condition12_state_Idle = condition1_state_Idle & (s_axi_awvalid) && (s_axi_wvalid) && (state == Idle);
wire condition13_state_Idle = condition1_state_Idle & (!(s_axi_awvalid) && (s_axi_wvalid) && (state == Idle));
wire condition14_state_Idle = condition1_state_Idle & ((s_axi_awvalid) && !(s_axi_wvalid) && (state == Idle));

wire condition1_state_axi_read  = (bridge_state == axi_read) & ((state == Access) & (|(m_apb_psel & m_apb_pready)));
wire condition2_state_axi_read  = (bridge_state == axi_read) & ((state == Access) & !(|(m_apb_psel & m_apb_pready)));
wire condition3_state_axi_read  = (bridge_state == axi_read) & (state == Setup);
wire condition4_state_axi_read  = (bridge_state == axi_read) & (state == Idle);

wire condition11_state_axi_read = condition1_state_axi_read & (s_axi_rready);
wire condition12_state_axi_read = condition1_state_axi_read & !(s_axi_rready);

wire condition22_state_axi_read = condition2_state_axi_read & (timeout_counter == 32'h00000000) ;


wire condition111_state_axi_read = condition11_state_axi_read & (s_axi_arvalid);
wire condition112_state_axi_read = condition11_state_axi_read & ((s_axi_awvalid) && (s_axi_wvalid));
wire condition113_state_axi_read = condition11_state_axi_read & ((s_axi_awvalid) && (!s_axi_wvalid));
wire condition114_state_axi_read = condition11_state_axi_read & ((!s_axi_awvalid) && (s_axi_wvalid));

wire condition1_state_axi_write = (bridge_state == axi_write) & ((state == Access) & (|(m_apb_psel & m_apb_pready)));
wire condition2_state_axi_write = (bridge_state == axi_write) & ((state == Access) & !(|(m_apb_psel & m_apb_pready)));
wire condition3_state_axi_write = (bridge_state == axi_write) & (state == Setup);

wire condition22_state_axi_write = condition2_state_axi_write & (timeout_counter == 32'h00000000) ;

wire condition1_state_axi_read_response_wait  = (bridge_state == axi_read_response_wait) & (s_axi_rready);
wire condition2_state_axi_read_response_wait  = (bridge_state == axi_read_response_wait) & (!s_axi_rready);
wire condition11_state_axi_read_response_wait  = condition1_state_axi_read_response_wait & (s_axi_arvalid);
wire condition12_state_axi_read_response_wait  = condition1_state_axi_read_response_wait & ((s_axi_awvalid) && (s_axi_wvalid));
wire condition13_state_axi_read_response_wait  = condition1_state_axi_read_response_wait & ((s_axi_awvalid) && (!s_axi_wvalid));
wire condition14_state_axi_read_response_wait  = condition1_state_axi_read_response_wait & ((!s_axi_awvalid) && (s_axi_wvalid));


wire condition1_state_axi_write_address_wait  = (bridge_state == axi_write_address_wait) & (s_axi_awvalid);
wire condition2_state_axi_write_address_wait  = (bridge_state == axi_write_address_wait) & (!s_axi_awvalid);

wire condition1_state_axi_write_data_wait  = (bridge_state == axi_write_data_wait) & (s_axi_wvalid);
wire condition2_state_axi_write_data_wait  = (bridge_state == axi_write_data_wait) & (!s_axi_wvalid);

assign m_apb_pprot      = (APB_Protocol == 4) ? (bridge_state == axi_read) ? s_axi_arprot : (bridge_state == axi_write) ? s_axi_awprot : 3'b000 : 3'b000;
			   

assign apb_reset        = condition22_state_axi_read | condition22_state_axi_write ? 0 : s_axi_aresetn;


assign apb_transfer_req = condition11_state_Idle                  | condition12_state_Idle |
			  condition111_state_axi_read             | condition112_state_axi_read |
			  condition1_state_axi_write_address_wait | condition1_state_axi_write_data_wait |
			  condition11_state_axi_read_response_wait| condition12_state_axi_read_response_wait;

assign s_axi_arready    = condition11_state_Idle      | condition111_state_axi_read | condition11_state_axi_read_response_wait ;


assign s_axi_awready    = condition12_state_Idle      | condition14_state_Idle      | 
			  condition112_state_axi_read | condition113_state_axi_read |
			  (bridge_state == axi_write_address_wait)                  | 
			  (condition12_state_axi_read_response_wait)                | condition13_state_axi_read_response_wait ;


assign s_axi_wready     = condition12_state_Idle | condition13_state_Idle | 
			  (bridge_state == axi_write_data_wait)           |
			  (condition12_state_axi_read_response_wait)      | condition14_state_axi_read_response_wait ;	

 



assign write_req                = (bridge_state == axi_write) | condition2_state_Idle | ((bridge_state == Bridge_Idle) & (write_happened && s_axi_bready)) ;

assign read_valid_nxt	      = ((state == Access) & |(m_apb_psel & m_apb_pready) & !write_req)| (condition2_state_axi_read_response_wait) | 
				(condition22_state_axi_read) ;

assign read_resp_nxt            = condition1_state_axi_read ? {|(m_apb_psel&m_apb_pslverr),1'b0} :
				condition22_state_axi_read ? 2'b10 :
				condition2_state_axi_read_response_wait ? read_resp : 2'b00;

assign read_data_nxt      = ((state == Access) & |(m_apb_psel & m_apb_pready) & !write_req) ? sel_m_apb_prdata :
				condition22_state_axi_read ? 32'h00000000 : 
			        (condition2_state_axi_read_response_wait) ? read_data_reg : 32'h00000000;	 		  

assign axi_write_data_nxt = condition12_state_Idle                   | condition13_state_Idle |
				condition112_state_axi_read              | condition114_state_axi_read |
				condition1_state_axi_write_data_wait     | condition12_state_axi_read_response_wait |
				condition14_state_axi_read_response_wait  
			 	? s_axi_wdata : (bridge_state == axi_write_address_wait) | condition2_state_axi_write |condition3_state_axi_write
			        ? axi_write_data_reg : 32'h00000000;

assign write_resp_valid_nxt     = condition2_state_Idle | condition1_state_axi_write | condition22_state_axi_write ;
assign write_resp_nxt 	   = condition1_state_axi_write  ? {|(m_apb_psel&m_apb_pslverr),1'b0} :
				     condition22_state_axi_write ? 2'b10 :
				     condition2_state_Idle ? write_resp  : 2'b00;

assign captured_addr_nxt  = condition11_state_Idle | condition111_state_axi_read | condition11_state_axi_read_response_wait ? s_axi_araddr :
				condition12_state_Idle | condition14_state_Idle | condition112_state_axi_read | condition113_state_axi_read |
				condition1_state_axi_write_address_wait | condition12_state_axi_read_response_wait
				| condition13_state_axi_read_response_wait ? s_axi_awaddr : condition2_state_axi_read | condition3_state_axi_read |
				(bridge_state == axi_write) | (bridge_state == axi_write_data_wait ) ? captured_addr : 32'h00000000;

assign timeout_counter_nxt = (condition2_state_axi_read | condition2_state_axi_write) & (timeout_counter > 32'h00000000) ?
				 timeout_counter-1 : condition3_state_Idle | condition1_state_axi_read | condition1_state_axi_write ?
				 timeout_val       : timeout_counter;
		
assign write_happened_nxt        = (!s_axi_aresetn) ? 1'b0 : (bridge_state == axi_write) ? 1'b1 : condition2_state_Idle ? write_happened : 1'b0;




assign s_axi_rdata      = read_data_reg;
assign s_axi_bresp      = write_resp;
assign s_axi_rresp      = read_resp ;
assign s_axi_bvalid     = write_resp_valid_reg;
assign s_axi_rvalid     = read_valid_reg;
	
assign SADDR            = captured_addr; 
assign STREQ            = apb_transfer_req;
assign SWRT             = write_req;
assign SWDATA           = axi_write_data_reg;


always@(posedge s_axi_clk or negedge s_axi_aresetn) begin

	if(!s_axi_aresetn) begin
		bridge_state	    <= Bridge_Idle;
	end
	else if(bridge_state == Bridge_Idle)begin
		if(condition1_state_Idle) begin
			if ((s_axi_arvalid) && ((state == Idle) || (state == Access))) 			 bridge_state <= axi_read;
			else if((s_axi_awvalid) &&  (s_axi_wvalid) && (state == Idle | state == Access)) bridge_state <= axi_write;
			else if(!(s_axi_awvalid) && (s_axi_wvalid) && (state == Idle | state == Access)) bridge_state <= axi_write_address_wait;
			else if((s_axi_awvalid) && !(s_axi_wvalid) && (state == Idle | state == Access)) bridge_state <= axi_write_data_wait;
			else 										 bridge_state <= Bridge_Idle;
		end
		else if(condition2_state_Idle) bridge_state <= Bridge_Idle;
		else begin
			bridge_state 	     <= Bridge_Idle;
		end
	end
	else if(bridge_state == axi_read) begin
		if (condition1_state_axi_read)begin
			if (s_axi_rready) begin
				if (s_axi_arvalid)			    bridge_state  <= axi_read;
				else if ((s_axi_awvalid) && (s_axi_wvalid)) bridge_state  <= axi_write;
				else if ((s_axi_awvalid) && (!s_axi_wvalid))bridge_state  <= axi_write_data_wait;
				else if ((!s_axi_awvalid) && (s_axi_wvalid))bridge_state  <= axi_write_address_wait;
				else 					    bridge_state  <= Bridge_Idle;
			end
			else bridge_state   <= axi_read_response_wait;
		end
		else if (condition2_state_axi_read) begin
			if(timeout_counter > 32'h00000000) bridge_state  <= axi_read;		
			else 				   bridge_state  <= axi_read_response_wait;	
			
		end
		else if (state == Setup) bridge_state <= axi_read;
		else if (state == Idle)  bridge_state <= Bridge_Idle;	
	end
	else if(bridge_state == axi_write) begin
		if ((state == Access) && (|(m_apb_psel & m_apb_pready))) begin
			bridge_state         <= Bridge_Idle;

		end
		else if ((state == Access) && (!|(m_apb_psel & m_apb_pready))) begin
			if(timeout_counter > 32'h00000000) bridge_state <= axi_write;
			else 				   bridge_state <= Bridge_Idle;
			
		end
		else if (state == Setup) bridge_state <= axi_write;
		else if (state == Idle)  bridge_state <= Bridge_Idle;
	end
	else if(bridge_state == axi_write_data_wait) begin
		if(s_axi_wvalid) bridge_state <= axi_write;
		else 		 bridge_state <= axi_write_data_wait;
	end
	else if(bridge_state == axi_write_address_wait) begin
		if(s_axi_awvalid) bridge_state 	   <= axi_write;
		else 		  bridge_state	   <= axi_write_address_wait;
	end
	else if(bridge_state == axi_read_response_wait) begin
		if (s_axi_rready) begin
			if (s_axi_arvalid) 			     bridge_state <= axi_read; 
			else if ((s_axi_awvalid) && (s_axi_wvalid))  bridge_state <= axi_write;	          
			else if ((s_axi_awvalid) && (!s_axi_wvalid)) bridge_state <= axi_write_data_wait;				
			else if ((!s_axi_awvalid) && (s_axi_wvalid)) bridge_state <= axi_write_address_wait;
			else 					     bridge_state <= Bridge_Idle;
		end
		else bridge_state <= axi_read_response_wait;
	end
end

wire[31:0] dummy  = memory_regions2[31:0];

genvar i;
/*
generate
	for(i=0;i<c_apb_num_slaves;i=i+1) assign SSEL[i] = (captured_addr >= memory_regions1[i]) & ((state == Access)|(state == Setup)) & (captured_addr <= memory_regions2[i]) ;
endgenerate
*/
generate
	for(i=32;i<=c_apb_num_slaves*32;i=i+32) assign SSEL[(i-32)/32] = (captured_addr >= memory_regions1[i-1:(i-32)]) & ((state == Access)|(state == Setup)) & (captured_addr <= memory_regions2[i-1:(i-32)]) ;
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
