#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

iirflt01_c_src = \
	algotst.c \
	bmark.c
iirflt01_c_lib = \
	crc.c  heap.c  memmgr.c  printfe.c  ssubs.c  syscalls.c  \
	thal.c  therror.c  thfl.c  thlib.c  uuencode.c anytoi.c

iirflt01_c_objs = $(patsubst %.c, %.o.iir, $(iirflt01_c_src))
iirflt01_l_objs  = $(patsubst %.c, %.o.lib, $(iirflt01_c_lib))
iirflt01_arc_objs =
iirflt01_defs =  -DHEAP_SIZE=13107
iirflt01_cflags = -O3 -flto

%.o.iir: iirflt01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(iirflt01_defs) \
	$(iirflt01_cflags) -c $(incs) $< -o $@

%.o.lib: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(iirflt01_defs) \
	$(iirflt01_cflags) -c $(incs) $< -o $@

iirflt01_arc_bin = iirflt01.arc
$(iirflt01_arc_bin): $(iirflt01_c_objs) $(iirflt01_arc_objs) $(iirflt01_l_objs)
	$(ARC_LINK) $(iirflt01_c_objs) $(iirflt01_arc_objs) $(iirflt01_l_objs) \
	-o $(iirflt01_arc_bin) $(ARC_LINK_OPTS) -lm \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648 -flto

iirflt01_arc_rep = iirflt01.arc.rep
$(iirflt01_arc_rep): iirflt01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{print "iirflt01 |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(iirflt01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(iirflt01_arc_rep)

junk += $(iirflt01_c_objs) $(iirflt01_arc_objs) $(iirflt01_l_objs) \
	$(iirflt01_host_bin) $(iirflt01_arc_bin) $(iirflt01_arc_rep)
