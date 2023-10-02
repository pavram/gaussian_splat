#!/bin/bash

conda activate gaussian_splatting

INPUT=/workspace/input
OUTPUT=/workspace/output

iterations=$1
shift

mkdir -p ${INPUT}
mkdir -p ${OUTPUT}

nvidia-smi

cd /workspace/gaussian-splatting

for folder in ${INPUT}/*; do
 [ -d "$folder" ] || continue
 [[ "$folder" == *".processed"* ]] && continue

  outfolder=$OUTPUT/$(basename ${folder})_output_${iterations}
  mkdir -p ${outfolder}
  
  conda run --no-capture-output --name gaussian_splatting python train.py -s ${folder} --model_path ${outfolder} --iterations ${iterations} "$@"

  # Rename the folder to [input].processed once done
  mv ${folder} ${folder}.processed
done
