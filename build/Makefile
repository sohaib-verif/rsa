
export PRJ_DIR := $(realpath ../.)

TEST      = rsa_base_test
TIME_OUT  = 110000000

#------------------------------------------------------------
# Compilation & Execution Target (Synchronized for VCS 2016)
#------------------------------------------------------------
build:
	rm -rf $(TEST)_build
	mkdir -p $(TEST)_build

	# Compile Step: Initialize layout and enable full GUI/wave access features
	vcs -f build_RSA.f \
		-ntb_opts uvm-1.2+max_coverage \
		-sverilog \
		-full64 \
		-top testbench \
		-debug_access+all \
		-timescale=1ns/1ps \
		-cm line+cond+tgl+branch+fsm+assert \
		-cm_dir $(TEST)_build/simv.vdb

	mv -f csrc* simv* $(TEST)_build/

	# Robust Copy Check: Ensures stimulus.txt is actually present before launching
	if [ -f stimulus.txt ]; then \
		cp stimulus.txt $(TEST)_build/; \
	elif [ -f $(PRJ_DIR)/tb/stimulus.txt ]; then \
		cp $(PRJ_DIR)/tb/stimulus.txt $(TEST)_build/; \
	else \
		echo "CRITICAL ERROR: stimulus.txt not found anywhere!"; exit 1; \
	fi

	# Run Step: Runs standard batch simulation and saves logs/coverage/waves
	cd $(TEST)_build && \
	./simv \
		+UVM_TESTNAME=$(TEST) \
		+UVM_TIMEOUT=$(TIME_OUT) \
		+vcs+dumpvars=wave.vcd \
		-cm line+cond+tgl+branch+fsm+assert \
		-cm_dir ./simv.vdb \
		-cm_log coverage_run.log \
		> log_$(TEST)_build.txt

	cp -f $(TEST)_build/*.vcd ../tb/ 2>/dev/null || true
	cp -f $(TEST)_build/*.vpd ../tb/ 2>/dev/null || true

#------------------------------------------------------------
# Interactive GUI Target (Launches DVE Waveform & Simulation Window)
#------------------------------------------------------------
gui:
	cd $(TEST)_build && \
	./simv \
		+UVM_TESTNAME=$(TEST) \
		+UVM_TIMEOUT=$(TIME_OUT) \
		-cm line+cond+tgl+branch+fsm+assert \
		-cm_dir ./simv.vdb \
		-gui &

#------------------------------------------------------------
# Coverage Reporting Target
#------------------------------------------------------------
cov:
	urg -full64 \
		-dir $(TEST)_build/simv.vdb \
		-report coverage_report

clean:
	rm -rf csrc DVEfiles inter.vpd simv simv.daidir simv.vdb \
		tr_db.log ucli.key vc_hdrs.h novas.conf \
		novas_dump.log *.txt *.vdb *.daidir \
		test *.cst *.log coverage_report *_build *.vpd *.vcd

all:
	$(MAKE) build TEST=rsa_base_test