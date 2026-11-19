/*
 * Copyright (c) 2026 Brendan Ang
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// When en_i is switched from low to high, it generates a 
// rising edge that propagates through a carry chain delay.
// A pulse is generated that samples the taps on the next cycle.
// The hamming weight is counted over the length of N cycles to save area
(* keep_hierarchy = "yes" *)
module tdc #(
) (
    input wire clk,
    input wire en_i,
    output reg done,
    output reg [7:0] hamming_weight
);

  localparam integer N = 31;
  localparam integer CW = $clog2(N + 1);

  wire pulse;
  pulse_gen pulse_gen (
      .clk(clk),
      .d  (en_i),
      .q  (pulse)
  );

  wire [N-1:0] taps;
  reg  [N-1:0] taps_sync;
  carry_chain #(
      .N(N)
  ) cc (
      .edge_i(en_i),
      .taps  (taps)
  );

  reg start;
  reg [CW-1:0] counter;

  always @(posedge clk) begin
    if (pulse) taps_sync <= taps;
    else if (start == 1'b1) begin
      taps_sync <= {1'b0, taps_sync[N-1:1]};
    end else taps_sync <= taps_sync;
  end

  always @(posedge clk) begin
    if (pulse) start <= 1'b1;
    else if (counter == N) start <= 1'b0;
    else start <= start;
  end

  always @(posedge clk) begin
    if (pulse) begin
      counter <= 0;
      hamming_weight <= 0;
      done <= 0;
    end else if (start) begin
      counter <= counter + 1;
      hamming_weight <= hamming_weight + taps_sync[0];
      done <= 0;
    end else if (counter == N) begin
      counter <= counter;
      hamming_weight <= hamming_weight;
      done <= 1;
    end
  end

endmodule
