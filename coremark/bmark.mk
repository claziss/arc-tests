#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

coremark_c_src = \
	core_matrix.c \
	core_list_join.c  \
	core_main.c  \
	core_portme.c \
	core_state.c \
	core_util.c

coremark_c_objs   = $(patsubst %.c, %.o.cm, $(coremark_c_src))
coremark_arc_objs =
coremark_defs = -DCLOCKS_PER_SEC=1000000 -DPERFORMANCE_RUN=1 -DITERATIONS=50
coremark_cflags = -std=gnu99 -O3 -ffast-math -fno-common -fno-builtin-printf \
	-fno-tree-loop-ivcanon -fno-gcse -frename-registers -funroll-all-loops \
        -funroll-loops -fira-region=all -fira-loop-pressure \
	-fno-cse-follow-jumps -fno-toplevel-reorder \
	--param max-unroll-times=10000 --param max-unrolled-insns=10000 \
	-fsched-pressure

ifeq ($(CPU),arcem)
dhrystone_cflags  := -mcode-density -mbarrel-shifter -mnorm -mswap \
	-O2 -fno-tree-loop-ivcanon -fgcse -frename-registers -funroll-all-loops \
        -funroll-loops -fira-region=all -fira-loop-pressure -fno-cse-follow-jumps \
        -funswitch-loops -fgcse-las -fsched-pressure -fno-sched-interblock \
        -fno-toplevel-reorder --param max-unroll-times=10000 --param max-unrolled-insns=1000 \
        --param max-pending-list-length=1000000 \
        -mauto-modify-reg -finline-functions-called-once -finline-small-functions \
	-finline-limit=500 -fno-jump-tables
endif

%.o.cm: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(coremark_defs) \
	$(coremark_cflags) -c $(incs) $< -o $@

coremark_arc_bin = coremark.arc
$(coremark_arc_bin): $(coremark_c_objs) $(coremark_arc_objs)
	$(ARC_LINK) $(coremark_c_objs) $(coremark_arc_objs) \
	-o $(coremark_arc_bin) $(ARC_LINK_OPTS)

coremark_arc_rep = coremark.arc.rep
$(coremark_arc_rep): coremark.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS=":"}{print "Coremark |", $$2}' > $@

bmarks_arc_rep := $(filter-out $(coremark_arc_rep), $(bmarks_arc_rep))
extra_reports += $(coremark_arc_rep)

junk += $(coremark_c_objs) $(coremark_arc_objs) \
	$(coremark_host_bin) $(coremark_arc_bin) $(coremark_arc_rep)
