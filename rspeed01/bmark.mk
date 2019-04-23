#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an arc and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

rspeed01_c_src = \
	algotst.c \
	bmark.c

rspeed01_c_objs = $(patsubst %.c, %.o.rsp, $(rspeed01_c_src))
rspeed01_arc_objs =
rspeed01_defs =  -DHEAP_SIZE=13107
rspeed01_cflags = -O3 -flto

%.o.rsp: rspeed01/%.c
	$(ARC_GCC) $(ARC_GCC_OPTS) $(bmarks_defs) $(rspeed01_defs) \
	$(rspeed01_cflags) -c $(incs) $< -o $@

rspeed01_arc_bin = rspeed01.arc
$(rspeed01_arc_bin): $(rspeed01_c_objs) $(rspeed01_arc_objs) $(eembc_speed_objs)
	$(ARC_LINK) $^ \
	-o $(rspeed01_arc_bin) $(ARC_LINK_OPTS) \
	-Wl,--defsym=__DEFAULT_HEAP_SIZE=262144 \
	-Wl,--section-start,.data=2147483648

rspeed01_arc_rep = rspeed01.arc.rep
$(rspeed01_arc_rep): rspeed01.arc.out
	grep "Iterations/Sec" $< | \
	awk 'BEGIN{FS="="}{printf "rspeed01 | %f", $$2}' > $@
	grep -q "Failure" $< && echo -n " *" >> $@ || true
	echo "" >> $@

bmarks_arc_rep := $(filter-out $(rspeed01_arc_rep), $(bmarks_arc_rep))
extra_reports += $(rspeed01_arc_rep)

junk += $(rspeed01_c_objs) $(rspeed01_arc_objs) \
	$(rspeed01_host_bin) $(rspeed01_arc_bin) $(rspeed01_arc_rep)
