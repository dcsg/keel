.PHONY: demo demo-all demo-01 demo-02 demo-03 demo-04 demo-05 demo-06 demo-07 test

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

# Run test suite
test:
	./test/run.sh
