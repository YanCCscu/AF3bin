mkdir lptd_topmatch
awk -F"\t" '$8>=0.5{gsub("_summary_confidences.json","");printf("cp lptdout/%s/%s_model.cif lptd_topmatch/M%05d_%s_model.cif\n",$1,$1,NR,$1)}' lptd_af3.out|xargs -I{} sh -c {}

awk -F"\t" '$8>=0.5{gsub("_summary_confidences.json","");printf("cp bamaout/%s_model.cif bama_topmatch/M%05d_%s_model.cif\n",$1,NR,$1)}' bama_af3.out |xargs -I{} sh -c {}

