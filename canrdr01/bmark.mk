#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

canrdr01_c_src = \
	algotst.c \
	bmark.c

canrdr01_c_objs = $(patsubst %.c, %.o.can, $(canrdr01_c_src))
canrdr01_arc_objs =
canrdr01_defs =  -DHEAP_SIZE=13107
canrdr01_cflags = -O3 -flto

%.o.can: canrdr01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(canrdr01_defs) \
	$(canrdr01_cflags) -c $(incs) $< -o $@

canrdr01_arc_bin = canrdr01.arc
$(canrdr01_arc_bin): $(canrdr01_c_objs) $(canrdr01_arc_objs) $(eembc_speed_objs)
	$(ARC_LINK) $^ \
	-o $(canrdr01_arc_bin) $(ARC_LINK_OPTS) \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648

canrdr01_arc_rep = canrdr01.arc.rep
$(canrdr01_arc_rep): canrdr01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{printf "canrdr01 | %f", $$2}' > $@
	grep -q "Failure" $< && echo -n " *" >> $@ || true
	echo "" >> $@

bmarks_arc_rep := $(filter-out $(canrdr01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(canrdr01_arc_rep)

junk += $(canrdr01_c_objs) $(canrdr01_arc_objs) \
	$(canrdr01_host_bin) $(canrdr01_arc_bin) $(canrdr01_arc_rep)
