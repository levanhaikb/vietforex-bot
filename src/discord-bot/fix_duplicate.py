#!/usr/bin/env python3

with open('index.js', 'r') as f:
    lines = f.readlines()

seen_axios = False
new_lines = []

for line in lines:
    if "const axios = require('axios')" in line:
        if not seen_axios:
            new_lines.append(line)
            seen_axios = True
        else:
            print(f"Removed duplicate: {line.strip()}")
    else:
        new_lines.append(line)

with open('index.js', 'w') as f:
    f.writelines(new_lines)

print("✅ Fixed duplicate axios!")
