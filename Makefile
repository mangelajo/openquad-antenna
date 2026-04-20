MAC_OPENSCAD := /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
OPENSCAD ?= $(shell if [ "$$(uname)" = "Darwin" ] && [ -x "$(MAC_OPENSCAD)" ]; then echo "$(MAC_OPENSCAD)"; else echo openscad; fi)
OPENSCAD_FLAGS ?= --backend=manifold
# Override e.g.: make renders RENDER_COLORSCHEME=Metallic
# Schemes: Cornfield Metallic Sunset Starnight BeforeDawn Nature
#          "Daylight Gem" "Nocturnal Gem" DeepOcean Solarized
#          Tomorrow "Tomorrow Night" ClearSky Monotone
RENDER_COLORSCHEME ?= ClearSky
RENDER_FLAGS   ?= --imgsize=800,800 --camera=0,0,0,65,0,-135,0 --viewall --autocenter --render --backend=manifold $(if $(RENDER_COLORSCHEME),--colorscheme="$(RENDER_COLORSCHEME)")

BUILD := build
DOCS_IMG_DIR := docs/images/generated
STLS := $(BUILD)/all_in_one.stl $(BUILD)/driven_element.stl $(BUILD)/regular_wire_clamp.stl
PNGS := $(STLS:.stl=.png)

.PHONY: help all matrix zip renders docs-images test serve clean nfq

# Calculator / web app
NODE    ?= node
PORT    ?= 8765
WEB_DIR := web

help: ## Show this help
	@awk 'BEGIN{FS=":.*## "; printf "Targets:\n"} /^[a-zA-Z_-]+:.*## / {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf "\nOverridable variables (e.g. make renders RENDER_COLORSCHEME=Metallic):\n"
	@printf "  \033[36m%-22s\033[0m %s\n" "OPENSCAD" "openscad binary (auto-detected on macOS)"
	@printf "  \033[36m%-22s\033[0m %s\n" "OPENSCAD_FLAGS" "flags for STL generation [$(OPENSCAD_FLAGS)]"
	@printf "  \033[36m%-22s\033[0m %s\n" "RENDER_FLAGS" "flags for PNG renders"
	@printf "  \033[36m%-22s\033[0m %s\n" "RENDER_COLORSCHEME" "OpenSCAD color scheme name (see top of Makefile)"
	@printf "  \033[36m%-22s\033[0m %s\n" "NODE" "node binary for 'make test' [$(NODE)]"
	@printf "  \033[36m%-22s\033[0m %s\n" "PORT" "port for 'make serve' [$(PORT)]"
	@printf "\nTip: use 'make -j4 ...' for parallel builds.\n"

all: $(STLS) ## Build the 3 default STLs into build/

$(BUILD):
	mkdir -p $@

$(BUILD)/all_in_one.stl: src/all_in_one.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ $<

$(BUILD)/driven_element.stl: src/antenna_spreader_clamp.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ -D 'driven_element=true' $<

$(BUILD)/regular_wire_clamp.stl: src/antenna_spreader_clamp.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ -D 'driven_element=false' $<

$(BUILD)/all_in_one.png: src/all_in_one.scad | $(BUILD)
	$(OPENSCAD) $(RENDER_FLAGS) -o $@ $<

$(BUILD)/driven_element.png: src/antenna_spreader_clamp.scad | $(BUILD)
	$(OPENSCAD) $(RENDER_FLAGS) -o $@ -D 'driven_element=true' $<

$(BUILD)/regular_wire_clamp.png: src/antenna_spreader_clamp.scad | $(BUILD)
	$(OPENSCAD) $(RENDER_FLAGS) -o $@ -D 'driven_element=false' $<

# ============================================================
# Non-foldable quad (src/non_foldable_quad.scad)
# Integrated-rod X element + boom segment couplers.
# Override on the command line, e.g.:
#   make nfq NFQ_FREQ=432.0 NFQ_VF=0.95 NFQ_DIRS=2
# ============================================================

NFQ_FREQ ?= 432.0
NFQ_VF   ?= 0.95
NFQ_DIRS ?= 2

NFQ_COMMON = -D 'freq=$(NFQ_FREQ)' -D 'vf=$(NFQ_VF)' -D 'num_directors=$(NFQ_DIRS)'

NFQ_STLS := $(BUILD)/nfq_x_reflector.stl $(BUILD)/nfq_x_driven.stl \
            $(BUILD)/nfq_x_dir1.stl $(BUILD)/nfq_x_dir2.stl \
            $(BUILD)/nfq_boom_seg0.stl $(BUILD)/nfq_boom_seg1.stl \
            $(BUILD)/nfq_all.stl

$(BUILD)/nfq_x_reflector.stl: src/non_foldable_quad.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ \
	  -D 'render_part="x"' -D 'element_index=0' -D 'driven_element=false' \
	  $(NFQ_COMMON) $<

$(BUILD)/nfq_x_driven.stl: src/non_foldable_quad.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ \
	  -D 'render_part="x"' -D 'element_index=1' -D 'driven_element=true' \
	  $(NFQ_COMMON) $<

$(BUILD)/nfq_x_dir1.stl: src/non_foldable_quad.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ \
	  -D 'render_part="x"' -D 'element_index=2' -D 'driven_element=false' \
	  $(NFQ_COMMON) $<

