#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

ttsprk01_c_src = \
	algotst.c \
	bmark.c
ttsprk01_c_lib = \
	crc.c  heap.c  memmgr.c  printfe.c  ssubs.c  syscalls.c  \
	thal.c  therror.c  thfl.c  thlib.c  uuencode.c anytoi.c

ttsprk01_c_objs = $(patsubst %.c, %.o.tts, $(ttsprk01_c_src))
ttsprk01_l_objs  = $(patsubst %.c, %.o.lib, $(ttsprk01_c_lib))
ttsprk01_arc_objs =
ttsprk01_defs =  -DHEAP_SIZE=13107
ttsprk01_cflags = -O3 -flto

%.o.tts: ttsprk01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(ttsprk01_defs) \
	$(ttsprk01_cflags) -c $(incs) $< -o $@

%.o.lib: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(ttsprk01_defs) \
	$(ttsprk01_cflags) -c $(incs) $< -o $@

ttsprk01_arc_bin = ttsprk01.arc
$(ttsprk01_arc_bin): $(ttsprk01_c_objs) $(ttsprk01_arc_objs) $(ttsprk01_l_objs)
	$(ARC_LINK) $(ttsprk01_c_objs) $(ttsprk01_arc_objs) $(ttsprk01_l_objs) \
	-o $(ttsprk01_arc_bin) $(ARC_LINK_OPTS) -lm \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648 -flto

ttsprk01_arc_rep = ttsprk01.arc.rep
$(ttsprk01_arc_rep): ttsprk01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS=":"}{print "Bitmnp01 |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(ttsprk01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(ttsprk01_arc_rep)

junk += $(ttsprk01_c_objs) $(ttsprk01_arc_objs) $(ttsprk01_l_objs) \
	$(ttsprk01_host_bin) $(ttsprk01_arc_bin) $(ttsprk01_arc_rep)
