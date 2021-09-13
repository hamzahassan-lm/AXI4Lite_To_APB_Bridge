# AXI4 Lite to APB3/APB4 Bridge Introduction
The repository contains the AXI4 lite to APB3/4 bridge Design written in verilog and also contains the test bench written in system verilog.


## Testbench is Included 
Testbench is in the Git repository, so you can 
run a simulation and see a live example 

## Project Structure
   * RTL
   * Testbench 
   * Documentaions
	
### Pre-Requisites
Before running the make file present in the Testbench folder following tools need to be sourced.
   * EDA Tools
   * GTKWave

### RTL
Contains RTL for all the Modules used in the Design.

   * axi_apb_bridge.v
      * The main module having all the logic of the bridge comprising of a state machine for AXI4_SLAVE
   * axi_lite_pkg.sv
      * contains the structures and datatypes defined for axi_lite transactions
   * apb_master.v
      * RTL for the APB master that is instantiated inside the bridge
   * flop.v
      * RTL for a synchronous flop having active low reset that is for registers in the design 
   * APB_Slave.v
      * APB slave for testing
   * axi_lite_if.sv
      * AXI4 lite interface definitions for interconnect
   * axi_lite_master.sv
      * AXI4 Lite master for testing purpose

### Testbench
Contains the Test Bench which runs a sanity test on the Bridge . In order to run the Test Bench go into the testbench folder and run make. It would
run the basic test that is implemented inside the testbench.

   * tb_top.sv
      * The test bench having simple sanity test for testing the bridge including the instantiations of other additive modules for testing
	which are not the part of the actual design. It also contains a state machine for the simple tests.

### Documentation
Contains the Implementation Document.
