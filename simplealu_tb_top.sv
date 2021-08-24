import uvm_pkg::*;
`include "axi_lite_pkg.sv"
import axi_lite_pkg::*;
`include "uvm_macros.svh"
`include "simple_alu.v"

`include "flop.v"
`include "apb_master.v"
`include "axi_apb_bridge.v"
`include "APB_Slave.v"

`include "simplealu_if.sv"
`include "axi_lite_if.sv"
`include "axi_lite_master.sv"

//`include "simplealu_pkg.sv"
`include "simplealu_sequencer.sv"
`include "simplealu_monitor.sv"
`include "simplealu_driver.sv"
`include "simplealu_agent.sv"
`include "simplealu_scoreboard.sv"
//`include "simplealu_config.sv"
`include "simplealu_env.sv"
`include "simplealu_test.sv"
    

module simplealu_tb_top;
//import uvm_pkg::*;

//interface declaration
simplealu_if vif();
axi_lite_if axi_lite_master_vif();

//connect the interface to the DUT

simple_alu dut(vif.clk       ,
               vif.en_i      ,
               vif.en_o      ,
               vif.select_op ,
               vif.a         ,
               vif.b,
               vif.out);
logic areset_n;
logic start_read;
logic start_write;
axi_lite_master axi_lite_master_DUT(
	vif.clk,
	areset_n,
	axi_lite_master_vif.master,
	start_read,
	start_write
);


localparam c_apb_num_slaves = 1;
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

axi_apb_bridge bridge(        
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


APB_Slave apb_slave
(
                         vif.clk,
                         areset_n,
        		 m_apb_paddr,
                         m_apb_pwrite,
                         m_apb_psel[0],
        		 m_apb_pwdata,
        		 m_apb_prdata,
                         m_apb_pready[0]
);
			       

initial begin
 //   uvm_config_db #(virtual simplealu_if)::set(.scope("ifs"), .name("simplealu_if"), .val(vif));
    uvm_config_db#(virtual simplealu_if)::set(null,"*","simplealu_vif",vif);  //set method

    run_test();
end

initial begin
    vif.clk  = 1'b1;
    areset_n = 1'b1;
    start_read  = 0;
    start_write = 0;
    #30;
    areset_n = 1'b0; 
    #30;  
    areset_n = 1'b1; 
    start_write = 1'b1;
    start_read  = 1'b0;
    #30;
    start_write = 1'b0;
    start_read  = 1'b1;
    #30;
    start_write = 1'b0;
    start_read  = 1'b0;
end
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
