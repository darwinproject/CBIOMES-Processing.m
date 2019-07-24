#!/bin/bash

#SBATCH -o cmap_interp.log-%j-%a
#SBATCH -a 1-32
#SBATCH --mem-per-cpu=12000

matlab -nodisplay -r "runGroups_cs510; exit;"