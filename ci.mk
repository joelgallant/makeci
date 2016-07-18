.PHONY: ci-pre ci-init ci-build ci-finish
ci-pre:
	# Do all important environment setup here (typically only stuff that's only needed in CI)
ci-init:
	# Initialize your project (stuff that would be needed to build the project anywhere)
ci-build:
	# Build the project (build/compile, test, lint, whatever)
ci-finish:
	# Undo steps for dismantling, if needed
ci:
	# Does all ci steps - this is probably only useful for personal testing of the ci
	@$(MAKE) ci-pre
	@$(MAKE) ci-init
	@$(MAKE) ci-build
	@$(MAKE) ci-finish

.PHONY: gitinit
gitinit:
	# Initializes all git submodules
	git submodule update -q --recursive --init

.PHONY: %.gitmodule
%.gitmodule:
	# Initilizes git submodule
	git submodule update --init $(basename $@)

.PHONY: gitdeinit
gitdeinit:
	# Deinitializes all git submodules
	git submodule deinit --force .

.PHONY: %.pkg
.NOTPARALLEL: %.pkg
%.pkg:
	# Installs an apt-get package if it's not already there
	dpkg-query -l $(basename $@) 2>/dev/null | grep ^.i >/dev/null \
		|| (echo "Installing $(basename $@)..." && \
			sudo apt-get -qq install -y $(basename $@) && \
			echo "$(basename $@) is installed")

.PHONY: %.pip
%.pip:
	# Installs a pip python package if it's not already there
	python -c "import $(basename $@)" 2>/dev/null \
		|| (echo "Installing $(basename $@) on pip..." && \
			sudo pip -q install $(basename $@) && \
			echo "$(basename $@) is installed")

.PHONY: %.npm
%.npm:
	# Installs an npm package if it's not already there
	npm list -g $(basename $@) >/dev/null \
		|| (echo "Installing $(basename $@) on npm..." && \
			sudo npm install --no-progress -g $(basename $@) && \
			echo "$(basename $@) is installed")

# Defaults to .cache just to stay out of the way
# This is where git clones are stored
CACHE_DIR := $(shell pwd)/.cache
$(shell mkdir -p $(CACHE_DIR))

.PHONY: %.github
%.github:
	# Clones a github repository to CACHE_DIR
	@$(MAKE) https://github.com/$(basename $@).git

.PHONY: %.git
%.git:
	# Clones a git repo to CACHE_DIR
	if [ -d $(CACHE_DIR)/$(basename $(notdir $@)) ]; then \
		git -C $(CACHE_DIR)/$(basename $(notdir $@)) fetch; \
	else \
		echo "Cloning $@ to $(CACHE_DIR)/$(basename $(notdir $@))" && \
		git clone -q $@ $(CACHE_DIR)/$(basename $(notdir $@)) && \
		echo "Clone ($@) complete"; \
	fi;
