/*
 * Copyright (c) 2026 Brendan Ang
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Selects up to 2^n RO waster arrays at once from sel_i value
// @param[in] sel_i Decoded into 2^n bit enable
(* keep_hierarchy = "yes" *)
module waster_array_sel #(
  parameter N = 2
  ) (
    input wire clk,
    input wire rst_n,
    input wire en_i,
    input wire [N:0] sel_i
);

  localparam integer BITS = (1<<(N+1));

  reg  [BITS-1:0] en;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) en <= '0;
    else en <= (en_i) ? ((1 << (sel_i + 1)) - 1) : '0;
  end

  genvar i;
  generate
    for (i = 0; i < BITS; i = i + 1) begin : g_array
      (* keep = "true" *) waster_array arr (.en_i(en[i]));
    end
  endgenerate

endmodule
