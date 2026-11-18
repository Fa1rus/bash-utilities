# Bash Utilities

A collection of small, practical Bash scripts for everyday file and media management.

## Scripts

### `convert_mov_to_mp4.sh`
Batch-convert `.mov` / `.MOV` files (or a single file) to `.mp4` using `ffmpeg`.

```bash
./convert_mov_to_mp4.sh                      # Convert all MOV files in current directory
./convert_mov_to_mp4.sh /path/to/videos       # Convert all MOV files in a directory
./convert_mov_to_mp4.sh /path/to/video.mov    # Convert a single MOV file
./convert_mov_to_mp4.sh /path/to/videos --copy      # Fast stream copy without re-encoding
./convert_mov_to_mp4.sh /path/to/videos --overwrite # Overwrite existing MP4 files
```

### `remove_1_suffix.sh`
Batch-rename files in the current directory by stripping duplicate ` (1)` or `(1)` suffixes while safely skipping collisions if the target filename already exists.

```bash
./remove_1_suffix.sh
```

## Requirements

- `bash`
- `ffmpeg` (for `convert_mov_to_mp4.sh`)
