`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
`ifdef SDF_ANNOTATE
    $sdf_annotate(
        "../runs/wokwi/final/sdf/nom_tt_025C_1v80/tt_um_bbawj_volt_profile__nom_tt_025C_1v80.sdf",
        user_project);
`endif
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Replace tt_um_example with your module name:
  tt_um_bbawj_volt_profile user_project (

      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif

      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

`ifdef GL_TEST
  // Test-only taps into one representative RO per waster array (gen_ro[0] of
  // each), reached via Verilog's own hierarchical reference so cocotb only
  // ever sees one plain, bracket-free bus. Its Python-side name discovery
  // can't safely walk the flattened post-layout netlist's escaped
  // identifiers directly (see test.py), so the splicing has to happen here,
  // at elaboration time, instead. Verilog can't generate these from a
  // `generate`/genvar loop: a genvar can't be spliced into the text of an
  // escaped identifier, since that identifier is one opaque token to the
  // flattened netlist, not a real indexable hierarchy.
  wire waster_tap_0 = user_project.\wasters/g_array[0].arr/gen_ro[0].ro_/last ;
  wire waster_tap_1 = user_project.\wasters/g_array[1].arr/gen_ro[0].ro_/last ;
  wire waster_tap_2 = user_project.\wasters/g_array[2].arr/gen_ro[0].ro_/last ;
  wire waster_tap_3 = user_project.\wasters/g_array[3].arr/gen_ro[0].ro_/last ;
  wire waster_tap_4 = user_project.\wasters/g_array[4].arr/gen_ro[0].ro_/last ;
  wire waster_tap_5 = user_project.\wasters/g_array[5].arr/gen_ro[0].ro_/last ;
  wire waster_tap_6 = user_project.\wasters/g_array[6].arr/gen_ro[0].ro_/last ;
  wire waster_tap_7 = user_project.\wasters/g_array[7].arr/gen_ro[0].ro_/last ;
  wire waster_tap_8 = user_project.\wasters/g_array[8].arr/gen_ro[0].ro_/last ;
  wire waster_tap_9 = user_project.\wasters/g_array[9].arr/gen_ro[0].ro_/last ;
  wire waster_tap_10 = user_project.\wasters/g_array[10].arr/gen_ro[0].ro_/last ;
  wire waster_tap_11 = user_project.\wasters/g_array[11].arr/gen_ro[0].ro_/last ;
  wire waster_tap_12 = user_project.\wasters/g_array[12].arr/gen_ro[0].ro_/last ;
  wire waster_tap_13 = user_project.\wasters/g_array[13].arr/gen_ro[0].ro_/last ;
  wire waster_tap_14 = user_project.\wasters/g_array[14].arr/gen_ro[0].ro_/last ;
  wire waster_tap_15 = user_project.\wasters/g_array[15].arr/gen_ro[0].ro_/last ;
  wire [15:0] waster_tap = {
    waster_tap_15, waster_tap_14, waster_tap_13, waster_tap_12,
    waster_tap_11, waster_tap_10, waster_tap_9,  waster_tap_8,
    waster_tap_7,  waster_tap_6,  waster_tap_5,  waster_tap_4,
    waster_tap_3,  waster_tap_2,  waster_tap_1,  waster_tap_0
  };
`endif

endmodule
