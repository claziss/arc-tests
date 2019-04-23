#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

a2time01_c_src = \
	algotst.c \
	bmark.c

a2time01_c_objs   = $(patsubst %.c, %.o.a2t, $(a2time01_c_src))
a2time01_arc_objs =
a2time01_defs = -DITERATIONS=10 -DHEAP_SIZE=13107
a2time01_cflags = -O3 -flto -ffast-math

%.o.a2t: a2time01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(a2time01_defs) \
	$(a2time01_cflags) -c $(incs) $< -o $@

a2time01_arc_bin = a2time01.arc
$(a2time01_arc_bin): $(a2time01_c_objs) $(a2time01_arc_objs) $(eembc_speed_objs)
	$(ARC_LINK) $^ \
	-o $(a2time01_arc_bin) $(ARC_LINK_OPTS) \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648

a2time01_arc_rep = a2time01.arc.rep
$(a2time01_arc_rep): a2time01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{printf "A2time01 | %f", $$2}' > $@
	grep -q "Failure" $< && echo -n " *" >> $@ || true
	echo "" >> $@

bmarks_arc_rep := $(filter-out $(a2time01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(a2time01_arc_rep)

junk += $(a2time01_c_objs) $(a2time01_arc_objs) \
	$(a2time01_arc_bin) $(a2time01_arc_rep)
