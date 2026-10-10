.PHONY: setup run restore
run: setup
	./antivirusd.sh dir malicious_dir 5
setup:
	mkdir -p malicious_dir
restore: setup
	./restore.sh dir malicious_dir