build/CMakeCache.txt:
	# Sets up a cmake build without arguments
	# Use CMAKE_ARGS
	mkdir -p build && cd build && cmake $(CMAKE_ARGS) ..

.PHONY: %.cmake
%.cmake: build/CMakeCache.txt
	# Sets a variable to SETTING_VAL (undefined by default)
	if [ ! "$(shell grep -s '$(basename $@):' build/CMakeCache.txt | cut -d '=' -f2)" = "$(SETTING_VAL)" ]; then \
		cd build && cmake -D$(basename $@)=$(SETTING_VAL) ..; \
	fi

.PHONY: %.type
%.type:
	# Sets a variable to cmake's ON
	@$(MAKE) SETTING_VAL=$(basename $@) CMAKE_BUILD_TYPE.cmake

.PHONY: %.on
%.on:
	# Sets a variable to cmake's ON
	@$(MAKE) SETTING_VAL=ON $(basename $@).cmake

.PHONY: %.off
%.off:
	# Sets a variable to cmake's OFF
	@$(MAKE) SETTING_VAL=OFF $(basename $@).cmake

.PHONY: %.target
%.target: build/CMakeCache.txt
	# Builds a cmake target
	@$(MAKE) -Cbuild $(basename $@)
