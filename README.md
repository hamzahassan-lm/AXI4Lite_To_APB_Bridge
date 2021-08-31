# axi_apb_bridge
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
  

See the [OSVVM Verification Script Library](https://github.com/osvvm/OSVVM-Scripts) 
for a simple way to build the OSVVM libraries.

### RTL
Contains RTL for all the Modules used in the Design.

   * axi_lite_pkg.sv
      * References all packages required to use the AXI4 verification components
   * apb_master.v
      * References all packages required to use the AXI4 verification components
   * flop.v
      * References all packages required to use the AXI4 verification components
   * axi_apb_bridge.v
      * References all packages required to use the AXI4 verification components
   * APB_Slave.v
      * References all packages required to use the AXI4 verification components
   * axi_lite_if.sv
      * References all packages required to use the AXI4 verification components
   * axi_lite_master.sv
      * References all packages required to use the AXI4 verification components

