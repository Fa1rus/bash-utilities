#!/bin/bash

# Script to batch convert MOV files (.mov / .MOV) or a single MOV file to MP4 format using ffmpeg.
# Usage:
#   ./convert_mov_to_mp4.sh [path_to_file_or_dir] [options]
#
# Examples:
#   ./convert_mov_to_mp4.sh                      # Convert all MOV files in current directory
#   ./convert_mov_to_mp4.sh /path/to/videos       # Convert all MOV files in specified directory
#   ./convert_mov_to_mp4.sh /path/to/video.mov    # Convert a single MOV file
#   ./convert_mov_to_mp4.sh /path/to/videos --copy # Stream copy (fast, no re-encoding)

# Default settings
TARGET=""
USE_COPY=false
OVERWRITE=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --copy|-c)
            USE_COPY=true
            ;;
        --overwrite|-f)
            OVERWRITE=true
            ;;
        -h|--help)
            echo "Usage: $0 [FILE_OR_DIRECTORY] [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --copy, -c       Use stream copy (-c copy) for fast conversion without re-encoding"
            echo "  --overwrite, -f  Overwrite existing MP4 files without asking"
            echo "  --help, -h       Display this help message"
            exit 0
            ;;
        *)
            if [[ -e "$arg" ]]; then
                TARGET="$arg"
            fi
            ;;
    esac
done

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: 'ffmpeg' is not installed. Please install ffmpeg first."
    exit 1
fi

# Enable case-insensitive globbing
shopt -s nullglob nocaseglob

mov_files=()

if [[ -z "$TARGET" ]]; then
    # Default to current directory
    TARGET="."
    mov_files=("./"*.mov)
elif [[ -f "$TARGET" ]]; then
    # Target is a single file
    mov_files=("$TARGET")
elif [[ -d "$TARGET" ]]; then
    # Target is a directory
    mov_files=("$TARGET"/*.mov)
else
    echo "Error: '$TARGET' is neither a valid file nor a directory."
    exit 1
fi

if [[ ${#mov_files[@]} -eq 0 ]]; then
    echo "No .mov or .MOV files found in '$TARGET'."
    exit 0
fi

echo "=========================================="
echo " Starting MOV to MP4 Conversion"
echo " Target           : $TARGET"
echo " Total MOV Files  : ${#mov_files[@]}"
if [ "$USE_COPY" = true ]; then
    echo " Mode             : Stream Copy (-c copy)"
else
    echo " Mode             : Re-encode (H.264 / AAC)"
fi
echo "=========================================="
echo ""

converted_count=0
skipped_count=0
failed_count=0

for file in "${mov_files[@]}"; do
    filename=$(basename "$file")
    filename_no_ext="${filename%.*}"
    output_dir=$(dirname "$file")
    output_file="$output_dir/$filename_no_ext.mp4"

    # Check if target file already exists
    if [[ -f "$output_file" && "$OVERWRITE" = false ]]; then
        echo "[SKIP] '$output_file' already exists. Use --overwrite to replace."
        skipped_count=$((skipped_count + 1))
        continue
    fi

    echo "[CONVERTING] '$file' -> '$output_file'..."

    if [ "$USE_COPY" = true ]; then
        # Fast copy without re-encoding
        if ffmpeg -hide_banner -loglevel error -y -i "$file" -c copy "$output_file"; then
            echo "[SUCCESS] Saved to '$output_file'"
            converted_count=$((converted_count + 1))
        else
            echo "[ERROR] Failed to convert '$file'"
            failed_count=$((failed_count + 1))
        fi
    else
        # Re-encode to universal MP4 (H.264 / AAC)
        if ffmpeg -hide_banner -loglevel error -stats -y -i "$file" \
            -c:v libx264 -preset fast -crf 22 -c:a aac -b:a 192k \
            -movflags +faststart "$output_file"; then
            echo "[SUCCESS] Saved to '$output_file'"
            converted_count=$((converted_count + 1))
        else
            echo "[ERROR] Failed to convert '$file'"
            failed_count=$((failed_count + 1))
        fi
    fi
    echo "------------------------------------------"
done

echo ""
echo "=========================================="
echo " Conversion Summary"
echo " Converted : $converted_count"
echo " Skipped   : $skipped_count"
echo " Failed    : $failed_count"
echo "=========================================="

