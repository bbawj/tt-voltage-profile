/*
 * Copyright (c) 2026 Brendan Ang
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Selects up to 2^n RO waster arrays at once from sel_i value
// @param[in] sel_i Decoded into 2^n bit enable
(* keep_hierarchy = "yes" *)
module waster_array_sel (
    input wire clk,
    input wire rst_n,
    input wire en_i,
    input wire [3:0] sel_i
);

  wire [15:0] en_decoded;
  reg  [15:0] en;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) en <= '0;
    else en <= (en_i) ? ((1 << (sel_i + 1)) - 1) : '0;
  end

  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : g_array
      (* keep = "true" *) waster_array arr (.en_i(en[i]));
    end
  endgenerate

endmodule
