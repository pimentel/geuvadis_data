SAMPLE_NAMES = dict()
with open('metadata/clean.tsv') as file_handle:
    for line in file_handle:
        line = line.split('\t')
        SAMPLE_NAMES[line[0]] = line[1:3]

SAMPLE_KEYS = sorted(list(SAMPLE_NAMES.keys()))
SAMPLE_KEYS = SAMPLE_KEYS[0]

rule all:
    input:
        expand('data/{sample}/{sample}_1.fastq.gz', sample = SAMPLE_KEYS)

rule get_data:
    output:
        'data/{sample}/{sample}_1.fastq.gz',
        'data/{sample}/{sample}_2.fastq.gz'
    run:
        left = SAMPLE_NAMES[wildcards.sample][0]
        right = SAMPLE_NAMES[wildcards.sample][1]
        shell('curl -s -o {output[0]} ' + left)
        shell('curl -s -o {output[1]} ' + right)
