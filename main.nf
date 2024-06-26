#!/usr/bin/env nextflow

params.output = "./output/"
params.count_file = '' // Path to count.txt

params.file_type = 'png'
params.protein_column = 'Protein IDs'
params.organism = 'rat'
params.rev_con = false
params.reviewed = false
params.mode = 'uniprot_one'
params.gene_column = 'Gene names'
params.skip_filled = true
params.fasta = ''
params.tar_organism = 'human'

// data
count_file = file(params.count_file)

// scripts
main_script = file("${projectDir}/ProHarMeD.R")

process proharmed {
    container 'kadam0/proharmed:0.0.1'
    publishDir params.output, mode: "copy"

    input:
    path script_file
    path count_file 

    output:                                
    path("proharmed_output", type:"dir")

    script:
    """
    Rscript $script_file --count_file $count_file --out_dir ./proharmed_output --file_type $params.file_type --protein_column $params.protein_column --organism $params.organism --rev_con $params.rev_con --reviewed $params.reviewed --mode $params.mode --gene_column $params.gene_column --skip_filled $params.skip_filled --fasta $params.fasta --tar_organism $params.tar_organism    
    """
}

workflow {
  proharmed(main_script, count_file)
}
