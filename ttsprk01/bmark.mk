#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

ttsprk01_c_src = \
	algotst.c \
	bmark.c

ttsprk01_c_objs = $(patsubst %.c, %.o.tts, $(ttsprk01_c_src))
ttsprk01_arc_objs =
ttsprk01_defs =  -DHEAP_SIZE=13107
ttsprk01_cflags = -O3 -flto

%.o.tts: ttsprk01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(ttsprk01_defs) \
	$(ttsprk01_cflags) -c $(incs) $< -o $@

ttsprk01_arc_bin = ttsprk01.arc
$(ttsprk01_arc_bin): $(ttsprk01_c_objs) $(ttsprk01_arc_objs) $(eembc_speed_objs)
	$(ARC_LINK) $^ \
	-o $(ttsprk01_arc_bin) $(ARC_LINK_OPTS) \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648

ttsprk01_arc_rep = ttsprk01.arc.rep
$(ttsprk01_arc_rep): ttsprk01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{printf "ttsprk01 | %f", $$2}' > $@
	grep -q "Failure" $< && echo -n " *" >> $@ || true
	echo "" >> $@

bmarks_arc_rep := $(filter-out $(ttsprk01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(ttsprk01_arc_rep)

junk += $(ttsprk01_c_objs) $(ttsprk01_arc_objs) \
	$(ttsprk01_host_bin) $(ttsprk01_arc_bin) $(ttsprk01_arc_rep)
