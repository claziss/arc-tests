#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

rspeed01_c_src = \
	algotst.c \
	bmark.c
rspeed01_c_lib = \
	crc.c  heap.c  memmgr.c  printfe.c  ssubs.c  syscalls.c  \
	thal.c  therror.c  thfl.c  thlib.c  uuencode.c anytoi.c

rspeed01_c_objs = $(patsubst %.c, %.o.rsp, $(rspeed01_c_src))
rspeed01_l_objs  = $(patsubst %.c, %.o.lib, $(rspeed01_c_lib))
rspeed01_arc_objs =
rspeed01_defs =  -DHEAP_SIZE=13107
rspeed01_cflags = -O3 -flto

%.o.rsp: rspeed01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(rspeed01_defs) \
	$(rspeed01_cflags) -c $(incs) $< -o $@

%.o.lib: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(rspeed01_defs) \
	$(rspeed01_cflags) -c $(incs) $< -o $@

rspeed01_arc_bin = rspeed01.arc
$(rspeed01_arc_bin): $(rspeed01_c_objs) $(rspeed01_arc_objs) $(rspeed01_l_objs)
	$(ARC_LINK) $(rspeed01_c_objs) $(rspeed01_arc_objs) $(rspeed01_l_objs) \
	-o $(rspeed01_arc_bin) $(ARC_LINK_OPTS) -lm \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648 -flto

rspeed01_arc_rep = rspeed01.arc.rep
$(rspeed01_arc_rep): rspeed01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{print "rspeed01 |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(rspeed01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(rspeed01_arc_rep)

junk += $(rspeed01_c_objs) $(rspeed01_arc_objs) $(rspeed01_l_objs) \
	$(rspeed01_host_bin) $(rspeed01_arc_bin) $(rspeed01_arc_rep)
