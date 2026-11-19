/*
 * Copyright (c) 2026 Brendan Ang
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module delay (
    input  wire bypass_i,  // delay_en_i: 0 = bypass, 1 = add delay
    input  wire in,
    output wire out
);
  wire delayed;
  gf180mcu_fd_sc_mcu7t5v0__dlyb_2 dly (
      .I(in),
      .Z(delayed)
  );
  assign out = bypass_i ? delayed : in;
endmodule