$(BUILD)/nfq_x_dir2.stl: src/non_foldable_quad.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ \
	  -D 'render_part="x"' -D 'element_index=3' -D 'driven_element=false' \
	  $(NFQ_COMMON) $<

$(BUILD)/nfq_boom_seg0.stl: src/non_foldable_quad.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ \
	  -D 'render_part="boom"' -D 'segment_index=0' \
	  $(NFQ_COMMON) $<

$(BUILD)/nfq_boom_seg1.stl: src/non_foldable_quad.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ \
	  -D 'render_part="boom"' -D 'segment_index=1' \
	  $(NFQ_COMMON) $<

$(BUILD)/nfq_all.stl: src/non_foldable_quad.scad | $(BUILD)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ \
	  -D 'render_part="all"' $(NFQ_COMMON) $<

nfq: $(NFQ_STLS) ## Build the non-foldable quad STLs (override NFQ_FREQ/NFQ_VF/NFQ_DIRS)

# ============================================================
# Matrix builds: round/square × boom dim × spreader dim
# Layout: build/{shape}_boom_{dim}mm/spreaders_{sd}mm/*.stl
# Zip:    build/{shape}_boom_{dim}mm_spreaders_{sd}mm.zip
# ============================================================

SHAPES         := round square
BOOM_DIMS      := 14.9 15.9 19.9
SPREADERS_DIMS := 8.10 4.05 6.07

MATRIX_STLS :=
MATRIX_PNGS :=
MATRIX_ZIPS :=

# $(1) shape  $(2) is_round (true|false)  $(3) boom_var (boom_dia|boom_side)
# $(4) boom dim  $(5) spreaders dim
# Inner STL/PNG filenames are prefixed {r|s}_b{bd}_s{sd}_ for traceability.
define gen_combo
$(eval _dir := $(BUILD)/$(1)_boom_$(4)mm/spreaders_$(5)mm)
$(eval _pfx := $(if $(filter round,$(1)),r,s)_b$(4)_s$(5))

MATRIX_STLS += $(_dir)/$(_pfx)_all_in_one.stl $(_dir)/$(_pfx)_driven_element.stl $(_dir)/$(_pfx)_regular_wire_clamp.stl
MATRIX_PNGS += $(_dir)/$(_pfx)_all_in_one.png $(_dir)/$(_pfx)_driven_element.png $(_dir)/$(_pfx)_regular_wire_clamp.png
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

$(_dir)/$(_pfx)_all_in_one.png: src/all_in_one.scad | $(_dir)
	$(OPENSCAD) $(RENDER_FLAGS) -o $$@ \
	  -D 'boom_is_round=$(2)' \
	  -D '$(3)=$(4)' \
	  -D 'spreaders_dia=$(5)' $$<

$(_dir)/$(_pfx)_driven_element.png: src/antenna_spreader_clamp.scad | $(_dir)
	$(OPENSCAD) $(RENDER_FLAGS) -o $$@ \
	  -D 'driven_element=true' \
	  -D 'spreaders_dia=$(5)' $$<

$(_dir)/$(_pfx)_regular_wire_clamp.png: src/antenna_spreader_clamp.scad | $(_dir)
	$(OPENSCAD) $(RENDER_FLAGS) -o $$@ \
	  -D 'driven_element=false' \
	  -D 'spreaders_dia=$(5)' $$<

$(BUILD)/$(1)_boom_$(4)mm_spreaders_$(5)mm.zip: $(_dir)/$(_pfx)_all_in_one.stl $(_dir)/$(_pfx)_driven_element.stl $(_dir)/$(_pfx)_regular_wire_clamp.stl $(_dir)/$(_pfx)_all_in_one.png $(_dir)/$(_pfx)_driven_element.png $(_dir)/$(_pfx)_regular_wire_clamp.png
	cd $(BUILD) && zip -j $$(notdir $$@) $(1)_boom_$(4)mm/spreaders_$(5)mm/*.stl $(1)_boom_$(4)mm/spreaders_$(5)mm/*.png
endef

$(foreach s,$(SHAPES),$(foreach b,$(BOOM_DIMS),$(foreach d,$(SPREADERS_DIMS),$(eval $(call gen_combo,$(s),$(if $(filter round,$(s)),true,false),$(if $(filter round,$(s)),boom_dia,boom_side),$(b),$(d))))))

matrix: $(MATRIX_STLS) ## Build all 54 matrix STLs (round/square × 3 boom × 3 spreader)

zip: $(MATRIX_ZIPS) ## Build all 18 per-combination zip files

renders: $(PNGS) $(MATRIX_PNGS) ## Render PNG previews of every STL

docs-images: $(MATRIX_PNGS) ## Render matrix PNGs and copy them to docs/images/generated/
	mkdir -p $(DOCS_IMG_DIR)
	cp $(MATRIX_PNGS) $(DOCS_IMG_DIR)/

test: ## Run the calculator unit tests (node --test)
	$(NODE) --test $(WEB_DIR)/*.test.js

serve: ## Serve web/ locally (default port 8765; override with PORT=…)
	@echo "Serving $(WEB_DIR)/ at http://localhost:$(PORT)  (Ctrl-C to stop)"
	cd $(WEB_DIR) && python3 -m http.server $(PORT)

clean: ## Remove the build/ directory
	rm -rf $(BUILD)
