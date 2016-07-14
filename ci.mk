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
	git submodule update --recursive --init

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
		|| sudo apt-get install -y $(basename $@)

.PHONY: %.pip
%.pip:
	# Installs a pip python package if it's not already there
	python -c "import $(basename $@)" || sudo pip install $(basename $@)

.PHONY: %.npm
%.npm:
	# Installs an npm package if it's not already there
	npm list -g $(basename $@) >/dev/null || sudo npm install -g $(basename $@)

# Defaults to .cache just to stay out of the way
# This is where git clones are stored
CACHE_DIR := $(shell pwd)/.cache

.PHONY: %.github
%.github:
	# Clones a github repository to CACHE_DIR
	@$(MAKE) https://github.com/$(basename $@).git

.PHONY: %.git
%.git:
	# Clones a git repo to CACHE_DIR
	if [ -d $(CACHE_DIR)/$(basename $(notdir $@)) ]; then git -C $(CACHE_DIR)/$(basename $(notdir $@)) pull; \
	else git clone $@ $(CACHE_DIR)/$(basename $(notdir $@)); fi;
