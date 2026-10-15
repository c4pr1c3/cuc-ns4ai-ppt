#!/bin/bash

# Extract mermaid code blocks, save to temp file, render to image, and replace in markdown
INPUT_FILE="$1"
OUTPUT_DIR="$2"
BASENAME=$(basename "$INPUT_FILE" .md)

# Create images directory if it doesn't exist
IMAGES_DIR="$OUTPUT_DIR/images"
mkdir -p "$IMAGES_DIR"

# Temporary file for processing
TEMP_MD="$OUTPUT_DIR/${BASENAME}_processed.md"
cp "$INPUT_FILE" "$TEMP_MD"

# Extract mermaid blocks
# This is a simple state machine implemented in awk to extract mermaid blocks
awk -v images_dir="$IMAGES_DIR" -v basename="$BASENAME" '
BEGIN {
    in_mermaid = 0;
    block_count = 0;
}
/^```mermaid/ {
    in_mermaid = 1;
    block_count++;
    mmd_file = images_dir "/" basename "_" block_count ".mmd";
    svg_file = "images/" basename "_" block_count ".svg";
    print "Generating " mmd_file > "/dev/stderr";
    next;
}
/^```$/ {
    if (in_mermaid) {
        in_mermaid = 0;
        print "![](" svg_file ")";
        next;
    }
}
{
    if (in_mermaid) {
        print > mmd_file;
    } else {
        print;
    }
}
' "$INPUT_FILE" > "$TEMP_MD"

# Render mermaid files to SVG
find "$IMAGES_DIR" -name "${BASENAME}_*.mmd" | while read mmd_file; do
    svg_file="${mmd_file%.mmd}.svg"
    echo "Rendering $mmd_file to $svg_file"
    # Use mmdc with puppeteer config if needed, or default
    # Note: We need to point to a valid puppeteer config if sandbox issues occur
    mmdc -i "$mmd_file" -o "$svg_file" -b transparent
done

echo "$TEMP_MD"
