import os
from glob import glob

extensions = [
    "*.bin",
    "*.hex",
    "*.o",
    "*.map",
]

for e in extensions:
    for f in glob(os.path.join(os.getcwd(), e)):
        os.remove(f)