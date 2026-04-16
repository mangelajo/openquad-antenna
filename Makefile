MAC_OPENSCAD := /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
OPENSCAD ?= $(shell if [ "$$(uname)" = "Darwin" ] && [ -x "$(MAC_OPENSCAD)" ]; then echo "$(MAC_OPENSCAD)"; else echo openscad; fi)
OPENSCAD_FLAGS ?= --backend=manifold

BUILD := build
STLS := $(BUILD)/all_in_one.stl $(BUILD)/driven_element.stl $(BUILD)/regular_wire_clamp.stl

.PHONY: all clean
all: $(STLS)

$(BUILD):
	mkdir -p $@

$(BUILD)/all_in_one.stl: src/all_in_one.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ $<

$(BUILD)/driven_element.stl: src/antenna_spreader_clamp.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ -D 'driven_element=true' $<

$(BUILD)/regular_wire_clamp.stl: src/antenna_spreader_clamp.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ -D 'driven_element=false' $<

clean:
	rm -rf $(BUILD)
