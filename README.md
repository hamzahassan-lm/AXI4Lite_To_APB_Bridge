# AXI4 Lite to APB3/APB4 Bridge
The AXI Verification Component Library implements

## Testbench is Included 
Testbench is in the Git repository, so you can 
run a simulation and see a live example 

## Project Structure
   * RTL
   * testbench 
	
### Building Depencencies
Before building this project, you must build the following libraries in order

### RTL
Contains RTL for all the Modules used in the Design.

   * axi_lite_pkg.sv
      * contains the structures and datatypes defined for axi_lite transactions
   * apb_master.v
      * RTL for the APB master that is instantiated inside the bridge
   * flop.v
      * RTL for a synchronous flop having active low reset that is for registers in the design
   * axi_apb_bridge.v
      * The main module having all the logic of the bridge comprising of a state machine for AXI4_SLAVE 
   * APB_Slave.v
      * APB slave for testing
   * axi_lite_if.sv
      * AXI4 lite interface definitions for interconnect
   * axi_lite_master.sv
      * AXI4 Lite master for testing purpose

### testbench
Contains the Test Bench which runs a sanity test on the Bridge 

   * tb_top.sv
      * The test bench having simple sanity test for testing the bridge including the instantiations of other additive modules for testing
	which are not the part of the actual design. It also contains a state machine for the simple tests.
   
