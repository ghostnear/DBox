.PHONY: all

clean:
	@rm -f d-box.*
	@echo "[CLEAN]: Done."

build-release:
	@dub build --compiler=ldc2.EXE -a=x86_64 -b=release -c=application
	@echo "[BUILD]: Release build done."

build-debug:
	@dub build --compiler=ldc2.EXE -a=x86_64 -b=debug -c=application
	@echo "[BUILD]: Debug build done."

build:
	@make build-debug

run:
	@./d-box