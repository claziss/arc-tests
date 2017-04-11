dhrystone_c_src = dhry_1.c dhry_2.c \

dhrystone_c_objs   = $(patsubst %.c, %.o.dhry, $(dhrystone_c_src))
dhrystone_arc_objs =

dhrystone_defs     = -DITERATIONS=10000 -DMSC_CLOCK
dhrystone_cflags   = -O2  -mdiv-rem \
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

dhrystone_arc_rep = dhrystone.arc.rep
$(dhrystone_arc_rep): dhrystone.arc.out
	grep "Dhrystones per Second" $< | \
	awk 'BEGIN{FS=":"}{print "Dhrystone |", $$2/1757}' > $@

bmarks_arc_rep := $(filter-out $(dhrystone_arc_rep), $(bmarks_arc_rep))
extra_reports += $(dhrystone_arc_rep)

junk += $(dhrystone_c_objs) $(dhrystone_arc_objs)	\
	$(dhrystone_host_bin) $(dhrystone_arc_bin) $(dhrystone_arc_rep)
