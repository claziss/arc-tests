#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

empty_c_src = \
	bmark.c

empty_c_objs   = $(patsubst %.c, %.o.emp, $(empty_c_src))
empty_arc_objs =
empty_defs = -DITERATIONS=10 -DHEAP_SIZE=13107
empty_cflags = -O3 -flto -ffast-math

%.o.emp: empty/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(empty_defs) \
	$(empty_cflags) -c $(incs) $< -o $@

empty_arc_bin = empty.arc
$(empty_arc_bin): $(empty_c_objs) $(empty_arc_objs) $(eembc_speed_objs)
	$(ARC_LINK) $^ \
	-o $(empty_arc_bin) $(ARC_LINK_OPTS) \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648

empty_arc_rep = empty.arc.rep
$(empty_arc_rep): empty.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{printf "Empty | %f", $$2}' > $@
	grep -q "Failure" $< && echo -n " *" >> $@ || true
	echo "" >> $@

bmarks_arc_rep := $(filter-out $(empty_arc_rep), $(bmarks_arc_rep))
extra_reports += $(empty_arc_rep)

junk += $(empty_c_objs) $(empty_arc_objs) \
	$(empty_arc_bin) $(empty_arc_rep)
