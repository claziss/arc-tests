#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

a2time01_c_src = \
	algotst.c \
	bmark.c \
	crc.c  heap.c  memmgr.c  printfe.c  ssubs.c  syscalls.c  \
	thal.c  therror.c  thfl.c  thlib.c  uuencode.c anytoi.c

a2time01_c_objs   = $(patsubst %.c, %.o.a2t, $(a2time01_c_src))
a2time01_arc_objs =
a2time01_defs = -DITERATIONS=10 -DHEAP_SIZE=13107
a2time01_cflags = -O3 -flto

%.o.a2t: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(a2time01_defs) \
	$(a2time01_cflags) -c $(incs) $< -o $@

a2time01_arc_bin = a2time01.arc
$(a2time01_arc_bin): $(a2time01_c_objs) $(a2time01_arc_objs)
	$(ARC_LINK) $(a2time01_c_objs) $(a2time01_arc_objs) \
	-o $(a2time01_arc_bin) $(ARC_LINK_OPTS) -flto

a2time01_arc_rep = a2time01.arc.rep
$(a2time01_arc_rep): a2time01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS=":"}{print "A2time01 |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(a2time01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(a2time01_arc_rep)

junk += $(a2time01_c_objs) $(a2time01_arc_objs) \
	$(a2time01_host_bin) $(a2time01_arc_bin) $(a2time01_arc_rep)