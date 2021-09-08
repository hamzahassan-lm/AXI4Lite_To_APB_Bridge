import uvm_pkg::*;
`include "../RTL/axi_lite_pkg.sv"
import axi_lite_pkg::*;
`include "uvm_macros.svh"


`include "../RTL/apb_master.v"
`include "../RTL/address_decoder.v"
`include "../RTL/read_data_mux.v"
`include "../RTL/flop.v"


`include "../RTL/axi_apb_bridge.v"
`include "../RTL/APB_Slave.v"

`include "../RTL/axi_lite_if.sv"
`include "../RTL/axi_lite_master.sv"

//`include "simplealu_pkg.sv"

//`include "simplealu_config.sv"

    

module simplealu_tb_top;
//import uvm_pkg::*;

//interface declaration
axi_lite_if vif();
axi_lite_if axi_lite_master_vif();

//connect the interface to the DUT

logic areset_n;
logic start_read;
logic start_write;
logic[31:0] write_data= 10;
logic[31:0] read_data ;
logic[31:0] write_read_address = 4;
axi_lite_master axi_lite_master_DUT(
	vif.clk,
	areset_n,
	axi_lite_master_vif.master,
	start_read,
	start_write,
	write_data,
	write_read_address
);


localparam c_apb_num_slaves = 3;
localparam ADDRWIDTH        = 32;
localparam DATAWIDTH        = 32;


wire    [31:0]                  m_apb_paddr;
wire    [2:0]                   m_apb_pprot;
wire    [c_apb_num_slaves-1:0]  m_apb_psel;
wire                            m_apb_penable;
wire                            m_apb_pwrite;
wire    [31:0]                  m_apb_pwdata;
wire    [3:0]                   m_apb_pstrb;
wire    [c_apb_num_slaves-1:0]  m_apb_pready;

wire    [31:0]                  m_apb_prdata;
wire    [31:0]                  m_apb_prdata2;
wire    [31:0]                  m_apb_prdata3;
wire    [31:0]                  m_apb_prdata4;
wire    [31:0]                  m_apb_prdata5;
wire    [31:0]                  m_apb_prdata6;
wire    [31:0]                  m_apb_prdata7;
wire    [31:0]                  m_apb_prdata8;
wire    [31:0]                  m_apb_prdata9;
wire    [31:0]                  m_apb_prdata10;
wire    [31:0]                  m_apb_prdata11;
wire    [31:0]                  m_apb_prdata12;
wire    [31:0]                  m_apb_prdata13;
wire    [31:0]                  m_apb_prdata14;
wire    [31:0]                  m_apb_prdata15;
wire    [31:0]                  m_apb_prdata16;
wire    [c_apb_num_slaves-1:0]  m_apb_pslverr;

parameter [32*c_apb_num_slaves-1 : 0]  memory_regions1  = 32'h0+64'h0000004000000000+96'h000000800000000000000000;
parameter [32*c_apb_num_slaves-1 : 0]  memory_regions2  = 32'h3f+64'h0000007F00000000+96'h000000C00000000000000000;

axi_apb_bridge #(.c_apb_num_slaves(c_apb_num_slaves),
		.memory_regions1(memory_regions1),
		.memory_regions2(memory_regions2)
		)

		bridge(        
			vif.clk,
			areset_n,
			axi_lite_master_vif.s_axi_awaddr,
			axi_lite_master_vif.s_axi_awvalid,
			axi_lite_master_vif.s_axi_awready,
			axi_lite_master_vif.s_axi_wdata,
			axi_lite_master_vif.s_axi_wvalid,
			axi_lite_master_vif.s_axi_wstrb,
			axi_lite_master_vif.s_axi_wready,
			axi_lite_master_vif.s_axi_bresp,
			axi_lite_master_vif.s_axi_bvalid,
			axi_lite_master_vif.s_axi_bready,
			axi_lite_master_vif.s_axi_araddr,
			axi_lite_master_vif.s_axi_arvalid,
			axi_lite_master_vif.s_axi_arready,
			axi_lite_master_vif.s_axi_rresp,
			axi_lite_master_vif.s_axi_rvalid,
			axi_lite_master_vif.s_axi_rdata,
			axi_lite_master_vif.s_axi_rready,
			axi_lite_master_vif.s_axi_arprot,
			axi_lite_master_vif.s_axi_awprot,			

			m_apb_paddr,
			m_apb_pprot,
			m_apb_psel,
			m_apb_penable,
			m_apb_pwrite,
			m_apb_pwdata,
			m_apb_pstrb,
			m_apb_pready,
			m_apb_prdata,
			m_apb_prdata2,
			m_apb_prdata3,
			m_apb_prdata4,
			m_apb_prdata5,
			m_apb_prdata6,
			m_apb_prdata7,
			m_apb_prdata8,
			m_apb_prdata9,
			m_apb_prdata10,
			m_apb_prdata11,
			m_apb_prdata12,
			m_apb_prdata13,
			m_apb_prdata14,
			m_apb_prdata15,
			m_apb_prdata16,
			m_apb_pslverr
		);



