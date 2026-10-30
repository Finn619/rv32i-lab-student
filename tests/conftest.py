# Makes tests/common importable from every lab's tests (and from inside the
# simulator, because the cocotb runner forwards sys.path as PYTHONPATH).
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).parent / "common"))
