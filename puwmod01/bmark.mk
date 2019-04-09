#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

puwmod01_c_src = \
	algotst.c \
	bmark.c
puwmod01_c_lib = \
	crc.c  heap.c  memmgr.c  printfe.c  ssubs.c  syscalls.c  \
	thal.c  therror.c  thfl.c  thlib.c  uuencode.c anytoi.c

puwmod01_c_objs = $(patsubst %.c, %.o.puw, $(puwmod01_c_src))
puwmod01_l_objs  = $(patsubst %.c, %.o.lib, $(puwmod01_c_lib))
puwmod01_arc_objs =
puwmod01_defs =  -DHEAP_SIZE=13107
puwmod01_cflags = -O3 -flto

%.o.puw: puwmod01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(puwmod01_defs) \
	$(puwmod01_cflags) -c $(incs) $< -o $@

%.o.lib: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(puwmod01_defs) \
	$(puwmod01_cflags) -c $(incs) $< -o $@

puwmod01_arc_bin = puwmod01.arc
$(puwmod01_arc_bin): $(puwmod01_c_objs) $(puwmod01_arc_objs) $(puwmod01_l_objs)
	$(ARC_LINK) $(puwmod01_c_objs) $(puwmod01_arc_objs) $(puwmod01_l_objs) \
	-o $(puwmod01_arc_bin) $(ARC_LINK_OPTS) -lm \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648 -flto

puwmod01_arc_rep = puwmod01.arc.rep
$(puwmod01_arc_rep): puwmod01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{print "puwmod01 |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(puwmod01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(puwmod01_arc_rep)

junk += $(puwmod01_c_objs) $(puwmod01_arc_objs) $(puwmod01_l_objs) \
	$(puwmod01_host_bin) $(puwmod01_arc_bin) $(puwmod01_arc_rep)
