#!/bin/bash

rm -rf src/Scripts/SDOSTraduora
swift build -c release
mkdir -p src/Scripts
cp .build/release/SDOSTraduora src/Scripts/SDOSTraduora