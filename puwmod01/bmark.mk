#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

puwmod01_c_src = \
	algotst.c \
	bmark.c

puwmod01_c_objs = $(patsubst %.c, %.o.puw, $(puwmod01_c_src))
puwmod01_arc_objs =
puwmod01_defs =  -DHEAP_SIZE=13107
puwmod01_cflags = -O3 -flto

%.o.puw: puwmod01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(puwmod01_defs) \
	$(puwmod01_cflags) -c $(incs) $< -o $@

puwmod01_arc_bin = puwmod01.arc
$(puwmod01_arc_bin): $(puwmod01_c_objs) $(puwmod01_arc_objs) $(eembc_speed_objs)
	$(ARC_LINK) $^ \
	-o $(puwmod01_arc_bin) $(ARC_LINK_OPTS) \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648

puwmod01_arc_rep = puwmod01.arc.rep
$(puwmod01_arc_rep): puwmod01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{printf "puwmod01 | %f", $$2}' > $@
	grep -q "Failure" $< && echo -n " *" >> $@ || true
	echo "" >> $@

bmarks_arc_rep := $(filter-out $(puwmod01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(puwmod01_arc_rep)

junk += $(puwmod01_c_objs) $(puwmod01_arc_objs) \
	$(puwmod01_host_bin) $(puwmod01_arc_bin) $(puwmod01_arc_rep)
