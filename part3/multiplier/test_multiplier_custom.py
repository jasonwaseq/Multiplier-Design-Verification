import re
import git
import os
import sys
import subprocess
import git

# I don't like this, but it's convenient.
_REPO_ROOT = git.Repo(search_parent_directories=True).working_tree_dir
assert (os.path.exists(_REPO_ROOT)), "REPO_ROOT path must exist"
sys.path.append(os.path.join(_REPO_ROOT, "util"))
from utilities import runner, lint, assert_resolvable, assert_passerror, get_sources
tbpath = os.path.dirname(os.path.realpath(__file__))

import pytest

import cocotb

from cocotb.clock import Clock
from cocotb.regression import TestFactory
from cocotb.utils import get_sim_time
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, with_timeout, First
from cocotb.types import LogicArray, Range

from cocotb_test.simulator import run

from cocotbext.axi import AxiLiteBus, AxiLiteMaster, AxiStreamSink, AxiStreamMonitor, AxiStreamBus

from pytest_utils.decorators import max_score, visibility, tags, leaderboard
   
import random
random.seed(42)

from functools import reduce

timescale = "1ps/1ps"

@pytest.mark.parametrize("simulator", ["verilator", "icarus"])
@max_score(2)
def test_all(simulator):
    # This line must be first
    parameters = dict(locals())
    del parameters['simulator']
    runner(simulator, timescale, tbpath, parameters, pymodule="test_multiplier_custom")

@leaderboard("area")
def test_area(set_leaderboard_value=None):
    # This line must be first
    parameters = dict(locals())
    d = dict()
    # This line must be first
    root = git.Repo(search_parent_directories=True).working_tree_dir
    sources = get_sources(root, tbpath)

    fs = ""
    fs = filter(lambda f: not f.endswith("testbench.sv"), sources)

    delay = subprocess.run(["yosys", "-s", f"{tbpath}/delay.ys", *fs],
        capture_output=True,
        check=True,
        text=True,
    )
    fs = filter(lambda f: not f.endswith("testbench.sv"), sources)
    area = subprocess.run(["yosys", "-s", f"{tbpath}/area.ys", *fs],
        capture_output=True,
        check=True,
        text=True,
    )

    s = r'Estimated number of transistors:\s*(\d*)'
    m = re.findall(s, area.stdout)
    area = int(m[0])
    set_leaderboard_value(area)

@leaderboard("delay")
def test_delay(set_leaderboard_value=None):
    # This line must be first
    parameters = dict(locals())
    d = dict()
    # This line must be first
    root = git.Repo(search_parent_directories=True).working_tree_dir
    sources = get_sources(root, tbpath)

    fs = ""
    fs = filter(lambda f: not f.endswith("testbench.sv"), sources)

    delay = subprocess.run(["yosys", "-s", f"{tbpath}/delay.ys", *fs],
        capture_output=True,
        check=True,
        text=True,
    )
    s = r'Latest arrival time in .* is (\d*)'
    m = re.findall(s, delay.stdout)
    delay = int(m[0])
    print(f"Unitless Delay: {m[0]}")
    set_leaderboard_value(delay)


@leaderboard("area*delay")
def test_areaxdelay(set_leaderboard_value=None):
    # This line must be first
    parameters = dict(locals())
    d = dict()
    # This line must be first
    root = git.Repo(search_parent_directories=True).working_tree_dir
    sources = get_sources(root, tbpath)

    fs = ""
    fs = filter(lambda f: not f.endswith("testbench.sv"), sources)

    delay = subprocess.run(["yosys", "-s", f"{tbpath}/delay.ys", *fs],
        capture_output=True,
        check=True,
        text=True,
    )
    s = r'Latest arrival time in .* is (\d*)'
    m = re.findall(s, delay.stdout)
    delay = int(m[0])

    fs = filter(lambda f: not f.endswith("testbench.sv"), sources)
    area = subprocess.run(["yosys", "-s", f"{tbpath}/area.ys", *fs],
        capture_output=True,
        check=True,
        text=True,
    )

    s = r'Estimated number of transistors:\s*(\d*)'
    m = re.findall(s, area.stdout)
    area = int(m[0])
    set_leaderboard_value(area * delay)

@cocotb.test()
async def run_test(dut):
    await Timer(1, units="ns")

    # You must set these to 0 before testing!
    assert_passerror(dut.error_o)
    assert_passerror(dut.pass_o)
    
    # But only set them when you're certain the target module passes/fails!
    await First(RisingEdge(dut.error_o), RisingEdge(dut.pass_o))
    print(f"Cocotb saw: error_o: {dut.error_o.value}, pass_o: {dut.pass_o.value}")
