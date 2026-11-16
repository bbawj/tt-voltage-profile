# SPDX-FileCopyrightText: © 2026 Brendan Ang
# SPDX-License-Identifier: Apache-2.0

import os

import cocotb
from cocotb.clock import Clock, Timer
from cocotb.triggers import RisingEdge, ClockCycles, ValueChange, ReadOnly

GATES = os.environ.get("GATES") == "yes"
TIMING = os.environ.get("TIMING") == "yes"


class TB:
    def __init__(self, dut):
        self.dut = dut
        clock = Clock(dut.clk, 10, unit="ns")
        cocotb.start_soon(clock.start())

    async def reset(self):
        self.dut._log.info("Reset")
        self.dut.ena.value = 1
        self.dut.ui_in.value = 0
        self.dut.uio_in.value = 0
        self.dut.rst_n.value = 0
        await RisingEdge(self.dut.clk)

        self.dut.rst_n.value = 1
        await RisingEdge(self.dut.clk)
        self.dut.rst_n.value = 0
        await RisingEdge(self.dut.clk)
        self.dut.rst_n.value = 1
        await RisingEdge(self.dut.clk)


@cocotb.test(skip=not (GATES and TIMING))
async def test_counter_increments(dut):
    tb = TB(dut)
    await tb.reset()
    dut.ui_in.value = 1
    await ClockCycles(dut.clk, 4)
    assert dut.uo_out.value.to_unsigned() > 0
    await tb.reset()
    dut.ui_in.value = 1
    await ClockCycles(dut.clk, 4)
    assert dut.uo_out.value.to_unsigned() > 0


async def _toggle_mask(bus, n=50, step_ps=20):
    """Sample an unclocked bus over time; return a bitmask of every bit that changed.

    Only meaningful with real gate delays (GL + SDF timing); a zero-delay RTL
    sim can't resolve the ROs' combinational feedback loops.
    """
    mask = 0
    for _ in range(n):
        await Timer(step_ps, "ps")
        next = bus.value.to_unsigned()
        mask |= 0xFFFF ^ next
    return mask


@cocotb.test(skip=not (GATES and TIMING))
async def test_waster_oscillates(dut):
    tb = TB(dut)
    await tb.reset()

    enable_wasters = 1 << 1
    dut.ui_in.value = enable_wasters

    for sel in range(16):
        await RisingEdge(dut.clk)
        dut.ui_in.value = enable_wasters | (sel << 4)
        await RisingEdge(dut.clk)
        # 1 additional clock cycle latency from synchronous enable
        await RisingEdge(dut.clk)
        mask = await _toggle_mask(dut.waster_tap)
        assert mask == ((1 << (sel + 1)) - 1), (
            f"sel_i={sel}: expected only bit {sel} to toggle, got mask {mask:#06x}"
        )
