#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which 
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include 
# the benchmark name as a prefix so that they are unique.
#

multiply_c_src = \
	multiply_main.c \
	multiply.c \
	syscalls.c \

multiply_arc_src =

multiply_c_objs     = $(patsubst %.c, %.o, $(multiply_c_src))
multiply_arc_objs = $(patsubst %.S, %.o, $(multiply_arc_src))

multiply_host_bin = multiply.host
$(multiply_host_bin): $(multiply_c_src)
	$(HOST_COMP) $^ -o $(multiply_host_bin)

multiply_arc_bin = multiply.arc
$(multiply_arc_bin): $(multiply_c_objs) $(multiply_arc_objs)
	$(ARC_LINK) $(multiply_c_objs) $(multiply_arc_objs) -o $(multiply_arc_bin) $(ARC_LINK_OPTS)

junk += $(multiply_c_objs) $(multiply_arc_objs) \
        $(multiply_host_bin) $(multiply_arc_bin)
