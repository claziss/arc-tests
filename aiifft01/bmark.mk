#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

aiifft01_c_src = \
	algotst.c \
	bmark.c

aiifft01_c_objs = $(patsubst %.c, %.o.aii, $(aiifft01_c_src))
aiifft01_arc_objs =
aiifft01_defs =  -DHEAP_SIZE=13107
aiifft01_cflags = -O3 -flto

%.o.aii: aiifft01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(aiifft01_defs) \
	$(aiifft01_cflags) -c $(incs) $< -o $@

aiifft01_arc_bin = aiifft01.arc
$(aiifft01_arc_bin): $(aiifft01_c_objs) $(aiifft01_arc_objs) $(eembc_speed_objs)
	$(ARC_LINK) $^ \
	-o $(aiifft01_arc_bin) $(ARC_LINK_OPTS) \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648

aiifft01_arc_rep = aiifft01.arc.rep
$(aiifft01_arc_rep): aiifft01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{printf "Aiifft01 | %f", $$2}' > $@
	grep -q "Failure" $< && echo -n " *" >> $@ || true
	echo "" >> $@

bmarks_arc_rep := $(filter-out $(aiifft01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(aiifft01_arc_rep)

junk += $(aiifft01_c_objs) $(aiifft01_arc_objs) \
	$(aiifft01_arc_bin) $(aiifft01_arc_rep)
