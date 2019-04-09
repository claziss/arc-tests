#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

aifirf01_c_src = \
	algotst.c \
	bmark.c
aifirf01_c_lib = \
	crc.c  heap.c  memmgr.c  printfe.c  ssubs.c  syscalls.c  \
	thal.c  therror.c  thfl.c  thlib.c  uuencode.c anytoi.c

aifirf01_c_objs = $(patsubst %.c, %.o.aif, $(aifirf01_c_src))
aifirf01_l_objs  = $(patsubst %.c, %.o.lib, $(aifirf01_c_lib))
aifirf01_arc_objs =
aifirf01_defs =  -DHEAP_SIZE=13107
aifirf01_cflags = -O3 -flto

%.o.aif: aifirf01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(aifirf01_defs) \
	$(aifirf01_cflags) -c $(incs) $< -o $@

%.o.lib: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(aifirf01_defs) \
	$(aifirf01_cflags) -c $(incs) $< -o $@

aifirf01_arc_bin = aifirf01.arc
$(aifirf01_arc_bin): $(aifirf01_c_objs) $(aifirf01_arc_objs) $(aifirf01_l_objs)
	$(ARC_LINK) $(aifirf01_c_objs) $(aifirf01_arc_objs) $(aifirf01_l_objs) \
	-o $(aifirf01_arc_bin) $(ARC_LINK_OPTS) -lm \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648 -flto

aifirf01_arc_rep = aifirf01.arc.rep
$(aifirf01_arc_rep): aifirf01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{print "Aifirf01 |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(aifirf01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(aifirf01_arc_rep)

junk += $(aifirf01_c_objs) $(aifirf01_arc_objs) $(aifirf01_l_objs) \
	$(aifirf01_host_bin) $(aifirf01_arc_bin) $(aifirf01_arc_rep)
