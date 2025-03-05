#!/bin/bash
[[ $#  -lt 1 ]] && echo "sh $0 fasfile [Injson] [af3out]" && exit 1
[[ $#  -eq 2 ]] && jsondir=$2 || jsondir=Injson
[[ $#  -eq 3 ]] && af3out=$3 || af3out=af3out
[[ -d Injson ]] || mkdir -p $jsondir 

fasname=$1
retitlefas=retitle_$(basename ${fasname})
sed 's/\s\+.\+//' $fasname >$retitlefas
for f in `grep \> $retitlefas|tr -d "\r"`
do
        title=${f%%|*}
        title=${title#>}
        sequence=$(bioawk -c fastx '{if($name~"'$title'$"){print $seq}}' $retitlefas)
cat <<EOF >${jsondir}/AF3_${title}.json
{
  "name": "$title",
  "sequences": [
    {"protein": {
        "id": ["A"],
        "sequence":"$sequence"
      }}
  ],
  "modelSeeds": [11],
  "dialect": "alphafold3",
  "version": 1
}
EOF

echo "sh run_alphafold.sh ${jsondir}/AF3_${title}.json ${af3out}"
done
