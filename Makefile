.PHONY: all

clean:
	@cmake -E remove_directory bin
	@echo "[CLEAN]: Done."

build-profile:
	@dub build -c profile
	@echo "[BUILD]: Profiling build done."

build-release:
	@dub build -c=release --build release
	@echo "[BUILD]: Release build done."

build-debug:
	@dub build -c=debug --build debug
	@echo "[BUILD]: Debug build done."

build:
	@make build-debug

test:
	@dub test -c unittest --build unittest

run:
	@./bin/dbox-debug --systemConfig ./default-configs/system.json --type CHIP8 --emulatorConfig ./default-configs/chip8.json