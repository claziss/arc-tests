#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

idctrn01_c_src = \
	algotst.c \
	bmark.c
idctrn01_c_lib = \
	crc.c  heap.c  memmgr.c  printfe.c  ssubs.c  syscalls.c  \
	thal.c  therror.c  thfl.c  thlib.c  uuencode.c anytoi.c

idctrn01_c_objs = $(patsubst %.c, %.o.idc, $(idctrn01_c_src))
idctrn01_l_objs  = $(patsubst %.c, %.o.lib, $(idctrn01_c_lib))
idctrn01_arc_objs =
idctrn01_defs =  -DHEAP_SIZE=13107
idctrn01_cflags = -O3 -flto

%.o.idc: idctrn01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(idctrn01_defs) \
	$(idctrn01_cflags) -c $(incs) $< -o $@

%.o.lib: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(idctrn01_defs) \
	$(idctrn01_cflags) -c $(incs) $< -o $@

idctrn01_arc_bin = idctrn01.arc
$(idctrn01_arc_bin): $(idctrn01_c_objs) $(idctrn01_arc_objs) $(idctrn01_l_objs)
	$(ARC_LINK) $(idctrn01_c_objs) $(idctrn01_arc_objs) $(idctrn01_l_objs) \
	-o $(idctrn01_arc_bin) $(ARC_LINK_OPTS) -lm \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648 -flto

idctrn01_arc_rep = idctrn01.arc.rep
$(idctrn01_arc_rep): idctrn01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{print "idctrn01 |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(idctrn01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(idctrn01_arc_rep)

junk += $(idctrn01_c_objs) $(idctrn01_arc_objs) $(idctrn01_l_objs) \
	$(idctrn01_host_bin) $(idctrn01_arc_bin) $(idctrn01_arc_rep)
