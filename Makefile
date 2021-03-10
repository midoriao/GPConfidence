SH=$(wildcard test/benchmarks/*)
CSV=$(SH:test/benchmarks/%=results/%.csv)
DIRS=results output

.PHONY: all scalac

all: $(DIRS) $(CSV)

results:
	mkdir -p $@

output:
	mkdir -p $@

results/%.csv: test/benchmarks/%
	./run $* $< $@
	
clean:
	rm *.dat *.slxc *mex*
