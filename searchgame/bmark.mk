#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

searchgame_c_src = \
	SearchGame.c

searchgame_arc_src =

searchgame_c_objs     = $(patsubst %.c, %.o, $(searchgame_c_src))
searchgame_arc_objs = $(patsubst %.S, %.o, $(searchgame_arc_src))

searchgame_host_bin = searchgame.host
$(searchgame_host_bin) : $(searchgame_c_src)
	$(HOST_COMP) $^ -o $(searchgame_host_bin)

searchgame_arc_bin = searchgame.arc
$(searchgame_arc_bin) : $(searchgame_c_objs) $(searchgame_arc_objs)
	$(ARC_LINK) $(searchgame_c_objs) $(searchgame_arc_objs) \
	-o $(searchgame_arc_bin) $(ARC_LINK_OPTS)

searchgame_arc_rep = searchgame.arc.rep
$(searchgame_arc_rep): searchgame.arc.out
	grep -ohP "msec = (\d+.\d+)\s" $< | \
	awk 'BEGIN{FS="="}{print "SearchGame |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(searchgame_arc_rep), $(bmarks_arc_rep))
extra_reports += $(searchgame_arc_rep)


junk += $(searchgame_c_objs) $(searchgame_arc_objs) $(searchgame_arc_rep) \
        $(searchgame_host_bin) $(searchgame_arc_bin)
