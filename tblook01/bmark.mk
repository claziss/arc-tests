#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

tblook01_c_src = \
	algotst.c \
	bmark.c
tblook01_c_lib = \
	crc.c  heap.c  memmgr.c  printfe.c  ssubs.c  syscalls.c  \
	thal.c  therror.c  thfl.c  thlib.c  uuencode.c anytoi.c

tblook01_c_objs = $(patsubst %.c, %.o.tbl, $(tblook01_c_src))
tblook01_l_objs  = $(patsubst %.c, %.o.lib, $(tblook01_c_lib))
tblook01_arc_objs =
tblook01_defs =  -DHEAP_SIZE=13107
tblook01_cflags = -O3 -flto

%.o.tbl: tblook01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(tblook01_defs) \
	$(tblook01_cflags) -c $(incs) $< -o $@

%.o.lib: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(tblook01_defs) \
	$(tblook01_cflags) -c $(incs) $< -o $@

tblook01_arc_bin = tblook01.arc
$(tblook01_arc_bin): $(tblook01_c_objs) $(tblook01_arc_objs) $(tblook01_l_objs)
	$(ARC_LINK) $(tblook01_c_objs) $(tblook01_arc_objs) $(tblook01_l_objs) \
	-o $(tblook01_arc_bin) $(ARC_LINK_OPTS) -lm \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648 -flto

tblook01_arc_rep = tblook01.arc.rep
$(tblook01_arc_rep): tblook01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{print "tblook01 |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(tblook01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(tblook01_arc_rep)

junk += $(tblook01_c_objs) $(tblook01_arc_objs) $(tblook01_l_objs) \
	$(tblook01_host_bin) $(tblook01_arc_bin) $(tblook01_arc_rep)
