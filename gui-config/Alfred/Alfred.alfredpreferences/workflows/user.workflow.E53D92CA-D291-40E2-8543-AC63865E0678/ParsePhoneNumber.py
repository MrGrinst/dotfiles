import sys
import re

filename = sys.argv[1]
f = open(filename, "r")
text = f.read()
reg = re.compile(r"((\+\d) \(\d{3}\) \d{3}-\d{4})")
print(reg.findall(text)[0][0])
