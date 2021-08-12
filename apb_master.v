module apb_master
	#(parameter c_apb_num_slaves = 1)
	( PCLK,PRESETn,
	  STREQ,SWRT,SSEL,SADDR,SWDATA,SRDATA,
	  PADDR,PPROT,PSELx,PENABLE,PWRITE,PWDATA,PSTRB,
	  PREADY,PRDATA,PSLVERR,
	  m_apb_prdata2,m_apb_prdata3,m_apb_prdata4,m_apb_prdata5,m_apb_prdata6,m_apb_prdata7,
	  m_apb_prdata8,m_apb_prdata9,m_apb_prdata10,m_apb_prdata11,m_apb_prdata12,m_apb_prdata13,
	  m_apb_prdata14,m_apb_prdata15,m_apb_prdata16,
	  Out_State
	);

input       PCLK;
input       PRESETn;

input	     STREQ;
input	     SWRT;
input 	     SSEL;
input[31:0]  SADDR;
input[31:0]  SWDATA;
output[31:0] SRDATA;

output[31:0] PADDR;
output[2:0]  PPROT;
output       PSELx;
output	     PENABLE;
output       PWRITE;
output[31:0] PWDATA;
output[3:0]  PSTRB;

input        PREADY;
input[31:0]  PRDATA;
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
input        PSLVERR;

output[1:0]  Out_State;

parameter Idle   = 'd 0;
parameter Setup  = 'd 1;
parameter Access = 'd 2;

reg[1:0]  state;
wire[1:0]  nstate;
wire[1:0] nst_int1;
wire[1:0] nst_int3;

always @ (posedge PCLK)
begin
    if (!PRESETn)
        state <= Idle;
    else
        state <= nstate;
end 
/*
always @(*)		
begin
  if (state == Idle)
    begin
	if (STREQ)
	  nstate = Setup;
	else
          nstate = Idle;
    end
  else if (state == Setup)
    nstate = Access;

  else if (state == Access)
    begin
	if (PREADY && STREQ)
	  nstate = Setup;
	else if (PREADY && ~STREQ)
          nstate = Idle;
	else if (~PREADY)
          nstate = Access;
	else
          nstate = Idle;   
    end
   else nstate = Idle;

end
*/

assign nst_int1 = STREQ ? Setup : Idle;
assign nst_int3  = PREADY && STREQ ? Setup : PREADY && ~STREQ ? Idle :~PREADY ? Access : Idle;
assign nstate  = (state == Idle) ? nst_int1 : (state == Setup) ? Access : (state == Access) ? nst_int3 : Idle;

//assign PSELx   = (state == Idle)   ? 1'b0 : 1'b1;
assign PENABLE = (state == Access) ? 1'b1 : 1'b0;
assign PWRITE  = SWRT;
assign PSELx   = SSEL;


assign PADDR = SADDR;
assign PWDATA = SWDATA;
assign SRDATA = PRDATA;
assign Out_State = state;
assign PSTRB  = 4'b1111;

endmodule

