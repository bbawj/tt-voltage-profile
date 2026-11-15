/*
 * Copyright (c) 2026 Brendan Ang
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// An N-stage RO circuit voltage sensor
// @param[in] en_i Enable the sensor
(* keep_hierarchy = "yes" *)
module ro #(
    parameter integer STAGES = 3
) (
    input  wire en_i,
    output wire last
);

  wire [STAGES-1:0] stages;
  wire sig;
  assign sig = en_i ? stages[STAGES-1] : 0;
  inv inv_ (
      .in_i (sig),
      .out_o(stages[0])
  );
  genvar i;
  generate
    for (i = 1; i < STAGES; i = i + 1) begin : gen_chain
      inv inv_ (
          .in_i (stages[i-1]),
          .out_o(stages[i])
      );
    end
  endgenerate
  assign last = stages[STAGES-1];
endmodule
