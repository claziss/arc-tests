#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

whetstoneDP_c_src = \
	whetstone.c

whetstoneDP_arc_src =

whetstoneDP_c_objs   = $(patsubst %.c, %.o.wd, $(whetstoneDP_c_src))
whetstoneDP_arc_objs = $(patsubst %.S, %.o, $(whetstoneDP_arc_src))
whetstoneDP_defs     = -DPRINTOUT -DITERATIONS=10 -DDOUBLE_FLOAT

%.o.wd: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(whetstoneDP_defs) \
	$(whetstoneDP_cflags) -c $(incs) $< -o $@

whetstoneDP_host_bin = whetstoneDP.host
$(whetstoneDP_host_bin) : $(whetstoneDP_c_src)
	$(HOST_COMP) $^ -o $(whetstoneDP_host_bin)

whetstoneDP_arc_bin = whetstoneDP.arc
$(whetstoneDP_arc_bin) : $(whetstoneDP_c_objs) $(whetstoneDP_arc_objs)
	$(ARC_LINK) $(whetstoneDP_c_objs) $(whetstoneDP_arc_objs) \
	-o $(whetstoneDP_arc_bin) $(ARC_LINK_OPTS) -lm

whetstoneDP_arc_rep = whetstoneDP.arc.rep
$(whetstoneDP_arc_rep): whetstoneDP.arc.out
	grep -ohP "Whetstones:\s(\d+.\d+)\s" $< | \
	awk 'BEGIN{FS=":"}{print "WhetstoneDP |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(whetstoneDP_arc_rep), $(bmarks_arc_rep))
extra_reports += $(whetstoneDP_arc_rep)

junk += $(whetstoneDP_c_objs) $(whetstoneDP_arc_objs) $(whetstoneDP_arc_rep) \
        $(whetstoneDP_host_bin) $(whetstoneDP_arc_bin)
