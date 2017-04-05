#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

median_c_src = \
	median_main.c \
	median.c \
	syscalls.c \

median_arc_src =

median_c_objs     = $(patsubst %.c, %.o, $(median_c_src))
median_arc_objs = $(patsubst %.S, %.o, $(median_arc_src))

median_host_bin = median.host
$(median_host_bin): $(median_c_src)
	$(HOST_COMP) $^ -o $(median_host_bin)

median_arc_bin = median.arc
$(median_arc_bin): $(median_c_objs) $(median_arc_objs)
	$(ARC_LINK) $(median_c_objs) $(median_arc_objs) -o $(median_arc_bin) $(ARC_LINK_OPTS)

junk += $(median_c_objs) $(median_arc_objs) \
        $(median_host_bin) $(median_arc_bin)
