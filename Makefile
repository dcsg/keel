.PHONY: demo demo-all demo-01 demo-02 demo-03 demo-04 demo-05 demo-06 demo-07 demo-trust test

# Record all demo flows
demo-all:
	./docs/demo/record.sh all

# Record individual flows
demo-01:
	./docs/demo/record.sh 01-init

demo-02:
	./docs/demo/record.sh 02-context

demo-03:
	./docs/demo/record.sh 03-plan

demo-04:
	./docs/demo/record.sh 04-status

demo-05:
	./docs/demo/record.sh 05-doctor

demo-06:
	./docs/demo/record.sh 06-intake

demo-07:
	./docs/demo/record.sh 07-workflow

# List available flows
demo:
	./docs/demo/record.sh

# Pre-trust all demo directories so VHS recordings skip the trust dialog.
# Run this ONCE, accept the trust dialog in each Claude session that opens,
# then Ctrl+C or /exit — recordings will reuse the trusted paths.
demo-trust:
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  Pre-trusting demo directories for VHS recordings"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "  This will open Claude in each demo directory."
	@echo "  For each session: accept the trust dialog, then /exit"
	@echo ""
	@for flow in 01-init 02-context 03-plan 04-status 05-doctor 06-intake 07-workflow; do \
		dir="/tmp/keel-demo-$$flow"; \
		mkdir -p "$$dir"; \
		echo "  Trusting: $$dir"; \
		(cd "$$dir" && claude); \
	done
	@echo ""
	@echo "  Done — all paths trusted. Run make demo-01 to record."
	@echo ""

# Run test suite
test:
	./test/run.sh
