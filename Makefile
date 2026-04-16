MAC_OPENSCAD := /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
OPENSCAD ?= $(shell if [ "$$(uname)" = "Darwin" ] && [ -x "$(MAC_OPENSCAD)" ]; then echo "$(MAC_OPENSCAD)"; else echo openscad; fi)
OPENSCAD_FLAGS ?= --backend=manifold

BUILD := build
STLS := $(BUILD)/all_in_one.stl $(BUILD)/driven_element.stl $(BUILD)/regular_wire_clamp.stl

.PHONY: all matrix zip clean
all: $(STLS)

$(BUILD):
	mkdir -p $@

$(BUILD)/all_in_one.stl: src/all_in_one.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ $<

$(BUILD)/driven_element.stl: src/antenna_spreader_clamp.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ -D 'driven_element=true' $<

$(BUILD)/regular_wire_clamp.stl: src/antenna_spreader_clamp.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ -D 'driven_element=false' $<

# ============================================================
# Matrix builds: round/square × boom dim × spreader dim
# Layout: build/{shape}_boom_{dim}mm/spreaders_{sd}mm/*.stl
# Zip:    build/{shape}_boom_{dim}mm_spreaders_{sd}mm.zip
# ============================================================

SHAPES         := round square
BOOM_DIMS      := 14.9 15.9 19.9
SPREADERS_DIMS := 8.10 4.05 6.07

MATRIX_STLS :=
MATRIX_ZIPS :=

# $(1) shape  $(2) is_round (true|false)  $(3) boom_var (boom_dia|boom_side)
# $(4) boom dim  $(5) spreaders dim
# Inner STL filenames are prefixed {r|s}_b{bd}_s{sd}_ for traceability.
define gen_combo
$(eval _dir := $(BUILD)/$(1)_boom_$(4)mm/spreaders_$(5)mm)
$(eval _pfx := $(if $(filter round,$(1)),r,s)_b$(4)_s$(5))

MATRIX_STLS += $(_dir)/$(_pfx)_all_in_one.stl $(_dir)/$(_pfx)_driven_element.stl $(_dir)/$(_pfx)_regular_wire_clamp.stl
MATRIX_ZIPS += $(BUILD)/$(1)_boom_$(4)mm_spreaders_$(5)mm.zip

$(_dir):
	mkdir -p $$@

$(_dir)/$(_pfx)_all_in_one.stl: src/all_in_one.scad | $(_dir)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $$@ \
	  -D 'boom_is_round=$(2)' \
	  -D '$(3)=$(4)' \
	  -D 'spreaders_dia=$(5)' $$<

$(_dir)/$(_pfx)_driven_element.stl: src/antenna_spreader_clamp.scad | $(_dir)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $$@ \
	  -D 'driven_element=true' \
	  -D 'spreaders_dia=$(5)' $$<

$(_dir)/$(_pfx)_regular_wire_clamp.stl: src/antenna_spreader_clamp.scad | $(_dir)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $$@ \
	  -D 'driven_element=false' \
	  -D 'spreaders_dia=$(5)' $$<

$(BUILD)/$(1)_boom_$(4)mm_spreaders_$(5)mm.zip: $(_dir)/$(_pfx)_all_in_one.stl $(_dir)/$(_pfx)_driven_element.stl $(_dir)/$(_pfx)_regular_wire_clamp.stl
	cd $(BUILD) && zip -j $$(notdir $$@) $(1)_boom_$(4)mm/spreaders_$(5)mm/*.stl
endef

$(foreach s,$(SHAPES),$(foreach b,$(BOOM_DIMS),$(foreach d,$(SPREADERS_DIMS),$(eval $(call gen_combo,$(s),$(if $(filter round,$(s)),true,false),$(if $(filter round,$(s)),boom_dia,boom_side),$(b),$(d))))))

matrix: $(MATRIX_STLS)

zip: $(MATRIX_ZIPS)

clean:
	rm -rf $(BUILD)
