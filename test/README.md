# Testbench for `tt_um_bbawj_volt_profile`

This testbench uses [cocotb](https://docs.cocotb.org/en/stable/) with Icarus
Verilog (`SIM ?= icarus`) to drive the DUT and check the outputs. See the
[Tiny Tapeout testing guide](https://tinytapeout.com/hdl/testing/) for more
information.

It simulates **only the user macro** `tt_um_bbawj_volt_profile`. `ena` is driven
by the testbench; the Tiny Tapeout wrapper, multiplexer, chip ROM, pads, and
chip top (`tt_top`) are not instantiated here. Whole-chip assembly and
simulation happen upstream in the `tt-multiplexer` project.

## Setting up

1. Edit [Makefile](Makefile) and modify `PROJECT_SOURCES` to point to your Verilog files.
2. Edit [tb.v](tb.v) and replace `tt_um_example` with your module name.

## How to run

### RTL simulation

```sh
make -B
```

This compiles and elaborates the RTL. The tests in [test.py](test.py) are
skipped in this mode because they need real gate delays (see below).

### Gate-level simulation

The gate-level flow expects a hardened netlist at `gate_level_netlist.v`. The
LibreLane run in this repo writes it to
`../runs/wokwi/final/pnl/{your_module_name}.pnl.v`.

To harden the project and copy that netlist in one step:

```sh
make -B GATES=yes HARDEN=yes PDK=gf180mcuD
```

`HARDEN=yes` runs `../tt/tt_tool.py --create-user-config --pdk $(PDK) --harden`,
which uses the `tt-support-tools` checkout in `../tt` and LibreLane. Note that
`../tt` is a separate clone of
[TinyTapeout/tt-support-tools](https://github.com/TinyTapeout/tt-support-tools)
and is not tracked by this repo; it is installed by the devcontainer or must be
cloned manually.

If you already have a hardened netlist, copy it yourself and run:

```sh
make -B GATES=yes
```

### Gate-level simulation with SDF timing

```sh
make -B GATES=yes TIMING=yes
```

This adds `-gspecify -ginterconnect`, compiles the PDK standard-cell models, and
annotates the SDF from
`../runs/wokwi/final/sdf/nom_tt_025C_3v30/{your_module_name}__nom_tt_025C_3v30.sdf`
(see `tb.v`). This is the mode the tests in [test.py](test.py) are written for.

### Waveform format

By default the testbench writes `tb.fst`. If you wish to save the waveform in VCD
format instead, edit `tb.v` to use `$dumpfile("tb.vcd");` and run:

```sh
make -B FST=
```

This will generate `tb.vcd` instead of `tb.fst`.

## How to view the waveform file

Using GTKWave

```sh
gtkwave tb.fst tb.gtkw
```

Using Surfer

```sh
surfer tb.fst
```
