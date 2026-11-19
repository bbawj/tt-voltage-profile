/*
 * Copyright (c) 2026 Brendan Ang
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none (* keep_hierarchy = "yes" *)
module carry_chain #(
    parameter integer N = 255
) (
    input wire edge_i,
    output wire [N-1:0] taps
);

  wire [N:0] cout;

  assign cout[0] = edge_i;

  assign taps = cout[N:1];

  genvar i;
  generate
    for (i = 0; i < N; i = i + 1) begin
      gf180mcu_fd_sc_mcu7t5v0__addf_1 fa (
          .A (1'b0),
          .B (1'b1),
          .CI(cout[i]),
          .S (),
          .CO(cout[i+1])
      );
    end
  endgenerate

endmodule
