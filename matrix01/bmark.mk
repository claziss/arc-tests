#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

matrix01_c_src = \
	algotst.c \
	bmark.c

matrix01_c_objs = $(patsubst %.c, %.o.mat, $(matrix01_c_src))
matrix01_arc_objs =
matrix01_defs =  -DHEAP_SIZE=13107
matrix01_cflags = -O3 -flto

%.o.mat: matrix01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(matrix01_defs) \
	$(matrix01_cflags) -c $(incs) $< -o $@

matrix01_arc_bin = matrix01.arc
$(matrix01_arc_bin): $(matrix01_c_objs) $(matrix01_arc_objs) $(eembc_speed_objs)
	$(ARC_LINK) $^ \
	-o $(matrix01_arc_bin) $(ARC_LINK_OPTS) \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648

matrix01_arc_rep = matrix01.arc.rep
$(matrix01_arc_rep): matrix01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{printf "matrix01 | %f", $$2}' > $@
	grep -q "Failure" $< && echo -n " *" >> $@ || true
	echo "" >> $@

bmarks_arc_rep := $(filter-out $(matrix01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(matrix01_arc_rep)

junk += $(matrix01_c_objs) $(matrix01_arc_objs) \
	$(matrix01_host_bin) $(matrix01_arc_bin) $(matrix01_arc_rep)
