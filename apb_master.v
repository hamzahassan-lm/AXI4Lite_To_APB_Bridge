module apb_master
	( PCLK,PRESETn,
	  STREQ,SWRT,SSEL,SADDR,SWDATA,SRDATA,
	  PADDR,PPROT,PSELx,PENABLE,PWRITE,PWDATA,PSTRB,
	  PREADY,PRDATA,PSLVERR,
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
output       PPROT;
output       PSELx;
output	     PENABLE;
output       PWRITE;
output[31:0] PWDATA;
output[3:0]  PSTRB;

input        PREADY;
input[31:0]  PRDATA;
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

assign PSELx   = (state == Idle)   ? 1'b0 : 1'b1;
assign PENABLE = (state == Access) ? 1'b1 : 1'b0;
assign PWRITE  = SWRT;
assign PSELx   = SSEL;


assign PADDR = SADDR;
assign PWDATA = SWDATA;
assign SRDATA = PRDATA;
assign Out_State = state;
assign PSTRB  = 4'b1111;
endmodule

