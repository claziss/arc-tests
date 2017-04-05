#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
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
	-fsched-pressure -fno-branch-count-reg

%.o.cm: %.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(coremark_defs) \
	$(coremark_cflags) -c $(incs) $< -o $@

coremark_arc_bin = coremark.arc
$(coremark_arc_bin): $(coremark_c_objs) $(coremark_arc_objs)
	$(ARC_LINK) $(coremark_c_objs) $(coremark_arc_objs) \
	-o $(coremark_arc_bin) $(ARC_LINK_OPTS)

junk += $(coremark_c_objs) $(coremark_arc_objs) \
	$(coremark_host_bin) $(coremark_arc_bin)