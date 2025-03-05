#!/usr/bin/env python3
import os
import sys
import json
import subprocess

IDLIST=['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
def extract_block(json_file_path,homonumber=1,order=True):
	with open(json_file_path, 'r') as F:
		data = json.load(F)
		if homonumber <= 0:
			ablock=data['sequences']
			return(ablock)
		else:
			ablock=data['sequences'][0]
		if order:
			ablock['protein']['id']=IDLIST[:homonumber]
		else:
			ablock['protein']['id']=IDLIST[::-1][:homonumber]
	return ablock

def json2json(jsonfile1,jsonfile2,homonumber1=1,homonumber2=1):
	protein_block1=extract_block(jsonfile1,homonumber1,order=True) 
	protein_block2=extract_block(jsonfile2,homonumber2,order=False)
	title=os.path.basename(jsonfile1.replace(".json","").replace("_data",""))+"_"\
        +os.path.basename(jsonfile2.replace(".json","").replace("_data",""))
	if isinstance(protein_block1, list):
		seqlist=protein_block1+[protein_block2]
	else:
		seqlist=[protein_block1,protein_block2]
	#print("#",protein_block1,protein_block2,seqlist)
	json_content = {
		"name": title,
		"sequences":seqlist,
		"modelSeeds": [11],
		"dialect": "alphafold3",
		"version": 1
	}
	json_file_path = os.path.join("Injson", f"AF3_{title}.json")
	with open(json_file_path, 'w') as json_file:
		json.dump(json_content, json_file, indent=2)
	print(f"sh run_alphafold.sh {json_file_path} af3out")
 
def fas2json(fasname,jsonfile,homonumber):
	# Create Injson directory if it doesn't exist

	# Prepare retitled fasta file
	retitlefas = f"retitle_{os.path.basename(fasname)}"
	# Load protein block
	protein_block = extract_block(jsonfile,homonumber)

	# Process the input fasta file
	with open(fasname, 'r') as infile, open(retitlefas, 'w') as outfile:
		for line in infile:
			if line.startswith(">"):
				outfile.write(line.split()[0] + "\n")
			else:
				outfile.write(line)
	# Generate JSON files
	with open(retitlefas, 'r') as infile:
		lines = infile.readlines()

	titles = [line.strip()[1:] for line in lines if line.startswith(">")]
	sequences = {
		title: "" for title in titles
	}

	current_title = None
	for line in lines:
		if line.startswith(">"):
			current_title = line.strip()[1:]
		elif current_title:
			sequences[current_title] += line.strip()

	for title, sequence in sequences.items():
		json_content = {
			"name": title,
			"sequences": [
				protein_block,
				{
					"protein": {
						"id": ["ZZ"],
						"sequence": sequence
					}
				}
			],
			"modelSeeds": [11],
			"dialect": "alphafold3",
			"version": 1
		}
		json_file_path = os.path.join("Injson", f"AF3_{title}.json")
		with open(json_file_path, 'w') as json_file:
			json.dump(json_content, json_file, indent=2)
		print(f"sh run_alphafold.sh {json_file_path} af3out")

if __name__ == "__main__":
	if len(sys.argv) < 3:
		print(f"Usage: python {sys.argv[0]} fasfile|jsonfile jsonfile [homoNO1] [homoNO2]")
		sys.exit(1)
	fasname = sys.argv[1]
	jsonfile = sys.argv[2]
	if len(sys.argv) >= 4:
		homonumber=int(sys.argv[3])
	else:
		homonumber=1
	if len(sys.argv) >= 5:
		homonumber2=int(sys.argv[4])
	else:
		homonumber2=1
	os.makedirs("Injson", exist_ok=True)
	if fasname.endswith('.json'):
		json2json(fasname,jsonfile,homonumber,homonumber2)
	else:
		fas2json(fasname,jsonfile,homonumber,homonumber2)
