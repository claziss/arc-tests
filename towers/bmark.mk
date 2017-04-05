#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

towers_c_src = \
	towers_main.c \
	syscalls.c \

towers_arc_src =

towers_c_objs     = $(patsubst %.c, %.o, $(towers_c_src))
towers_arc_objs = $(patsubst %.S, %.o, $(towers_arc_src))

towers_host_bin = towers.host
$(towers_host_bin) : $(towers_c_src)
	$(HOST_COMP) $^ -o $(towers_host_bin)

towers_arc_bin = towers.arc
$(towers_arc_bin) : $(towers_c_objs) $(towers_arc_objs)
	$(ARC_LINK) $(towers_c_objs) $(towers_arc_objs) -o $(towers_arc_bin) $(ARC_LINK_OPTS)

junk += $(towers_c_objs) $(towers_arc_objs) \
        $(towers_host_bin) $(towers_arc_bin)
