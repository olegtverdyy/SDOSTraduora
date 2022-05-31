#!/bin/bash
rm -rf .build
rm -rf src/Scripts/SDOSTraduora
xcrun swift build -c release --arch arm64 --arch x86_64
mkdir -p src/Scripts
cp .build/apple/Products/Release/SDOSTraduora src/Scripts/SDOSTraduora
