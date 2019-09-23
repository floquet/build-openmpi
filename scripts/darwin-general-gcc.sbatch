#!/bin/bash

#SBATCH --nodes=1
#SBATCH --qos=long
#SBATCH --time=48:00:00
#SBATCH --partition=general
#SBATCH --output=/scratch/users/dantopa/repos/spack/libraries/batch-output/darwin-general-gcc.txt
#SBATCH --job-name=hypre

printf '%s\n' "$(date) ${BASH_SOURCE[0]}"

export SECONDS=0
export cntr=0
function new_step(){
    export TIMER=${SECONDS}
    export action="${1}"
    cntr=$((cntr+1))
    echo ""
    echo "Step ${cntr}: ${action}"
}
function time_mark(){
    echo "${action} = $((${SECONDS} - ${TIMER})) s"
}

new_step "Set up spack"
export dir_libraries="/scratch/users/dantopa/repos/spack/libraries"
export compiler="gcc@4.8.5"

echo "cd ${dir_libraries}"
      cd ${dir_libraries}

echo ". share/spack/setup-env.sh"
      . share/spack/setup-env.sh

export tpl="gcc"
export versions="9.1.0  8.3.0  7.4.0"
export tail="% ${compiler} $(spack arch)"

for v in ${versions}; do
    new_step "spack install ${tpl} @ ${v} ${tail}"
              spack install ${tpl} @ ${v} ${tail}
    time_mark

    new_step "spack compiler find $(spack location --install-dir ${tpl} @ ${v})"
              spack compiler find $(spack location --install-dir ${tpl} @ ${v})
    time_mark

done

new_step "Execution complete for ${BASH_SOURCE[0]}"
echo ""; echo "total time used = ${SECONDS} s"
date
