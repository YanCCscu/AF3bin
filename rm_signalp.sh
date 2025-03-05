#!/bin/bash

# 检查是否提供输入的 fasta 文件
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 input_fasta_file"
    exit 1
fi

# 定义输入和输出文件名
input_fasta=$1
output_dir=${input_fasta%.*}_"signalp_output"
processed_fasta="$output_dir/processed_entries.fasta"
processed_id="$output_dir/processed_id.txt"
nonprocessed_fasta="$output_dir/noprocessed_entries.fasta"
final_output_fasta=${input_fasta%.*}_"rmS.fasta"

# 激活 conda 环境
source /software/Anaconda3/bin/activate ProteinCluster
#signalp_path=/data/share/OriginTools/anaconda3/envs/signalp
#source /data/share/OriginTools/OriginTools/anaconda3/bin/activate $signalp_path


# 创建输出目录
mkdir -p "$output_dir"

# 运行 signalp6 去除信号肽
signalp6 -ff "$input_fasta" -od "$output_dir" -org eukarya

# 提取未被处理的序列
seqkit fx2tab -in "$processed_fasta" > "$processed_id"
seqkit grep --line-width 0 -v -f "$processed_id" "$input_fasta" > "$nonprocessed_fasta"

# 合并 processed 和未被处理的序列
cat "$processed_fasta" "$nonprocessed_fasta" > "$final_output_fasta"

echo "Final processed fasta file is generated: $final_output_fasta"

#conda activate ProteinCluster
#signalp6 -ff retitle_FTX3.fas -od 3FTX_rmS -org eukarya
#seqkit grep -v -f <(seqkit fx2tab -in 3FTX_rmS/processed_entries.fasta) retitle_FTX3.fas >3FTX_rmS/noprocessed_entries.fasta
