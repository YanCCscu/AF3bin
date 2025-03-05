#!/usr/bin/env python3
import os
import sys
import json

def process_confidence_files(json_files):
    """
    Process multiple AlphaFold 3 confidence JSON files and output values to a single line for each file.

    Args:
        json_files (list): List of paths to JSON files to process.

    """
    FirstTry=1
    for json_file in json_files:
        try:
            with open(json_file, 'r') as f:
                data = json.load(f)

            # Extract keys and values, assuming all values are scalar
            output_line = [os.path.basename(json_file)]  # Start with the file name
            keys_line =['filename']
            for key, value in data.items():
                if FirstTry:
                    keys_line.append(f"{key}")
                output_line.append(f"{value}")

            if FirstTry:
                print("\t".join(keys_line))
                FirstTry=0
            # Print all values on a single line
            print("\t".join(output_line))

        except FileNotFoundError:
            print(f"File not found: {json_file}")
        except json.JSONDecodeError:
            print(f"Error decoding JSON: {json_file}")
        except Exception as e:
            print(f"An error occurred with file {json_file}: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: python {sys.argv[0]} <json_file1> [<json_file2> ...]")
        sys.exit(1)

    json_files = sys.argv[1:]
    process_confidence_files(json_files)
