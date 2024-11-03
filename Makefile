include common.mk

all: gensrc main

# $(SRC_DIR)/generator.cc.cc -D REC_PREPROC_ARG=Value -> $(BUILD_DIR)/gensrc/generator.Value.cc
gensrc:

main: $(BUILD_DIR)/main.o
	$(COMPILE_EXE)

RUN_ARGS ?=
run: gensrc main
	./main $(RUN_ARGS)

$(BUILD_DIR)/%.o: $(BUILD_DIR)/%.c.deps.mk
	$(MAKE) -f $(BUILD_DIR)/$*.c.deps.mk $(MFLAGS) $(MAKEOVERRIDES) $@ $(BUILD_DIR)/$*.c.deps.mk

$(BUILD_DIR)/%.c.deps.mk: $(SRC_DIR)/%.c
	$(ENSURE_DIR)
	echo include common.mk > $@
	@printf '%s: ' "$@" >> $@
	@# SIC: not `read -r`
	@( $(CPP) $(CPPFLAGS) $(INCPATH) -M $(SRC_DIR)/$*.c | { read target deps; echo "$$deps" ;} >> $@ ) || { rm $@ && exit 1; }
	@echo '	rm $@' >> $@
	@echo '	$$(MAKE) -f Makefile $$(MFLAGS) $$(MAKEOVERRIDES) $@' >> $@
	@printf '%s/%s' "$(BUILD_DIR)" "$(patsubst ./,,$(dir $*))" >> $@
	$(CPP) $(CPPFLAGS) $(INCPATH) -M $(SRC_DIR)/$*.c >> $@ || { rm $@ && exit 1; }
	echo '	$(CC) -c $$< $$(CPPFLAGS) $$(CFLAGS) $$(INCPATH) -o $$@' >> $@

$(BUILD_DIR)/gensrc/%.cc: $(BUILD_DIR)/gensrc/%.cc.deps.mk
	$(MAKE) -f $(BUILD_DIR)/gensrc/$*.cc.deps.mk $(MFLAGS) $(MAKEOVERRIDES) $@ $(BUILD_DIR)/gensrc/$*.cc.deps.mk

$(BUILD_DIR)/gensrc/%.cc.deps.mk:
	$(ENSURE_DIR)
	echo include common.mk > $@
	@printf '%s: ' "$@" >> $@
	( $(CPP) $(CPPFLAGS) $(INCPATH) -M $(SRC_DIR)/$(basename $*).cc.cc -D REC_PREPROC_ARG=$(patsubst .%,%,$(suffix $*)) | { read target deps; echo "$$deps" ;} >> $@ ) || { rm $@ && exit 1; }
	@echo '	rm $@' >> $@
	@echo '	$$(MAKE) -f Makefile $$(MFLAGS) $$(MAKEOVERRIDES) $@' >> $@
	printf '%s: ' "$(basename $(basename $@))" >> $@
	@( $(CPP) $(CPPFLAGS) $(INCPATH) -M $(SRC_DIR)/$(basename $*).cc.cc -D REC_PREPROC_ARG=$(patsubst .%,%,$(suffix $*)) | { read target deps; echo "$$deps" ;} >> $@ ) || { rm $@ && exit 1; }
	echo '	$(CPP) $$(CPPFLAGS) $$(INCPATH) $$< -D REC_PREPROC_ARG=$(patsubst .%,%,$(suffix $*)) > $$@' >> $@

ifneq ($(BUILD_DIR),)
# Avoid `rm /`
clean:
	-rm main
	-rm -r $(BUILD_DIR)
endif

.PHONY: $(shell find $(BUILD_DIR) -name '*.deps.mk')
.PHONY: all run clean gensrc

.PRECIOUS: $(BUILD_DIR)/%.deps.mk $(shell find $(BUILD_DIR) -name '*.deps.mk')
.SECONDARY:
.SUFFIXES:
.NOTPARALLEL: gensrc
