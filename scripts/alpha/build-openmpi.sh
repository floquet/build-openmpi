#!/bin/bash -l
printf '%s\n' "$(date) ${BASH_SOURCE[0]}" # who I am

#    repo_dir="/scratch/users/dantopa/repos/gitlab/build-openmpi/scripts/alpha"
#   spack_dir="openmpi.arm.spack"
# scripts_dir="${repo_dir}/${spack_dir}-scripts"
#     tpl_dir="/scratch/users/dantopa/new-spack/${spack_dir}"

export ymd=$(date +%Y-%m-%d-%H-%M)
mkdir -p ${scripts_dir}/yaml

echo ""
echo "\${repo_dir}    = ${repo_dir}"
echo "\${spack_dir}   = ${spack_dir}"
echo "\${tpl_dir}     = ${tpl_dir}"
echo "\${scripts_dir} = ${scripts_dir}"
echo "\${SPACK_ROOT}  = ${SPACK_ROOT}"
echo ""

# activate spack
cd ${tpl_dir}
. share/spack/setup-env.sh
spack clean -a

for v in ${tpl_versions}; do
    for c in ${myCompilers}; do
        file_output="${scripts_dir}/${tpl}-${v}-${c}.out"
        echo $(date) > ${file_output}
        echo ""
        echo "spack ${spack_flag_fore} install ${spack_flag_aft} ${tpl} @ ${v} % ${c} ${spack_overrides}   > ${file_output} 2>&1"
        echo "spack ${spack_flag_fore} install ${spack_flag_aft} ${tpl} @ ${v} % ${c} ${spack_overrides}" >> ${file_output} 2>&1
              spack ${spack_flag_fore} install ${spack_flag_aft} ${tpl} @ ${v} % ${c} ${spack_overrides}  >> ${file_output} 2>&1
        echo ""
             spack clean -a
    done
done

echo "lss ${tpl_dir}"
      lss ${tpl_dir}
echo "lss ${SPACK_ROOT}"
      lss ${SPACK_ROOT}
echo "lss ${repo_dir}"
      lss ${repo_dir}
echo "lss ${spack_dir}"
      lss ${spack_dir}
echo "lss ${scripts_dir}"
      lss ${scripts_dir}

# what has been built?
echo $(date) > "${scripts_dir}/spack.find.txt"
spack find  >> "${scripts_dir}/spack.find.txt"

echo $(date)        > "${scripts_dir}/spack.find.openmpi.txt"
spack find openmpi >> "${scripts_dir}/spack.find.openmpi.txt"

# move output files
cp -a ${tpl_dir} ${scripts_dir}

# copy yamls
cp ${SPACK_ROOT}/etc/spack/defaults/*.yaml ${scripts_dir}/yaml

# sweep configuration
export checks="compilers mirrors packages modules config"
for c in ${checks};do
    spack config get ${c} > ${scripts_dir}/yaml/${c}.config
done

# move batch output file
mv ${repo_dir}/slurm*    ${scripts_dir}/.
mv ${repo_dir}/batch.out ${scripts_dir}/batch-${ymd}.out

# copy this file
cp ${repo_dir}/${BASH_SOURCE[0]} > ${scripts_dir}/.

# commit
git add -A .
git commit -m "${host_name} ${partition} node ${node_name} ${ymd}"
