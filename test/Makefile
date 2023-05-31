# PARENT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
# WORKSPACE_DIR:=$(abspath $(PARENT_DIR)/../../)

.PHONY: benchmark-scripts
benchmark-scripts:
	mkdir -p benchmarks
	for conf in conf/stl/*.conf; do\
		python3 breach_test.py $${conf};\
	done
	for conf in conf/stl/*.conf; do\
		python3 MCTS_test.py $${conf};\
	done

# .PHONY: experiments
# experiments:
# 	WORKSPACE_DIIR=${WORKSPACE_DIR}; \
# 		echo $${WORKSPACE_DIIR}
