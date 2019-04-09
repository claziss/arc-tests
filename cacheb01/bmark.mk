#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

cacheb01_c_src = \
	algotst.c \
	bmark.c
cacheb01_c_lib = \
	crc.c  heap.c  memmgr.c  printfe.c  ssubs.c  syscalls.c  \
	thal.c  therror.c  thfl.c  thlib.c  uuencode.c anytoi.c

cacheb01_c_objs = $(patsubst %.c, %.o.cac, $(cacheb01_c_src))
cacheb01_l_objs  = $(patsubst %.c, %.o.lib, $(cacheb01_c_lib))
cacheb01_arc_objs =
cacheb01_defs =  -DHEAP_SIZE=13107
cacheb01_cflags = -O3 -flto

%.o.cac: cacheb01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(cacheb01_defs) \
	$(cacheb01_cflags) -c $(incs) $< -o $@

%.o.lib: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(cacheb01_defs) \
	$(cacheb01_cflags) -c $(incs) $< -o $@

cacheb01_arc_bin = cacheb01.arc
$(cacheb01_arc_bin): $(cacheb01_c_objs) $(cacheb01_arc_objs) $(cacheb01_l_objs)
	$(ARC_LINK) $(cacheb01_c_objs) $(cacheb01_arc_objs) $(cacheb01_l_objs) \
	-o $(cacheb01_arc_bin) $(ARC_LINK_OPTS) -lm \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648 -flto

cacheb01_arc_rep = cacheb01.arc.rep
$(cacheb01_arc_rep): cacheb01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS=":"}{print "Cacheb01 |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(cacheb01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(cacheb01_arc_rep)

junk += $(cacheb01_c_objs) $(cacheb01_arc_objs) $(cacheb01_l_objs) \
	$(cacheb01_host_bin) $(cacheb01_arc_bin) $(cacheb01_arc_rep)
