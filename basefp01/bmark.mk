#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

basefp01_c_src = \
	algotst.c \
	bmark.c

basefp01_c_objs = $(patsubst %.c, %.o.bas, $(basefp01_c_src))
basefp01_arc_objs =
basefp01_defs =  -DHEAP_SIZE=13107
basefp01_cflags = -O3 -flto

%.o.bas: basefp01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(basefp01_defs) \
	$(basefp01_cflags) -c $(incs) $< -o $@

basefp01_arc_bin = basefp01.arc
$(basefp01_arc_bin): $(basefp01_c_objs) $(basefp01_arc_objs) $(eembc_speed_objs)
	$(ARC_LINK) $^ \
	-o $(basefp01_arc_bin) $(ARC_LINK_OPTS) \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648

basefp01_arc_rep = basefp01.arc.rep
$(basefp01_arc_rep): basefp01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{printf "Basefp01 | %f", $$2}' > $@
	grep -q "Failure" $< && echo -n " *" >> $@ || true
	echo "" >> $@

bmarks_arc_rep := $(filter-out $(basefp01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(basefp01_arc_rep)

junk += $(basefp01_c_objs) $(basefp01_arc_objs) \
	$(basefp01_host_bin) $(basefp01_arc_bin) $(basefp01_arc_rep)
