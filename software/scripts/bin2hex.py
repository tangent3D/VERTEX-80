from pathlib import Path
import sys

input_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])

data = input_path.read_bytes()

with output_path.open("w") as f:
    for byte in data:
        f.write(f"{byte:02X}\n")