#!/bin/bash
[[ $#  -lt 1 ]] && echo "sh $0 batchfile [group] [max]" && exit 1
[[ $#  -ge 2 ]] && cgrp=$2 || cgrp="gpu,smp"
[[ $#  -ge 3 ]] && MAX=$3 || MAX=200
[[ -d srundir ]] || mkdir -p srundir
DATE=$(date +%m%d_%H%M)
inbatchfile=$1
nline=$(awk 'END{print NR}' $inbatchfile)
for i in $(seq 1 $nline)
do
	runfile=srundir/srun_${DATE}_${i}.sh
	cat <<EOF >$runfile
#!/bin/bash
#SBATCH -J J${DATE}_${i}
#SBATCH -p ${cgrp}
#SBATCH -x gpu3
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --gres gpu:1
#SBATCH -o ${runfile}_%j.out
#SBATCH -e ${runfile}_%j.err
EOF
	cont=$(sed -n "${i}p" $inbatchfile)
	sed -i "$ a${cont}" $runfile
	while true
	do
		njobs=$(squeue -l -u yang123 | wc -l)
		if [[ $njobs -lt $MAX ]]
		then
			sbatch $runfile
			echo "Submitted job $i: $runfile (Total in queue: $njobs)"
			break
		else
			echo "Job limit reached ($njobs/$MAX). Waiting..."
			sleep 30  # 等待 10 秒后重新检查
		fi
	done
done
echo "All jobs submitted."
