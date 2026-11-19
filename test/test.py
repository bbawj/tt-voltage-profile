# SPDX-FileCopyrightText: © 2026 Brendan Ang
# SPDX-License-Identifier: Apache-2.0

import os

import cocotb
from cocotb.clock import Clock, Timer
from cocotb.triggers import RisingEdge, ClockCycles

GATES = os.environ.get("GATES") == "yes"
TIMING = os.environ.get("TIMING") == "yes"

TDC_EN = 1 << 1
TDC_EN_SEL = 1 << 2
WASTER_EN = 1 << 3


class TB:
    def __init__(self, dut):
        self.dut = dut
        clock = Clock(dut.clk, 25, unit="ns")
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

    dut.ui_in.value = WASTER_EN

    for sel in range(16):
        await RisingEdge(dut.clk)
        dut.ui_in.value = WASTER_EN | (sel << 4)
        await RisingEdge(dut.clk)
        # 1 additional clock cycle latency from synchronous enable
        await RisingEdge(dut.clk)
        mask = await _toggle_mask(dut.waster_tap)
        assert mask == ((1 << (sel + 1)) - 1), (
            f"sel_i={sel}: expected only bit {sel} to toggle, got mask {mask:#06x}"
        )


@cocotb.test(skip=not (GATES and TIMING))
async def test_tdc_counter(dut):
    tb = TB(dut)
    await tb.reset()

    assert dut.uio_oe.value != 0, "sanity check failed, the design should output uio"

    dut.ui_in.value = WASTER_EN
    await ClockCycles(dut.clk, 32)
    assert dut.uio_out.value.to_unsigned() > 0, "waster_en should trigger TDC"

    dut.ui_in.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    assert dut.uio_out.value != 0, "Input reset to 0 should not affect TDC count"

    dut.ui_in.value = TDC_EN | TDC_EN_SEL
    await ClockCycles(dut.clk, 32)
    assert dut.uio_out.value.to_unsigned(
    ) > 0, "TDC sel should have triggered another count"


@cocotb.test(skip=not (GATES and TIMING))
async def test_tdc_delay_element(dut):
    """delay_en_i (uio_in[7]) routes the carry chain's rising edge through an
    extra dlyb_2 delay buffer (src/delay.sv), so it starts propagating down
    the chain later. Sampled one clock period later, a later-starting edge
    has reached fewer taps, so the hamming weight should be lower with the
    delay element enabled. Only meaningful with real gate delays (GL +
    SDF timing), same as test_waster_oscillates.
    """
    tb = TB(dut)
    await tb.reset()

    async def run_tdc(delay_en):
        dut.uio_in.value = (1 << 7) if delay_en else 0
        dut.ui_in.value = 0
        await RisingEdge(dut.clk)
        dut.ui_in.value = TDC_EN | TDC_EN_SEL
        # N=63 taps to shift out serially, plus margin for the TDC to settle.
        await ClockCycles(dut.clk, 70)
        weight = dut.uio_out.value.to_unsigned() & 0x3F
        dut.ui_in.value = 0
        await ClockCycles(dut.clk, 2)
        return weight

    weight_no_delay = await run_tdc(delay_en=False)
    weight_with_delay = await run_tdc(delay_en=True)

    assert 0 < weight_with_delay < weight_no_delay < 63, (
        f"enabling delay_en_i should shift the edge later and reduce the "
        f"hamming weight sampled next cycle: no-delay={weight_no_delay}, "
        f"with-delay={weight_with_delay}"
    )
