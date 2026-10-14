"""Exercise the enabled plugin inside the actual editor, with a bounded lifetime."""
import os
import pathlib
import re
import subprocess

root = pathlib.Path(__file__).resolve().parents[1]
env = os.environ.copy(); env["ARCHELYS_WORKSHOP_EDITOR_CHECKS"] = "1"
result = subprocess.run(["godot", "--headless", "--path", str(root / "game"), "--editor"], env=env, capture_output=True, text=True, timeout=60)
output = result.stdout + result.stderr
print(output)
marker = re.search(r"WORKSHOP EDITOR: ([1-9][0-9]*) checks, 0 failures", output)
if result.returncode or marker is None or "SCRIPT ERROR:" in output or "\nERROR:" in output:
    raise SystemExit("Godot workshop editor checks failed")
