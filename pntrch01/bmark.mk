#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

pntrch01_c_src = \
	algotst.c \
	bmark.c

pntrch01_c_objs = $(patsubst %.c, %.o.pnt, $(pntrch01_c_src))
pntrch01_arc_objs =
pntrch01_defs =  -DHEAP_SIZE=13107
pntrch01_cflags = -O3 -flto

%.o.pnt: pntrch01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(pntrch01_defs) \
	$(pntrch01_cflags) -c $(incs) $< -o $@

pntrch01_arc_bin = pntrch01.arc
$(pntrch01_arc_bin): $(pntrch01_c_objs) $(pntrch01_arc_objs) $(eembc_speed_objs)
	$(ARC_LINK) $^ \
	-o $(pntrch01_arc_bin) $(ARC_LINK_OPTS) \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648

pntrch01_arc_rep = pntrch01.arc.rep
$(pntrch01_arc_rep): pntrch01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{printf "pntrch01 | %f", $$2}' > $@
	grep -q "Failure" $< && echo -n " *" >> $@ || true
	echo "" >> $@

bmarks_arc_rep := $(filter-out $(pntrch01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(pntrch01_arc_rep)

junk += $(pntrch01_c_objs) $(pntrch01_arc_objs) \
	$(pntrch01_host_bin) $(pntrch01_arc_bin) $(pntrch01_arc_rep)
