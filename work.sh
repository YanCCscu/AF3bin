sh run_alphafold.sh Injson/AF3_bama_recom_databama_recom_data.json af3out

for f in 3ftx/*.json;do python make_batch_json_2protein.py bama_recom/bama_recom_data.json $f;done >batch_run2protein.sh

python summ_confidences.py af3out/*/*_summary_confidences.json

title="filename\tchain_iptm\tchain_pair_iptm\tchain_pair_pae_min\tchain_ptm\tfraction_disordered\thas_clash\tiptm\tptm\tranking_score"
python summ_confidences.py af3out/*/*_summary_confidences.json|tail -n +2|sort -t $'\t' -k8nr|sed "1i$title" |less -S 

awk -F"\t" '$8>=0.8&&$9>=0.5{gsub("_summary_confidences.json","");printf("cp gpviout/%s/%s_model.cif gpvi_topmatch/M%05d_%s_model.cif\n",$1,$1,NR-1,$1)}' gpvi_ranking.txt |xargs -I{} sh -c {}

for f in ../TXDB/txdb_nr/*/*_data.json; do python make_batch_json_2protein.py ljcdir/lptd/lptd_data.json $f;done >batch_run2lptd_txdb.sh


for f in /share/home/af3out/*/*_data.json;do python make_batch_json_2protein.py bama_recom/bama_recom_data.json $f;done >batch_run2bama_txdb.sh
