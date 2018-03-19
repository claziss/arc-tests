#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

cachebench_c_src = \
	cachebench.c

cachebench_arc_src =

cachebench_c_objs   = $(patsubst %.c, %.o.cb, $(cachebench_c_src))
cachebench_arc_objs = $(patsubst %.S, %.o, $(cachebench_arc_src))
cachebench_defs     = -DUSE_INT

%.o.cb: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(cachebench_defs) \
	$(cachebench_cflags) -c $(incs) $< -o $@

cachebench_host_bin = cachebench.host
$(cachebench_host_bin) : $(cachebench_c_src)
	$(HOST_COMP) $^ -o $(cachebench_host_bin)

cachebench_arc_bin = cachebench.arc
$(cachebench_arc_bin) : $(cachebench_c_objs) $(cachebench_arc_objs)
	$(ARC_LINK) $(cachebench_c_objs) $(cachebench_arc_objs) \
	-o $(cachebench_arc_bin) $(ARC_LINK_OPTS)

cachebench_arc_rep = cachebench.arc.rep
$(cachebench_arc_rep): cachebench.arc.out
	grep -Poh "1024\s+(\d+.\d+)\s" $< | \
	awk 'BEGIN{FS=" "}{print "Cachebench |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(cachebench_arc_rep), $(bmarks_arc_rep))
extra_reports += $(cachebench_arc_rep)

junk += $(cachebench_c_objs) $(cachebench_arc_objs) $(cachebench_arc_rep)\
        $(cachebench_host_bin) $(cachebench_arc_bin)
