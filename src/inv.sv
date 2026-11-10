/*
 * Copyright (c) 2026 Brendan Ang
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// A combinational inverter with enable
(* keep_hierarchy = "yes" *)
module inv (
    input  wire in_i,
    output wire out_o
);

  assign out_o = ~in_i;

endmodule
