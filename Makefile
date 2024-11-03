include common.mk

all: main

main: $(BUILD_DIR)/main.o
	$(COMPILE_EXE)

RUN_ARGS ?=
run: main
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

ifneq ($(BUILD_DIR),)
# Avoid `rm /`
clean:
	-rm main
	-rm -r $(BUILD_DIR)
endif

.PHONY: $(shell find $(BUILD_DIR) -name '*.deps.mk')
.PHONY: all run clean

.PRECIOUS: $(BUILD_DIR)/%.deps.mk $(shell find $(BUILD_DIR) -name '*.deps.mk')
.SECONDARY:
.SUFFIXES:
