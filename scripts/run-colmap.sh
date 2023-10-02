#!/bin/bash

INPUT=/workspace/input
OUTPUT=/workspace/output


# Make sure the output folders exist.
mkdir -p ${INPUT}
mkdir -p ${OUTPUT}

# Just to confirm your GPU is attached and working
nvidia-smi

# For each file in the Input folder
for fullfile in ${INPUT}/*; do
  [ -f "$fullfile" ] || continue
  [[ "$fullfile" == *".processed"* ]] && continue

  infile=$(basename -- "$fullfile")
  outpath=${OUTPUT}/${infile%.*}_$1

  mkdir -p "${outpath}/input"

  # Split the input video to the input images for Colmap
  ffmpeg -i ${fullfile} -r $1 "${outpath}/input/image_%04d.jpg" -y && \
      mv ${fullfile} ${fullfile}.processed

done

for folder in $OUTPUT/*; do
  [ -d "$folder" ] || continue
  # Use the convert.py to perform colmap processing
  conda run --no-capture-output python convert.py -s "${folder}" --resize
done
