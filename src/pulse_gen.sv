/*
 * Copyright (c) 2026 Brendan Ang
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

(* keep_hierarchy = "yes" *)
module pulse_gen (
    input  wire clk,
    input  wire d,
    output wire q
);

  reg d_q;
  always @(posedge clk) begin
    d_q <= d;
  end

  assign q = ~d_q & d;

endmodule
