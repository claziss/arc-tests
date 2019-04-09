#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

pntrch01_c_src = \
	algotst.c \
	bmark.c
pntrch01_c_lib = \
	crc.c  heap.c  memmgr.c  printfe.c  ssubs.c  syscalls.c  \
	thal.c  therror.c  thfl.c  thlib.c  uuencode.c anytoi.c

pntrch01_c_objs = $(patsubst %.c, %.o.pnt, $(pntrch01_c_src))
pntrch01_l_objs  = $(patsubst %.c, %.o.lib, $(pntrch01_c_lib))
pntrch01_arc_objs =
pntrch01_defs =  -DHEAP_SIZE=13107
pntrch01_cflags = -O3 -flto

%.o.pnt: pntrch01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(pntrch01_defs) \
	$(pntrch01_cflags) -c $(incs) $< -o $@

%.o.lib: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(pntrch01_defs) \
	$(pntrch01_cflags) -c $(incs) $< -o $@

pntrch01_arc_bin = pntrch01.arc
$(pntrch01_arc_bin): $(pntrch01_c_objs) $(pntrch01_arc_objs) $(pntrch01_l_objs)
	$(ARC_LINK) $(pntrch01_c_objs) $(pntrch01_arc_objs) $(pntrch01_l_objs) \
	-o $(pntrch01_arc_bin) $(ARC_LINK_OPTS) -lm \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648 -flto

pntrch01_arc_rep = pntrch01.arc.rep
$(pntrch01_arc_rep): pntrch01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS=":"}{print "Bitmnp01 |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(pntrch01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(pntrch01_arc_rep)

junk += $(pntrch01_c_objs) $(pntrch01_arc_objs) $(pntrch01_l_objs) \
	$(pntrch01_host_bin) $(pntrch01_arc_bin) $(pntrch01_arc_rep)
