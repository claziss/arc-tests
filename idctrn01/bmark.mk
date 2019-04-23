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

idctrn01_c_objs = $(patsubst %.c, %.o.idc, $(idctrn01_c_src))
idctrn01_arc_objs =
idctrn01_defs =  -DHEAP_SIZE=13107
idctrn01_cflags = -O3 -flto

%.o.idc: idctrn01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(idctrn01_defs) \
	$(idctrn01_cflags) -c $(incs) $< -o $@

idctrn01_arc_bin = idctrn01.arc
$(idctrn01_arc_bin): $(idctrn01_c_objs) $(idctrn01_arc_objs) $(eembc_speed_objs)
	$(ARC_LINK) $^ \
	-o $(idctrn01_arc_bin) $(ARC_LINK_OPTS) \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648

idctrn01_arc_rep = idctrn01.arc.rep
$(idctrn01_arc_rep): idctrn01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{printf "idctrn01 | %f", $$2}' > $@
	grep -q "Failure" $< && echo -n " *" >> $@ || true
	echo "" >> $@

bmarks_arc_rep := $(filter-out $(idctrn01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(idctrn01_arc_rep)

junk += $(idctrn01_c_objs) $(idctrn01_arc_objs) \
	$(idctrn01_host_bin) $(idctrn01_arc_bin) $(idctrn01_arc_rep)
