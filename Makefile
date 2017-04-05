#=======================================================================
# UCB VLSI FLOW: Makefile for riscv-bmarks
#-----------------------------------------------------------------------
# Yunsup Lee (yunsup@cs.berkeley.edu)
#

default: all

src_dir = .

instname = arc-bmarks
instbasedir = install

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

bmarks = \
	median \
	qsort \
	rsort \
	towers \
	vvadd \
	multiply \
	dhrystone\
	spmv \
	coremark

bmarks_host = \
	median \
	qsort \
	towers \
	vvadd \
	multiply \
	spmv \
	vec-vvadd \
	vec-cmplxmult \
	vec-matmul \

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

HOST_OPTS = -std=gnu99 -DPREALLOCATE=0 -DHOST_DEBUG=1
HOST_COMP = gcc $(HOST_OPTS)

ARC_PREFIX ?= arc-elf32-
ARC_GCC ?= $(ARC_PREFIX)gcc
ARC_GCC_OPTS ?= -std=gnu99 -O3 -ffast-math -fno-common -fno-builtin-printf --specs=nsim.specs\
	-fno-tree-loop-ivcanon -fno-gcse -frename-registers -funroll-all-loops \
        -funroll-loops -fira-region=all -fira-loop-pressure -fno-cse-follow-jumps \
	-fno-toplevel-reorder --param max-unroll-times=10000 --param max-unrolled-insns=10000 \
	-fsched-pressure -fno-branch-count-reg -mcpu=hs4xd
ARC_LINK ?= $(ARC_GCC)  --specs=nsim.specs $(incs)
#ARC_LINK_MT ?= $(ARC_GCC) -T $(src_dir)/common/test-mt.ld
ARC_LINK_OPTS ?= -Wl,--whole-archive ${HOSTLINK_PATH}/archs/libhlt.a \
	-Wl,--no-whole-archive -Wl,--section-start,.data=0x80000000
ARC_OBJDUMP ?= $(ARC_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.data
ARC_SIM ?= $(NSIM_HOME)/bin/nsimdrv -tcf $(src_dir)/common/intel_mcc_bench.tcf \
	-prop=nsim_isa_family=av2hs  \
	-prop=nsim_isa_core=4 -on=nsim_ncam_experimental_option \
        -on=nsim_print_stats_on_exit -on=nsim_profile=1
#  -on nsim_emt   -on=nsim_trace -on=nsim_trace-ncam -prop=nsim_trace-output=trace.txt \

VPATH += $(addprefix $(src_dir)/, $(bmarks))
VPATH += $(src_dir)/common

#incs  += -I$(src_dir)/../env -I$(src_dir)/common $(addprefix -I$(src_dir)/, $(bmarks))
incs  +=  -I$(src_dir)/common $(addprefix -I$(src_dir)/, $(bmarks))
objs  :=

include $(patsubst %, $(src_dir)/%/bmark.mk, $(bmarks))

#------------------------------------------------------------
# Build and run benchmarks on arc simulator

bmarks_arc_bin  = $(addsuffix .arc,  $(bmarks))
bmarks_arc_dump = $(addsuffix .arc.dump, $(bmarks))
bmarks_arc_out  = $(addsuffix .arc.out,  $(bmarks))

bmarks_defs   = -DHOST_DEBUG=0 -DITERATIONS=10000 -DMSC_CLOCK \
	-DCLOCKS_PER_SEC=1000000 -DPERFORMANCE_RUN=1 -DITERATIONS=50
bmarks_cycles = 80000

$(bmarks_arc_dump): %.arc.dump: %.arc
	$(ARC_OBJDUMP) $< > $@

$(bmarks_arc_out): %.arc.out: %.arc
	$(ARC_SIM) $< &> $@

%.o: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) \
	             -c $(incs) $< -o $@

%.o: %.S
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) -D__ASSEMBLY__=1 \
	             -c $(incs) $< -o $@

arc: $(bmarks_arc_dump)
run-arc: $(bmarks_arc_out)
	echo; grep CPI \
	       $(bmarks_arc_out); echo;

junk += $(bmarks_arc_bin) $(bmarks_arc_dump) $(bmarks_arc_hex) $(bmarks_arc_out)

#------------------------------------------------------------
# Build and run benchmarks on host machine

bmarks_host_bin = $(addsuffix .host, $(bmarks_host))
bmarks_host_out = $(addsuffix .host.out, $(bmarks_host))

$(bmarks_host_out): %.host.out: %.host
	./$< > $@

host: $(bmarks_host_bin)
run-host: $(bmarks_host_out)
	echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
	       $(bmarks_host_out); echo;

junk += $(bmarks_host_bin) $(bmarks_host_out)

#------------------------------------------------------------
# Default

all: arc

#------------------------------------------------------------
# Install

date_suffix = $(shell date +%Y-%m-%d_%H-%M)
install_dir = $(instbasedir)/$(instname)-$(date_suffix)
latest_install = $(shell ls -1 -d $(instbasedir)/$(instname)* | tail -n 1)

install:
	mkdir $(install_dir)
	cp -r $(bmarks_arc_bin) $(bmarks_arc_dump) $(install_dir)

install-link:
	rm -rf $(instbasedir)/$(instname)
	ln -s $(latest_install) $(instbasedir)/$(instname)

#------------------------------------------------------------
# Clean up

clean:
	rm -rf $(objs) $(junk)
