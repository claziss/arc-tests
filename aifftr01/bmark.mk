#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

aifftr01_c_src = \
	algotst.c \
	bmark.c
aifftr01_c_lib = \
	crc.c  heap.c  memmgr.c  printfe.c  ssubs.c  syscalls.c  \
	thal.c  therror.c  thfl.c  thlib.c  uuencode.c anytoi.c

aifftr01_c_objs = $(patsubst %.c, %.o, $(aifftr01_c_src))
aifftr01_l_objs  = $(patsubst %.c, %.o.lib, $(aifftr01_c_lib))
aifftr01_arc_objs =
aifftr01_defs = -DHEAP_SIZE=13107
aifftr01_cflags = -O3 -flto

%.o: aifftr01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(aifftr01_defs) \
	$(aifftr01_cflags) -c $(incs) $< -o $@

%.o.lib: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(aifftr01_defs) \
	$(aifftr01_cflags) -c $(incs) $< -o $@

aifftr01_arc_bin = aifftr01.arc
$(aifftr01_arc_bin): $(aifftr01_c_objs) $(aifftr01_arc_objs) $(aifftr01_l_objs)
	$(ARC_LINK) $(aifftr01_c_objs) $(aifftr01_arc_objs) $(aifftr01_l_objs) \
	-o $(aifftr01_arc_bin) $(ARC_LINK_OPTS) -lm \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648 -flto

aifftr01_arc_rep = aifftr01.arc.rep
$(aifftr01_arc_rep): aifftr01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS=":"}{print "Aifftr01 |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(aifftr01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(aifftr01_arc_rep)

junk += $(aifftr01_c_objs) $(aifftr01_arc_objs) $(aifftr01_l_objs) \
	$(aifftr01_host_bin) $(aifftr01_arc_bin) $(aifftr01_arc_rep)
