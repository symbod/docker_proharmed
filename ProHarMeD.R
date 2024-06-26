#!/usr/bin/env Rscript

## Script name: ProHarMeD.R
##
## Purpose of script: ProHarMeD Harmonization
##
## Author: Klaudia Adamowicz
## Email: klaudia.adamowicz@uni-hamburg.de
##
## Date Created: 2024-06-25
##
## Copyright (c) Dr. Tanja Laske, 2024


# Load required libraries -----
suppressPackageStartupMessages({
  reticulate::use_virtualenv("/home/python_env", required = TRUE)
  library("proharmed")
  
  required_packages <- c("optparse","data.table","dplyr","stringr","ggrepel", "rjson")
  for(package in required_packages){
    #if(!require(package,character.only = TRUE, quietly = TRUE)) install.packages(package, dependencies = TRUE, quietly = TRUE)
    library(package, character.only = TRUE, quietly = TRUE)
  }
})

# Source the configuration file -----
source("config.R")

# ProHarMeD Harmonization -----------------

## Parse arguments -----

# save arguments
count_file_path <- params$count_file_path
out_dir <- params$out_dir

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE) #stops warnings if folder already exists

## Load data ----
count_data <- data.table::fread(count_file_path)

## Helper Function ----

# Function to save each data.frame in the list
save_data_frames <- function(in_list, subdir) {
  for (name in names(in_list)) {
    filepath <- file.path(subdir, paste0(name, ".csv"))
    # Create a copy of the data.frame for modification
    df <- in_list[[name]]
    # Check for columns that are lists and concatenate their elements
    list_cols <- sapply(df, is.list)
    if (any(list_cols)) {
      df[list_cols] <- lapply(df[list_cols], function(col) {
        sapply(col, function(cell) {
          if (is.null(cell)) return(NA)
          paste(cell, collapse = ";")
        })
      })
    }
    write.csv(df, file = filepath, row.names = FALSE)
  }
}

## Filter Protein IDs ----

### Set Preferences ----

# Use parameters from config.R
filtered_prot_results <- proharmed::filter_protein_ids(
  data = count_data, 
  protein_column = params$filter_protein_ids_params$protein_column, 
  organism = params$filter_protein_ids_params$organism, 
  rev_con = params$filter_protein_ids_params$rev_con, 
  keep_empty = params$filter_protein_ids_params$keep_empty, 
  res_column = params$filter_protein_ids_params$res_column,
  reviewed = params$filter_protein_ids_params$reviewed
)

filtered_prot_data <- filtered_prot_results$Modified_Data

### Save Data ----

subdir <- file.path(out_dir, "filtered_protein_ids", "")
dir.create(subdir, recursive = TRUE, showWarnings = FALSE)

# Save the data.frames in the list to the specified subdirectory
save_data_frames(filtered_prot_results, subdir)

### Create Plots ----

overview_plots <- proharmed::create_overview_plot(
  logging = filtered_prot_results$Overview_Log, 
  out_dir = subdir, 
  file_type = params$file_type
)

detailed_plot <- proharmed::create_filter_detailed_plot(
  logging = filtered_prot_results$Detailed_Log, 
  organism = params$filter_protein_ids_params$organism, 
  reviewed = params$filter_protein_ids_params$reviewed, 
  decoy = params$filter_protein_ids_params$rev_con, 
  out_dir = subdir, 
  file_type = params$file_type
)


## Remapp Gene Names ----

# Use parameters from config.R
remapped_prot_results <- proharmed::remap_genenames(
  data =  filtered_prot_data, 
  mode = params$remap_genenames_params$mode, 
  protein_column = params$remap_genenames_params$protein_column, 
  gene_column = params$remap_genenames_params$gene_column, 
  res_column = params$remap_genenames_params$res_column, 
  skip_filled = params$remap_genenames_params$skip_filled, 
  organism = params$remap_genenames_params$organism, 
  fasta = params$remap_genenames_params$fasta, 
  keep_empty = params$remap_genenames_params$keep_empty
)

remapped_prot_data <- remapped_prot_results$Modified_Data

### Save Data ----

subdir <- file.path(out_dir, "remap_gene_names", "")
dir.create(subdir, recursive = TRUE, showWarnings = FALSE)

# Save the data.frames in the list to the specified subdirectory
save_data_frames(remapped_prot_results, subdir)

### Create Plots ----

overview_plots <- proharmed::create_overview_plot(
  logging = remapped_prot_results$Overview_Log, 
  out_dir = subdir, 
  file_type = params$file_type
)

## Map Orthologs ----

# Use parameters from config.R
orthologs_prot_results <- proharmed::map_orthologs(
  data = remapped_prot_data, 
  gene_column = params$map_orthologs_params$gene_column, 
  organism = params$map_orthologs_params$organism, 
  tar_organism = params$map_orthologs_params$tar_organism, 
  res_column = params$map_orthologs_params$res_column, 
  keep_empty = params$map_orthologs_params$keep_empty
)

orthologs_prot_data <- orthologs_prot_results$Modified_Data

### Save Data ----

subdir <- file.path(out_dir, "map_orthologs", "")
dir.create(subdir, recursive = TRUE, showWarnings = FALSE)
# Save the data.frames in the list to the specified subdirectory
save_data_frames(orthologs_prot_results, subdir)

### Create Plots ----

overview_plots <- proharmed::create_overview_plot(
  logging = orthologs_prot_results$Overview_Log, 
  out_dir = subdir, 
  file_type = file_type
)

detailed_plot <- proharmed::create_ortholog_detailed_plot(
  logging = orthologs_prot_results$Detailed_Log, 
  organism = params$map_orthologs_params$organism, 
  out_dir = subdir, 
  file_type = params$file_type
)

## Final Mapping ----

common_columns <- intersect(names(count_data), names(orthologs_prot_data))
# Merge the datasets
harmonized_data <- merge(count_data, orthologs_prot_data, by = common_columns, all.x = TRUE)

# Save the final harmonized data to a CSV file
harmonized_data_path <- file.path(out_dir, "harmonized_data.csv")
write.csv(harmonized_data, harmonized_data_path, row.names = FALSE)

# Print message indicating successful save
cat("Final harmonized data saved to:", harmonized_data_path, "\n")
