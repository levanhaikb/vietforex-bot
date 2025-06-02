#!/bin/bash

FILE="index.js"

# Count axios declarations
COUNT=$(grep -c "const axios = require('axios')" $FILE)

echo "Found $COUNT axios declarations"

if [ $COUNT -gt 1 ]; then
    echo "Fixing duplicate axios..."
    
    # Keep first occurrence, remove others
    awk '/const axios = require\('\''axios'\''\)/ && !f{f=1; print; next} 
         !/const axios = require\('\''axios'\''\)/' $FILE > temp.js
    
    mv temp.js $FILE
    echo "✅ Fixed! Removed duplicate axios"
else
    echo "✅ No duplicate axios found"
fi

# Check result
echo "Checking result..."
grep -n "const axios" $FILE | head -5
