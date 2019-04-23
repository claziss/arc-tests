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
	whetstone \
	whetstoneDP \
	searchgame \
	cachebench \
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

ARC_PREFIX ?= arc-elf32-
ARC_GCC ?= $(ARC_PREFIX)gcc
ARC_GCC_OPTS ?= -std=gnu99 -O3 -ffast-math -fno-common -fno-builtin-printf\
	 -mcpu=$(CPU) -flto
#	-march=rv32imc -flto
ARC_LINK ?= $(ARC_GCC) $(incs)

ARC_LINK_OPTS ?= --specs=nsim.specs -mcpu=$(CPU) -flto -lm
ifeq ($(ARCH),av2hs)
#ARC_LINK_OPTS += -Wl,--section-start,.data=0x80000000 -Wl,--whole-archive \
#	${HOSTLINK_PATH}/archs/libhlt.a -Wl,--no-whole-archive
else
#ARC_LINK_OPTS += -Wl,--whole-archive \
#	${HOSTLINK_PATH}/arcem/libhlt.a -Wl,--no-whole-archive
endif

ARC_OBJDUMP ?= $(ARC_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text \
	--section=.text.startup --section=.data

ARC_SIZE ?= $(ARC_PREFIX)size -G

ifeq ($(SIM),xcam)
ARC_SIM ?= mdb -arcint=rascalint,rascal_env=$(RASCAL_ENV) -notrace -noprofile -run
else
ARC_SIM ?= $(NSIM_HOME)/bin/nsimdrv -tcf $(src_dir)/common/intel_mcc_bench.tcf \
	-prop=nsim_isa_family=av2hs  \
	-prop=nsim_isa_core=4 -on=nsim_ncam_experimental_option \
        -on=nsim_print_stats_on_exit -on=nsim_profile=1 \
	$(NSIM_EXTRA)
bmarks += linpack \
	a2time01 \
	aifftr01 \
	aifirf01 \
	aiifft01 \
	basefp01 \
	bitmnp01 \
	cacheb01 \
	canrdr01 \
	idctrn01 \
	iirflt01 \
	matrix01 \
	pntrch01 \
	puwmod01 \
	rspeed01 \
	tblook01 \
	ttsprk01
endif

# EEMBC support files.
eembc_c_lib = \
	crc.c  heap.c  memmgr.c  printfe.c  ssubs.c  syscalls.c  \
	thal.c  therror.c  thfl.c  thlib.c  uuencode.c anytoi.c

eembc_speed_objs  = $(patsubst %.c, %.o.lib, $(eembc_c_lib))

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

bmarks_defs   = -DHOST_DEBUG=0 -DHEAP_SIZE=13107

#------------------------------------------------------------
# Build and run benchmarks on arc simulator

$(bmarks_arc_dump): %.arc.dump: %.arc
	$(ARC_OBJDUMP) $< > $@

$(bmarks_arc_out): %.arc.out: %.arc
	$(ARC_SIM) $< &> $@

$(bmarks_arc_rep): %.arc.rep: %.arc
	grep "User time" $(basename $@).out | \
	awk '{gsub(/,/,"");print "$(basename $@) | " $$6/$$3}' > $@ ; \
	grep -q "Failure" $(basename $@).out && echo -n " *" >> $@ || true

%.o.lib: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) -c $(incs) $< -o $@


%.o: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) \
	             -c $(incs) $< -o $@

%.o: %.S %.s
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) -D__ASSEMBLY__=1 \
	             -c $(incs) $< -o $@

arc: $(bmarks_arc_dump)
run: $(bmarks_arc_out)
	echo; grep CPI $(bmarks_arc_out); echo;
reports: $(bmarks_arc_out) $(bmarks_arc_rep) $(extra_reports)
	cat *.arc.rep

junk += $(bmarks_arc_bin) $(bmarks_arc_dump) $(bmarks_arc_hex) $(bmarks_arc_out)
junk += $(bmarks_arc_rep) $(eembc_speed_objs)

#------------------------------------------------------------
# Default

all: arc

#------------------------------------------------------------
# Build and run benchmarks for size
bmarks_size = \
	a2time01 \
	aifftr01 \
	aifirf01 \
	aiifft01 \
	basefp01 \
	bitmnp01 \
	cacheb01 \
	canrdr01 \
	idctrn01 \
	iirflt01 \
	matrix01 \
	pntrch01 \
	puwmod01 \
	rspeed01 \
	tblook01 \
	ttsprk01

size_cflags = -Os -flto  -fdata-sections -ffunction-sections \
	-Wa,-mlinker-relax
size_lflags = -flto  -Wl,-gc-sections -Wl,-relax

eembc_l_objs  = $(patsubst %.c, %.o.slib, $(eembc_c_lib))

%.o.slib: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) -DHEAP_SIZE=13107 \
	$(size_cflags) -c $(incs) $< -o $@

define compile_template
$(1).arc.size: $(wildcard $(src_dir)/$(1)/*.c) $$(eembc_l_objs)
	$$(ARC_GCC) $$(ARC_GCC_OPTS) $$(bmarks_defs) \
	$$($(1)_defs) $$(size_cflags) $$(incs) \
	$$^ \
	-o $$@ $$(size_lflags) $$(ARC_LINK_OPTS) \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648 -lm
endef

$(foreach bmark,$(bmarks_size),$(eval $(call compile_template,$(bmark))))

bmarks_size_bin = $(addsuffix .arc.size, $(bmarks_size))
bmarks_size_out = $(addsuffix .arc.size.out, $(bmarks_size))
bmarks_size_rep = $(addsuffix .arc.size.rep, $(bmarks_size))

$(bmarks_size_out): %.size.out: %.size
	$(ARC_SIM) $< &> $@

$(bmarks_size_rep): %.size.rep: %.size
	$(ARC_SIZE) $< > $@

size: $(bmarks_size_bin) $(bmarks_size_rep)

run-size: $(bmarks_size_out)

report-size: $(bmarks_size_rep)
	cat *.size.rep  | grep -v "text"

junk += $(bmarks_size_bin) $(bmarks_size_out) $(bmarks_size_rep) $(eembc_l_objs)

#------------------------------------------------------------
# Install

date_suffix = $(shell date +%Y-%m-%d_%H-%M)
install_dir = $(instbasedir)/$(instname)-$(date_suffix)
latest_install = $(shell ls -1 -d $(instbasedir)/$(instname)* | tail -n 1)

install: $(bmarks_arc_out)
	mkdir -p $(install_dir)
	cp -r $(bmarks_arc_bin) $(bmarks_arc_out) $(install_dir)

install-link:
	rm -rf $(instbasedir)/$(instname)
	ln -s $(latest_install) $(instbasedir)/$(instname)

#------------------------------------------------------------
# Clean up

clean:
	rm -rf $(objs) $(junk)
