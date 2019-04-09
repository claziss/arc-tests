#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

canrdr01_c_src = \
	algotst.c \
	bmark.c
canrdr01_c_lib = \
	crc.c  heap.c  memmgr.c  printfe.c  ssubs.c  syscalls.c  \
	thal.c  therror.c  thfl.c  thlib.c  uuencode.c anytoi.c

canrdr01_c_objs = $(patsubst %.c, %.o.can, $(canrdr01_c_src))
canrdr01_l_objs  = $(patsubst %.c, %.o.lib, $(canrdr01_c_lib))
canrdr01_arc_objs =
canrdr01_defs =  -DHEAP_SIZE=13107
canrdr01_cflags = -O3 -flto

%.o.can: canrdr01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(canrdr01_defs) \
	$(canrdr01_cflags) -c $(incs) $< -o $@

%.o.lib: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(canrdr01_defs) \
	$(canrdr01_cflags) -c $(incs) $< -o $@

canrdr01_arc_bin = canrdr01.arc
$(canrdr01_arc_bin): $(canrdr01_c_objs) $(canrdr01_arc_objs) $(canrdr01_l_objs)
	$(ARC_LINK) $(canrdr01_c_objs) $(canrdr01_arc_objs) $(canrdr01_l_objs) \
	-o $(canrdr01_arc_bin) $(ARC_LINK_OPTS) -lm \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648 -flto

canrdr01_arc_rep = canrdr01.arc.rep
$(canrdr01_arc_rep): canrdr01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{print "canrdr01 |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(canrdr01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(canrdr01_arc_rep)

junk += $(canrdr01_c_objs) $(canrdr01_arc_objs) $(canrdr01_l_objs) \
	$(canrdr01_host_bin) $(canrdr01_arc_bin) $(canrdr01_arc_rep)
