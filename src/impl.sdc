source $::env(FALLBACK_SDC)

# Each carry-chain stage ties A=0, B=1 to activate the full adder's
# CI->CO pass-through arc (when: "!A&B" in the liberty). Those ties are
# routed through resizer-inserted fanout buffers rather than directly from
# a tie cell, so STA's own constant propagation may not trace back far
# enough to prove the condition on its own — in which case it silently
# skips the arc instead of timing it. Assert the values explicitly so the
# chain's real CI->CO delay is always included in analysis.
foreach fa_cell [get_cells -hierarchical "tdc_/cc/genblk1*fa"] {
  set a_pin [get_pins -of_objects $fa_cell -filter {name == A}]
  set b_pin [get_pins -of_objects $fa_cell -filter {name == B}]
  if {$a_pin ne ""} { set_case_analysis 0 $a_pin }
  if {$b_pin ne ""} { set_case_analysis 1 $b_pin }
}

# TDC carry-chain delay line (tdc_/cc): a single edge is meant to propagate
# only partway down this chain within the sample window, by design — it's
# never required to fully settle within one clock period. This is re-enabled
# now that set_case_analysis + a standalone report_checks query (not this
# SDC) have confirmed the chain's real per-stage delay (~2.0 ns/stage,
# docs/info.md) rather than hiding an unknown timing.
set_false_path -through [get_pins -of_objects [get_cells -hierarchical "tdc_/cc/genblk1*"]]
