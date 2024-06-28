# Configuration Parameters for ProHarMeD

# Load required libraries for argument parsing
suppressPackageStartupMessages(library(optparse))

# Default Configuration Parameters for ProHarMeD
default_params <- list(
  out_dir = "",
  file_type = "png",
  
  # Filter Protein IDs Parameters
  filter_protein_ids_params = list(
    protein_column = "Protein.IDs",
    organism = "rat",
    rev_con = FALSE,
    keep_empty = FALSE,
    res_column = "FilteredProteinIDs",
    reviewed = FALSE
  ),
  
  # Remap Gene Names Parameters
  remap_genenames_params = list(
    mode = "uniprot_one",
    protein_column = "FilteredProteinIDs",
    gene_column = "Gene.Names",
    res_column = "RemappedGeneNames",
    skip_filled = TRUE,
    organism = "rat",
    fasta = NULL,
    keep_empty = TRUE
  ),
  
  # Map Orthologs Parameters
  map_orthologs_params = list(
    gene_column = "RemappedGeneNames",
    organism = "rat",
    tar_organism = "human",
    res_column = "Orthologs",
    keep_empty = TRUE
  )
)

# Set Up Argument Parser
parser <- OptionParser()
parser <- add_option(parser, c("-c", "--count_file"), help = "Preprocessed count file")
parser <- add_option(parser, c("-o", "--out_dir"), help = "Directory for output files", default = "")
parser <- add_option(parser, "--file_type", help = "Directory for output files", default = "png")

# General
parser <- add_option(parser, "--protein_column", help = "Name of column with protein IDs", default = "Protein IDs")
parser <- add_option(parser, "--organism", help = "Organism", default = "rat")

# For Filter Proteins
parser <- add_option(parser, "--rev_con", help = "Reverse concatenation flag", type = "logical", default = FALSE)
parser <- add_option(parser, "--reviewed", help = "Reviewed flag", type = "logical", default = FALSE)

# For Remapp Gene Names
parser <- add_option(parser, "--mode", help = "Mode for remapping gene names", default = "uniprot_one")
parser <- add_option(parser, "--gene_column", help = "Name of gene column", default = "Gene names")
parser <- add_option(parser, "--skip_filled", help = "Skip filled flag", type = "logical", default = TRUE)
parser <- add_option(parser, "--fasta", help = "Path to FASTA file", default = NULL)

# For Ortholog Mapping
parser <- add_option(parser, "--tar_organism", help = "Target organism for ortholog mapping", default = "human")

# Parse arguments
args <- parse_args(parser)

# Override default parameters with command-line arguments
params <- default_params

params$count_file_path <- args$count_file
params$out_dir <- args$out_dir

params$filter_protein_ids_params$protein_column <- args$protein_column
params$filter_protein_ids_params$organism <- args$organism
params$filter_protein_ids_params$rev_con <- args$rev_con
params$filter_protein_ids_params$reviewed <- args$reviewed

params$remap_genenames_params$mode <- args$mode
params$remap_genenames_params$gene_column <- args$gene_column
params$remap_genenames_params$skip_filled <- args$skip_filled
params$remap_genenames_params$fasta <- args$fasta

params$map_orthologs_params$tar_organism <- args$tar_organism


