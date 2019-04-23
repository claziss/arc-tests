#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

aifirf01_c_src = \
	algotst.c \
	bmark.c

aifirf01_c_objs = $(patsubst %.c, %.o.aif, $(aifirf01_c_src))
aifirf01_arc_objs =
aifirf01_defs =  -DHEAP_SIZE=13107
aifirf01_cflags = -O3 -flto

%.o.aif: aifirf01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(aifirf01_defs) \
	$(aifirf01_cflags) -c $(incs) $< -o $@

aifirf01_arc_bin = aifirf01.arc
$(aifirf01_arc_bin): $(aifirf01_c_objs) $(aifirf01_arc_objs) $(eembc_speed_objs)
	$(ARC_LINK) $^ \
	-o $(aifirf01_arc_bin) $(ARC_LINK_OPTS) \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648

aifirf01_arc_rep = aifirf01.arc.rep
$(aifirf01_arc_rep): aifirf01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{printf "Aifirf01 | %f", $$2}' > $@
	grep -q "Failure" $< && echo -n " *" >> $@ || true
	echo "" >> $@

bmarks_arc_rep := $(filter-out $(aifirf01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(aifirf01_arc_rep)

junk += $(aifirf01_c_objs) $(aifirf01_arc_objs) \
	$(aifirf01_host_bin) $(aifirf01_arc_bin) $(aifirf01_arc_rep)
