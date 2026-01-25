#!/bin/bash

# Convert all PNG files in assets/images to WebP and remove originals
# Requires: brew install webp

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="$PROJECT_ROOT/assets/images"

if ! command -v cwebp &> /dev/null; then
    echo "Error: cwebp not found. Install with: brew install webp"
    exit 1
fi

if [ ! -d "$IMAGES_DIR" ]; then
    echo "Error: $IMAGES_DIR not found"
    exit 1
fi

count=0
while IFS= read -r -d '' file; do
    output="${file%.png}.webp"
    echo "Converting: $(basename "$file")"
    cwebp -q 90 "$file" -o "$output" -quiet
    rm "$file"
    ((count++))
done < <(find "$IMAGES_DIR" -type f -name "*.png" -print0)

echo "Done. Converted and removed $count PNG file(s)."
