#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

bitmnp01_c_src = \
	algotst.c \
	bmark.c

bitmnp01_c_objs = $(patsubst %.c, %.o.bit, $(bitmnp01_c_src))
bitmnp01_arc_objs =
bitmnp01_defs =  -DHEAP_SIZE=13107
bitmnp01_cflags = -O3 -flto

%.o.bit: bitmnp01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(bitmnp01_defs) \
	$(bitmnp01_cflags) -c $(incs) $< -o $@

bitmnp01_arc_bin = bitmnp01.arc
$(bitmnp01_arc_bin): $(bitmnp01_c_objs) $(bitmnp01_arc_objs) $(eembc_speed_objs)
	$(ARC_LINK) $^ \
	-o $(bitmnp01_arc_bin) $(ARC_LINK_OPTS) \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648

bitmnp01_arc_rep = bitmnp01.arc.rep
$(bitmnp01_arc_rep): bitmnp01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{printf "Bitmnp01 | %f", $$2}' > $@
	grep -q "Failure" $< && echo -n " *" >> $@ || true
	echo "" >> $@

bmarks_arc_rep := $(filter-out $(bitmnp01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(bitmnp01_arc_rep)

junk += $(bitmnp01_c_objs) $(bitmnp01_arc_objs) \
	$(bitmnp01_host_bin) $(bitmnp01_arc_bin) $(bitmnp01_arc_rep)
