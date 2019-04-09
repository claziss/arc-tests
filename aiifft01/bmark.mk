#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

aiifft01_c_src = \
	algotst.c \
	bmark.c
aiifft01_c_lib = \
	crc.c  heap.c  memmgr.c  printfe.c  ssubs.c  syscalls.c  \
	thal.c  therror.c  thfl.c  thlib.c  uuencode.c anytoi.c

aiifft01_c_objs = $(patsubst %.c, %.o.aii, $(aiifft01_c_src))
aiifft01_l_objs  = $(patsubst %.c, %.o.lib, $(aiifft01_c_lib))
aiifft01_arc_objs =
aiifft01_defs =  -DHEAP_SIZE=13107
aiifft01_cflags = -O3 -flto

%.o.aii: aiifft01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(aiifft01_defs) \
	$(aiifft01_cflags) -c $(incs) $< -o $@

%.o.lib: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(aiifft01_defs) \
	$(aiifft01_cflags) -c $(incs) $< -o $@

aiifft01_arc_bin = aiifft01.arc
$(aiifft01_arc_bin): $(aiifft01_c_objs) $(aiifft01_arc_objs) $(aiifft01_l_objs)
	$(ARC_LINK) $(aiifft01_c_objs) $(aiifft01_arc_objs) $(aiifft01_l_objs) \
	-o $(aiifft01_arc_bin) $(ARC_LINK_OPTS) -lm \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648 -flto

aiifft01_arc_rep = aiifft01.arc.rep
$(aiifft01_arc_rep): aiifft01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{print "Aiifft01 |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(aiifft01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(aiifft01_arc_rep)

junk += $(aiifft01_c_objs) $(aiifft01_arc_objs) $(aiifft01_l_objs) \
	$(aiifft01_host_bin) $(aiifft01_arc_bin) $(aiifft01_arc_rep)
