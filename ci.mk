.PHONY: ci-init ci-build ci-finish
ci-init:
ci-build:
ci-finish:
ci:
	@$(MAKE) ci-init
	@$(MAKE) ci-build
	@$(MAKE) ci-finish

.PHONY: gitinit
gitinit: .git/modules
.git/modules:
	git submodule update --recursive --init

.PHONY: gitdeinit
gitdeinit:
	git submodule deinit --force .

.PHONY: %.pkg
.NOTPARALLEL: %.pkg
%.pkg:
	dpkg-query -l $(basename $@) 2>/dev/null | grep ^.i >/dev/null \
		|| sudo apt-get install -y $(basename $@)

.PHONY: %.pip
%.pip:
	python -c "import $(basename $@)" || sudo pip install $(basename $@)

.PHONY: %.npm
%.npm:
	npm list -g $(basename $@) >/dev/null || sudo npm install -g $(basename $@)

# Defaults to .cache just to stay out of the way
CACHE_DIR := "$(shell pwd)/.cache"

.PHONY: %.github
%.github:
	@$(MAKE) https://github.com/$(basename $@).git

.PHONY: %.git
%.git:
	if [ -d $(CACHE_DIR)/$(basename $(notdir $@)) ]; then git -C $(CACHE_DIR)/$(basename $(notdir $@)) pull; \
	else git clone $@ $(CACHE_DIR)/$(basename $(notdir $@)); fi;
