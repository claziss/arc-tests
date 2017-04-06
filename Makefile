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

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

ARCH = av2hs
CPU = hs4xd
SIM = ncam

HOST_OPTS = -std=gnu99 -DPREALLOCATE=0 -DHOST_DEBUG=1
HOST_COMP = gcc $(HOST_OPTS)

ARC_PREFIX ?= arc-elf32-
ARC_GCC ?= $(ARC_PREFIX)gcc
ARC_GCC_OPTS ?= -std=gnu99 -O3 -ffast-math -fno-common -fno-builtin-printf\
	 -mcpu=$(CPU)
ARC_LINK ?= $(ARC_GCC) $(incs)

ARC_LINK_OPTS ?= --specs=nsim.specs
ifeq ($(ARCH),av2hs)
ARC_LINK_OPTS += -Wl,--section-start,.data=0x80000000 -Wl,--whole-archive \
	${HOSTLINK_PATH}/archs/libhlt.a -Wl,--no-whole-archive
else
ARC_LINK_OPTS += -Wl,--whole-archive \
	${HOSTLINK_PATH}/arcem/libhlt.a -Wl,--no-whole-archive
endif

ARC_OBJDUMP ?= $(ARC_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text \
	--section=.text.startup --section=.data

ifeq ($(SIM),xcam)
ARC_SIM ?= mdb -arcint=rascalint,rascal_env=$(RASCAL_ENV) -notrace -noprofile -run
else
ARC_SIM ?= $(NSIM_HOME)/bin/nsimdrv -tcf $(src_dir)/common/intel_mcc_bench.tcf \
	-prop=nsim_isa_family=av2hs  \
	-prop=nsim_isa_core=4 -on=nsim_ncam_experimental_option \
        -on=nsim_print_stats_on_exit -on=nsim_profile=1 \
	$(NSIM_EXTRA)
endif

VPATH += $(addprefix $(src_dir)/, $(bmarks))
VPATH += $(src_dir)/common

incs  +=  -I$(src_dir)/common $(addprefix -I$(src_dir)/, $(bmarks))
objs  :=
extra_reports =

bmarks_arc_bin  = $(addsuffix .arc,  $(bmarks))
bmarks_arc_dump = $(addsuffix .arc.dump, $(bmarks))
bmarks_arc_out  = $(addsuffix .arc.out,  $(bmarks))
bmarks_arc_rep  = $(addsuffix .arc.rep,  $(bmarks))

include $(patsubst %, $(src_dir)/%/bmark.mk, $(bmarks))

bmarks_defs   = -DHOST_DEBUG=0
bmarks_cycles = 80000

#------------------------------------------------------------
# Build and run benchmarks on arc simulator

$(bmarks_arc_dump): %.arc.dump: %.arc
	$(ARC_OBJDUMP) $< > $@

$(bmarks_arc_out): %.arc.out: %.arc
	$(ARC_SIM) $< &> $@

$(bmarks_arc_rep): %.arc.rep: %.arc
	grep "User time" $(basename $@).out | \
	awk '{gsub(/,/,"");print "$(basename $@) | " $$3}' > $@

%.o: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) \
	             -c $(incs) $< -o $@

%.o: %.S %.s
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) -D__ASSEMBLY__=1 \
	             -c $(incs) $< -o $@

arc: $(bmarks_arc_dump)
run: $(bmarks_arc_out)
	echo; grep CPI $(bmarks_arc_out); echo;
reports: $(bmarks_arc_rep) $(extra_reports)
	cat *.rep

junk += $(bmarks_arc_bin) $(bmarks_arc_dump) $(bmarks_arc_hex) $(bmarks_arc_out)
junk += $(bmarks_arc_rep)

#------------------------------------------------------------
# Default

all: arc

#------------------------------------------------------------
# Install

date_suffix = $(shell date +%Y-%m-%d_%H-%M)
install_dir = $(instbasedir)/$(instname)-$(date_suffix)
latest_install = $(shell ls -1 -d $(instbasedir)/$(instname)* | tail -n 1)

install: $(bmarks_arc_out)
	mkdir $(install_dir)
	cp -r $(bmarks_arc_bin) $(bmarks_arc_out) $(install_dir)

install-link:
	rm -rf $(instbasedir)/$(instname)
	ln -s $(latest_install) $(instbasedir)/$(instname)

#------------------------------------------------------------
# Clean up

clean:
	rm -rf $(objs) $(junk)
