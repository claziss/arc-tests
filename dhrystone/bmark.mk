dhrystone_c_src = dhry_1.c dhry_2.c \

dhrystone_c_objs   = $(patsubst %.c, %.o.dhry, $(dhrystone_c_src))
dhrystone_arc_objs =

dhrystone_defs     = -DITERATIONS=10000 -DMSC_CLOCK
dhrystone_cflags   = -O2  -mdiv-rem -mindexed-loads -mauto-modify-reg  \
	-fno-branch-count-reg -fno-jump-tables -fno-ivopts -fira-loop-pressure \
	-fno-gcse -frename-registers -fno-tree-dominator-opts \
	--param max-unroll-times=10000 --param max-unrolled-insns=1000 \
	-funroll-all-loops -funroll-loops -w

%.o.dhry: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(dhrystone_defs) \
	$(dhrystone_cflags) -c $(incs) $< -o $@

dhrystone_arc_bin = dhrystone.arc
$(dhrystone_arc_bin): $(dhrystone_c_objs) $(dhrystone_arc_objs)
	$(ARC_LINK) $(dhrystone_c_objs) $(dhrystone_arc_objs) \
	-o $(dhrystone_arc_bin) $(ARC_LINK_OPTS)

junk += $(dhrystone_c_objs) $(dhrystone_arc_objs)	\
	$(dhrystone_host_bin) $(dhrystone_arc_bin)
