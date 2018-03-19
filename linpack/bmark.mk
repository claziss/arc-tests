#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

linpack_c_src = \
	linpack-pc.c

linpack_arc_src =

linpack_c_objs   = $(patsubst %.c, %.o.lp, $(linpack_c_src))
linpack_arc_objs = $(patsubst %.S, %.o, $(linpack_arc_src))
linpack_defs = -DSP -DROLL
linpack_cflags =

%.o.lp: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(linpack_defs) \
	$(linpack_cflags) -c $(incs) $< -o $@

linpack_host_bin = linpack.host
$(linpack_host_bin) : $(linpack_c_src)
	$(HOST_COMP) $^ -o $(linpack_host_bin)

linpack_arc_bin = linpack.arc
$(linpack_arc_bin) : $(linpack_c_objs) $(linpack_arc_objs)
	$(ARC_LINK) $(linpack_c_objs) $(linpack_arc_objs) \
	-o $(linpack_arc_bin) $(ARC_LINK_OPTS)

linpack_arc_rep = linpack.arc.rep
$(linpack_arc_rep): linpack.arc.out
	grep "Rolled Single  Precision" $< | \
	awk 'BEGIN{FS=" "}{print "Linpack |", $$4}' > $@

bmarks_arc_rep := $(filter-out $(linpack_arc_rep), $(bmarks_arc_rep))
extra_reports += $(linpack_arc_rep)

junk += $(linpack_c_objs) $(linpack_arc_objs) $(linpack_arc_rep) \
        $(linpack_host_bin) $(linpack_arc_bin)
