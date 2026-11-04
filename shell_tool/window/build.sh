#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bin_dir="$(dirname "$script_dir")/bin"

mkdir -p "$bin_dir"
swiftc -O "$script_dir/tilt_window_arg.swift" -o "$bin_dir/window-tool"
echo "Built $bin_dir/window-tool"
