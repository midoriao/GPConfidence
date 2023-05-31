SH=$(wildcard test/benchmarks/*)
CSV=$(SH:test/benchmarks/%=results/%.csv)

DIRS=results output

.PHONY: all scalac

all: $(DIRS) benchmarks $(CSV)

results:
	mkdir -p $@

output:
	mkdir -p $@

.PHONY: benchmarks
benchmarks:
	make -C test benchmark-scripts
	chmod +x test/benchmarks/*

results/%.csv: test/benchmarks/%
	./run $* $< $@
	
clean:
	rm *.dat *.slxc *mex*