APB_Slave
#(.Start_Addr(memory_regions1[31:0]),
  .End_Addr(memory_regions2[31:0])
  )

apb_slave
(
                         vif.clk,
                         areset_n,
        		 m_apb_paddr,
                         m_apb_pwrite,
                         m_apb_psel[0],
        		 m_apb_pwdata,
        		 m_apb_prdata,
                         m_apb_pready[0],
			 m_apb_pslverr[0]
);			

APB_Slave
#(.Start_Addr(memory_regions1[32*2-1:32*1]),
  .End_Addr(memory_regions2[32*2-1:32*1])
  )

apb_slave2
(
                         vif.clk,
                         areset_n,
        		 m_apb_paddr,
                         m_apb_pwrite,
                         m_apb_psel[1],
        		 m_apb_pwdata,
        		 m_apb_prdata2,
                         m_apb_pready[1],
			 m_apb_pslverr[1]
);		       

APB_Slave
#(.Start_Addr(memory_regions1[32*3-1:32*2]),
  .End_Addr(memory_regions2[32*3-1:32*2])
  )
apb_slave3
(
                         vif.clk,
                         areset_n,
        		 m_apb_paddr,
                         m_apb_pwrite,
                         m_apb_psel[2],
        		 m_apb_pwdata,
        		 m_apb_prdata3,
                         m_apb_pready[2],
			 m_apb_pslverr[2]
);

/*
initial begin
 //   uvm_config_db #(virtual simplealu_if)::set(.scope("ifs"), .name("simplealu_if"), .val(vif));
    uvm_config_db#(virtual simplealu_if)::set(null,"*","simplealu_vif",vif);  //set method
    run_test();
end
*/


initial begin
    vif.clk  = 1'b1;
    areset_n = 1'b1;
    start_read  = 0;
    start_write = 0;
    #30;
    areset_n = 1'b0; 
    #30;  
    areset_n = 1'b1; 
end

typedef enum logic [3 : 0] {start, write_data_state, write_resp, read_data_state, read_resp, match,finish} test_state;

test_state test_state_ = start;
int repetetions = 0;
int slave_no    = 1;


   always @(posedge vif.clk) begin
	if(test_state_ == start) begin
		test_state_ <= write_data_state;
				
		if(slave_no>=2) slave_no = 1;
		else		slave_no += 1;
		
		
	end
	else if(test_state_ == write_data_state) begin
		test_state_ <= write_resp;
		write(repetetions,repetetions+memory_regions1[32*3-1:32*2]);
		
	end
	else if(test_state_ == write_resp) begin
		if(axi_lite_master_vif.s_axi_bvalid) test_state_ <= read_data_state;
		else test_state_ <= write_resp;
	end
	else if(test_state_ == read_data_state) begin
		test_state_ <= read_resp;  
		read(repetetions+memory_regions1[32*3-1:32*2]);

		
	end
	else if(test_state_ == read_resp) begin
		if(axi_lite_master_vif.s_axi_rvalid)  begin
				test_state_ <= match;
				read_data   = axi_lite_master_vif.s_axi_rdata;
		end
		else test_state_ <= read_resp;
	end
	else if(test_state_ == match) begin
		if(repetetions >= 20)  test_state_ <= finish;
		else begin
			repetetions <= repetetions + 1;
			test_state_ <= start;
			if(read_data != write_data) $display("test fail");
			else 			    $display("test pass");
		end
		
	end
	else begin
			test_state_ <= finish;
			$finish;
	end
   end


task write(int data, int address);
        start_write = 1;
  	start_read  = 0;
	write_data  = data;
    	write_read_address  = address;
endtask: write 

task read(int address);
        start_write = 0;
  	start_read  = 1;
    	write_read_address    = address;

endtask: read

initial begin 
	$dumpfile("waves.vcd");
	$dumpvars();

end

/*
initial begin 
	$fsdbDumpfile("waves.fsdb");
	$fsdbDumpvars(0,simplealu_tb_top);
	#12500 $finish;

end
*/
//assign counter_vif.clk = vif.clk;
//clock generation
always begin
    #5 vif.clk = ~vif.clk;
	
end
endmodule
