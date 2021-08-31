UVM_HOME ?= /eda_tools/vcs201809/etc/uvm-1.2
GCC_PATH   ?= /home/users/cores/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin
UVM_VERBOSITY = UVM_MEDIUM
TEST = simplealu_test

VCS =	vcs -sverilog -debug_pp -timescale=1ns/1ns -LDFLAGS -Wl,--no-as-needed \
	+acc +vpi \
	+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
	+incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm.sv \
	-cm line+cond+fsm+branch+tgl -cm_dir ./coverage.vdb \
	$(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS

SIMV = ./simv +UVM_VERBOSITY=$(UVM_VERBOSITY) \
	 +UVM_TR_RECORD +UVM_LOG_RECORD \
	+verbose=1 +ntb_random_seed=244 -l vcs.log


x:	comp run 

comp:
	$(VCS) +incdir+. tb_top.sv

run:
	$(SIMV)

clean:
	rm -rf coverage.vdb csrc DVEfiles inter.vpd simv simv.daidir ucli.key vc_hdrs.h vcs.log .inter.vpd.uvm
