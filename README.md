# makeci
Simple tools for using GNU / POSIX make for continuous integration

## Example
Here's a simple example to act as documentation. A simple cpp project that uses
opencv, has tests and uses `cppcheck` as a linter.

```markdown
# Include the required modules up top
include makeci/ci.mk makeci/cmake.mk

# Set CACHE_DIR to wherever the git repositories needed should be stored
CACHE_DIR := $(shell if test -n "$${ENV_CACHE_DIR}"; then echo $${ENV_CACHE_DIR}; else echo "$(CACHE_DIR)"; fi;)

# ci-pre contains things only needed on a ci server, but probably not necessary in a normal build
ci-pre: opencv
# ci-init initialized (in this case, cmake ..) the build
ci-init: init
# ci-build builds, tests, lints, etc
ci-build: test lint
# ci-finish dismantles
ci-finish: gitdeinit

.PHONY: all config runnable test clean clean-config config init
all: all.target
runnable: runnable.target
test: test.target
test.target: all
clean: clean.target
build/CMakeCache.txt: gitinit
config: build/CMakeCache.txt
init: config

.PHONY: clean-config
clean-config:
	rm -rf build

opencv: opencv/opencv.github libeigen3-dev.pkg libav-tools.pkg \
        libavcodec-dev.pkg libavformat-dev.pkg libswscale-dev.pkg numpy.pip
	mkdir -p $(CACHE_DIR)/opencv/build
	cd $(CACHE_DIR)/opencv/build && \
	cmake -DBUILD_EXAMPLES=OFF -DBUILD_PERF_TESTS=OFF \
	      -DBUILD_TESTS=OFF -DBUILD_DOCS=OFF .. && \
	sudo make install -j

.PHONY: lint cppcheck
lint: cppcheck
cppcheck: cppcheck.pkg
	cppcheck \
		--enable=warning,performance,portability --suppress=ignoredReturnValue \
		--error-exitcode=1 src/*
```

The ci server would likely call it like:
```bash
git submodule update --init makeci
make ci-pre -j
make ci-init -j
make ci-build -j
make ci-finish -j
```

Ommiting job servers for cleaner output, but slower performance.

A simple call of `make ci` performs the full suite as well, if your CI server
doesn't support separation of init/build/finish steps for clarity.

See source code for details. Licensed under GPLv3.
