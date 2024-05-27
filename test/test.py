# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles



@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 40 ns (25 MHz)
    clock = Clock(dut.clk, 40, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)
    dut._log.info("Test project behavior")

    #Write test case

    #address & mask
    #write enable
    dut.uio_in.value = 0b00000110
    #data
    dut.ui_in.value = 0x11
    await ClockCycles(dut.clk, 1)

	
    #Read test case

    #address & mask, but mask doesn't matter here
    #read enable
    dut.uio_in.value = 0b00000111
    #data
    await ClockCycles(dut.clk, 2)

    assert dut.uo_out.value == 0x11, "NOT PASS!!!"

