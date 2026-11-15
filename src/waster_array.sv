/*
 * Copyright (c) 2026 Brendan Ang
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// A <NUM> array of 1-stage RO waster circuits
// @param[in] en_i Enable control for all of them at once
(* keep_hierarchy = "yes" *)
module waster_array (
    input wire en_i
);

  localparam integer NUM = 16;
  genvar i;
  generate
    for (i = 0; i < NUM; i += 1) begin : gen_ro
      (* keep = "true" *) ro ro_ (
          .en_i(en_i),
          .last()
      );
    end
  endgenerate

endmodule
