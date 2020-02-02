.PHONY: all install-hooks clean

submodule_path ?= gen
export submodule_path

root := $(dir $(lastword $(MAKEFILE_LIST)))

datafiles := data/perks.m4 data/weapons.m4
sources := $(wildcard *.m4)

all: $(datafiles) $(sources:.m4=.txt)

install-hooks:
	for hook in $(root)$(submodule_path)/.hooks/*; do \
		ln -sf ../../$${hook} $(root).git/hooks/; \
	done

%.txt: %.m4 $(submodule_path)/common.m4 $(datafiles)
	m4 -Dgen_root="$(submodule_path)" $(submodule_path)/common.m4 $< > $@

$(datafiles) manifest.json names.json:
	$(MAKE) -f $(submodule_path)/Makefile.gen $@

clean:
	rm *.json || true
