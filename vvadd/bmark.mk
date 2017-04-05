#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

vvadd_c_src = \
	vvadd_main.c \
	syscalls.c \

vvadd_arc_src =

vvadd_c_objs     = $(patsubst %.c, %.o, $(vvadd_c_src))
vvadd_arc_objs = $(patsubst %.S, %.o, $(vvadd_arc_src))

vvadd_host_bin = vvadd.host
$(vvadd_host_bin) : $(vvadd_c_src)
	$(HOST_COMP) $^ -o $(vvadd_host_bin)

vvadd_arc_bin = vvadd.arc
$(vvadd_arc_bin) : $(vvadd_c_objs) $(vvadd_arc_objs)
	$(ARC_LINK) $(vvadd_c_objs) $(vvadd_arc_objs) -o $(vvadd_arc_bin) $(ARC_LINK_OPTS)

junk += $(vvadd_c_objs) $(vvadd_arc_objs) \
        $(vvadd_host_bin) $(vvadd_arc_bin)
