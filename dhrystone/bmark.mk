#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

dhrystone_c_src = \
	dhry_1.c \
	dhry_2.c \

dhrystone_arc_src =

dhrystone_c_objs     = $(patsubst %.c, %.o, $(dhrystone_c_src))
dhrystone_arc_objs = $(patsubst %.S, %.o, $(dhrystone_arc_src))

dhrystone_host_bin = dhrystone.host
$(dhrystone_host_bin): $(dhrystone_c_src)
	$(HOST_COMP) $^ -o $(dhrystone_host_bin)

dhrystone_arc_bin = dhrystone.arc
$(dhrystone_arc_bin): $(dhrystone_c_objs) $(dhrystone_arc_objs)
	$(ARC_LINK) $(dhrystone_c_objs) $(dhrystone_arc_objs) \
    -o $(dhrystone_arc_bin) $(ARC_LINK_OPTS)

junk += $(dhrystone_c_objs) $(dhrystone_arc_objs) \
        $(dhrystone_host_bin) $(dhrystone_arc_bin)
