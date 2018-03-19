#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

whetstone_c_src = \
	whetstone.c

whetstone_arc_src =

whetstone_c_objs   = $(patsubst %.c, %.o.ws, $(whetstone_c_src))
whetstone_arc_objs = $(patsubst %.S, %.o, $(whetstone_arc_src))
whetstone_defs     = -DPRINTOUT -DITERATIONS=20

%.o.ws: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(whetstone_defs) \
	$(whetstone_cflags) -c $(incs) $< -o $@

whetstone_host_bin = whetstone.host
$(whetstone_host_bin) : $(whetstone_c_src)
	$(HOST_COMP) $^ -o $(whetstone_host_bin)

whetstone_arc_bin = whetstone.arc
$(whetstone_arc_bin) : $(whetstone_c_objs) $(whetstone_arc_objs)
	$(ARC_LINK) $(whetstone_c_objs) $(whetstone_arc_objs) \
	-o $(whetstone_arc_bin) $(ARC_LINK_OPTS) -lm

whetstone_arc_rep = whetstone.arc.rep
$(whetstone_arc_rep): whetstone.arc.out
	grep -Poh "Whetstones:\s(\d+.\d+)\s" $< | \
	awk 'BEGIN{FS=":"}{print "Whetstone |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(whetstone_arc_rep), $(bmarks_arc_rep))
extra_reports += $(whetstone_arc_rep)

junk += $(whetstone_c_objs) $(whetstone_arc_objs) $(whetstone_arc_rep) \
        $(whetstone_host_bin) $(whetstone_arc_bin)
