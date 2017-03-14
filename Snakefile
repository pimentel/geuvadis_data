# Make sure to change this on your local installation
BASE = '/Users/hjp/analysis/geuvadis_analysis'

SAMPLE_NAMES = dict()
with open('metadata/clean.tsv') as file_handle:
    for line in file_handle:
        line = line.split('\t')
        SAMPLE_NAMES[line[0]] = line[1:3]

SAMPLE_KEYS = sorted(list(SAMPLE_NAMES.keys()))
SAMPLE_KEYS = SAMPLE_KEYS[0]

rule all:
    input:
        expand(BASE + '/rna/{sample}/{sample}_1.fastq.gz', sample = SAMPLE_KEYS),
        expand(BASE + '/genotypes/GEUVADIS.chr{i}.PH1PH2_465.IMPFRQFILT_BIALLELIC_PH.annotv2.genotypes.vcf.gz',
            i = range(1, 23))

rule get_rna:
    output:
        BASE + '/rna/{sample}/{sample}_1.fastq.gz',
        BASE + '/rna/{sample}/{sample}_2.fastq.gz'
    threads: 1
    run:
        left = SAMPLE_NAMES[wildcards.sample][0]
        right = SAMPLE_NAMES[wildcards.sample][1]
        shell('curl -s -o {output[0]} ' + left)
        shell('curl -s -o {output[1]} ' + right)

rule get_genotypes:
    output:
        BASE + '/genotypes/ALL.phase1_release_v3.20101123.snps_indels_sv.sites.gdid.gdannot.v2.vcf.gz',
        BASE + '/genotypes/Phase1.Geuvadis_dbSnp137_idconvert.txt.gz',
        expand(BASE + '/genotypes/GEUVADIS.chr{i}.PH1PH2_465.IMPFRQFILT_BIALLELIC_PH.annotv2.genotypes.vcf.gz',
            i = range(1, 23))
    threads: 1
    shell:
        'wget -r -nH'
        ' -P {BASE}/genotypes/'
        ' ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/experiment/GEUV/E-GEUV-1/genotypes/'
        ' && '
        'find {BASE}/genotypes -name "*.gz" | xargs -I$ mv $ {BASE}/genotypes/'
        ' && '
        'rm -rf {BASE}/pub'

rule md5:
    output:
        BASE + '/metadata/results.md5'
    shell:
        'cd {BASE}'
        ' && '
        'md5sum -c metadata/fastq.md5'
        ' > '
        '{output}'
