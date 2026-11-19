# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
FST ?= -fst # Use more efficient FST format
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = project.v
PROJECT_SOURCES += ro_sensor.sv
PROJECT_SOURCES += ro.sv
PROJECT_SOURCES += inv.sv
PROJECT_SOURCES += waster_array.sv
PROJECT_SOURCES += waster_array_sel.sv

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

else ifeq ($(TIMING), yes)

# Gate level simulation with SDF timing annotation:
SIM_BUILD				= sim_build/gl
ifeq ($(SIM), cvc)
COMPILE_ARGS    += +define+GL_TEST
COMPILE_ARGS    += +define+USE_POWER_PINS
COMPILE_ARGS    += +define+SIM
COMPILE_ARGS    += +define+SDF_ANNOTATE
else
COMPILE_ARGS    += -gspecify -ginterconnect
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DSDF_ANNOTATE
endif
VERILOG_SOURCES += $(PDK_ROOT)/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/gf180mcu_fd_sc_mcu7t5v0.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

ifeq ($(HARDEN), yes)
harden := $(shell (cd .. && ./tt/tt_tool.py --create-user-config --pdk $(PDK) --harden && cp $(CURDIR)/../runs/wokwi/final/pnl/tt_um_bbawj_volt_profile.pnl.v $(CURDIR)/gate_level_netlist.v) 1>&2)
ifneq ($(.SHELLSTATUS),0)
$(error Hardening failed)
endif
endif

# Icarus can't match the COND-qualified IOPATH entries the generated SDF
# uses for the carry chain's addf_1 cells, so it leaves their CI->CO delay
# at 0ns (see gen_addf_override_sdf.py). Regenerate the override file from
# the current harden run's SDF every time, since runs/wokwi/final/ is
# overwritten by each --harden.
gen_addf_override := $(shell python3 $(CURDIR)/gen_addf_override_sdf.py 1>&2)
ifneq ($(.SHELLSTATUS),0)
$(error Failed to generate addf_override.sdf)
endif

else

# Gate level simulation:
SIM_BUILD				= sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/gf180mcu_fd_sc_mcu7t5v0.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Allow sharing configuration between design and testbench via `include`:
COMPILE_ARGS 		+= -I$(SRC_DIR)

# Include the testbench sources:
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb

# List test modules to run, separated by commas and without the .py suffix:
COCOTB_TEST_MODULES = test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
