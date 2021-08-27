`timescale 1ns/1ps
`define DATAWIDTH 32
`define ADDRWIDTH 32
`define IDLE     2'b00
`define W_ENABLE  2'b01
`define R_ENABLE  2'b10
module APB_Slave
(
  input                         PCLK,
  input                         PRESETn,
  input        [`ADDRWIDTH-1:0] PADDR,
  input                         PWRITE,
  input                         PSEL,
  input        [`DATAWIDTH-1:0] PWDATA,
  output wire   [`DATAWIDTH-1:0] PRDATA,
  output reg                    PREADY,
  output wire			PSLVERR
);

reg [`DATAWIDTH-1:0] RAM [63:0];

reg [1:0] State;



always @(negedge PRESETn or posedge PCLK) begin
  if (PRESETn == 0) begin
    State <= `IDLE;
    PREADY <= 0;
    end

  else begin
    case (State)
      `IDLE : begin
        if (PSEL) begin
          if (PWRITE) begin
            State <= `W_ENABLE;
          end
          else begin
            State <= `R_ENABLE;
          end
        end
      end

      `W_ENABLE : begin
        if (PSEL && PWRITE) begin
          RAM[PADDR]  <= PWDATA;
          PREADY <=1;          
        end
          State <= `IDLE;
      end

      `R_ENABLE : begin
        if (PSEL && !PWRITE) begin
          PREADY <= 1;
          
        end
        State <= `IDLE;
      end
      default: begin
        State <= `IDLE;
      end
    endcase
  end
end 
assign PRDATA = (State == `R_ENABLE) & (PSEL && !PWRITE) ? RAM[PADDR] : 32'h00000000;
assign PSLVERR = 1'b0;
endmodule
