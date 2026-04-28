#!/bin/bash
mkdir -p assets/fonts
BASE="https://github.com/google/fonts/raw/main/ofl/poppins"
curl -fsSL "$BASE/Poppins-Regular.ttf"  -o assets/fonts/Poppins-Regular.ttf
curl -fsSL "$BASE/Poppins-Medium.ttf"   -o assets/fonts/Poppins-Medium.ttf
curl -fsSL "$BASE/Poppins-SemiBold.ttf" -o assets/fonts/Poppins-SemiBold.ttf
curl -fsSL "$BASE/Poppins-Bold.ttf"     -o assets/fonts/Poppins-Bold.ttf
echo "✅ Fonts downloaded"
ls -lh assets/fonts/
