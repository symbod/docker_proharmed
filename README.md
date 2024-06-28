
# README for ProHarMeD Harmonization Pipeline

## Overview
This repository contains a Nextflow pipeline for harmonizing proteomics data using the ProHarMeD package. The pipeline is designed to process and refine proteomic datasets, improving data clarity and utility by filtering protein IDs, remapping gene names, and mapping orthologs.

## Container
The corresponding Docker container, which is called in the Nextflow file, can be found here: https://hub.docker.com/repository/docker/kadam0/proharmed/general

## Usage
To run the pipeline, you need to specify several parameters:

1. `--count_file`: This flag should be followed by the path to your count file, which contains the raw counts data for your analysis.
2. `--out_dir`: Use this flag to specify the output directory where the results will be stored.
3. `--file_type`: The file type for plots (e.g., `png`, `pdf`).
4. `--protein_column`: Name of the column with protein IDs.
5. `--organism`: The organism for protein ID filtering.
6. `--rev_con`: Boolean flag indicating if decoy protein IDs should be kept.
7. `--reviewed`: Boolean flag indicating if protein IDs should be reduced to reviewed ones only.
8. `--mode`: Mode for remapping gene names.
9. `--gene_column`: Name of the column with gene names.
10. `--skip_filled`: Boolean flag indicating if already filled gene name cells should be skipped.
11. `--fasta`: Path to the FASTA file for remapping gene names.
12. `--tar_organism`: Target organism for ortholog mapping.

Example command:
```
./nextflow run main.nf --count_file path/to/count_file.txt --out_dir output_directory --file_type png --protein_column "Protein IDs" --organism rat --rev_con false --reviewed false --mode uniprot_one --gene_column "Gene names" --skip_filled true --fasta path/to/fasta_file.fasta --tar_organism human
```

## Output Description
The pipeline generates several output files and directories:

- **`filtered_protein_ids` Directory**: Contains filtered protein IDs with relevant details.
- **`remap_gene_names` Directory**: Contains remapped gene names.
- **`map_orthologs` Directory**: Contains ortholog mapping results.
- **`harmonized_data.csv`**: The final merged dataset after processing.

Each directory includes data files and visualization plots summarizing the processing steps and outcomes.

## Getting Started
To get started, clone this repository and ensure you have Nextflow installed. Prepare your count file according to the required format and run the command with the appropriate paths to your files. Check the output directory for results and detailed analysis.

---

**Note**: This README provides a general guide. Users should adjust paths and file names according to their specific project structure and requirements.

-----

## Parameters and Functions

### Filtering Protein IDs

The `filter_protein_ids` function processes a DataFrame containing protein IDs. It allows for the removal of decoy IDs, contamination IDs, and the option to filter IDs based on a specified organism. Additionally, the function can restrict protein IDs to reviewed ones and manage empty cells in the dataset.

#### Parameters

- `data`: A DataFrame that includes a column with protein IDs.
- `protein_column`: The name of the column in `data` that contains the protein IDs.
- `organism`: (Optional) Specify the organism to filter the protein IDs. Options: `human`, `rat`, `mouse`, `rabbit`.
- `rev_con`: (Optional) A boolean value indicating if decoy protein IDs should be kept. Default is `FALSE`.
- `keep_empty`: A boolean value indicating if rows with empty protein ID cells should be retained. Default is `FALSE`.
- `res_column`: The name of the column where the filtered protein IDs will be stored. If `NULL`, the original `protein_column` will be overwritten. Default is `FilteredProteinIDs`.
- `reviewed`: (Optional) A boolean value indicating if the protein IDs should be reduced to reviewed ones only. Default is `FALSE`.

### Remap Gene Names

The `remap_genenames` function remaps protein IDs to their associated gene names, offering various modes for filling empty entries or optionally replacing existing gene names.

#### Parameters

- `data`: A DataFrame containing a column with protein IDs.
- `mode`: Mode of refilling. Options: `all`, `fasta`, `uniprot`, `uniprot_primary`, `uniprot_one`. Default is `uniprot_one`.
- `protein_column`: Name of the column with protein IDs. Default is `FilteredProteinIDs`.
- `gene_column`: (Optional) Name of the column with gene names. Default is `Gene names`.
- `res_column`: Name of the column for results. If `NULL`, the `gene_column` will be overwritten. Default is `RemappedGeneNames`.
- `skip_filled`: (Optional) A boolean value indicating if already filled gene name cells should be skipped. Default is `TRUE`.
- `organism`: (Optional) Specify the organism for matching IDs. Options: `human`, `rat`, `mouse`, `rabbit`. Default is `rat`.
- `fasta`: (Optional) FASTA file to use when mode is `all` or `fasta`. Default is `NULL`.
- `keep_empty`: A boolean value indicating if rows with empty reduced gene names should be retained. Default is `TRUE`.

### Map Orthologs

The `map_orthologs` function maps gene names from one organism to their orthologs in another organism. This function is useful for cross-species analyses and comparative genomics studies.

#### Parameters

- `data`: A DataFrame containing a column with gene names.
- `gene_column`: The name of the column in `data` that contains the gene names. Default is `RemappedGeneNames`.
- `organism`: The organism corresponding to the current gene names in the data. Default is `rat`.
- `tar_organism`: The target organism to which you want to map the orthologs. Default is `human`.
- `res_column`: The name of the column where the orthologs will be stored. If `NULL`, the `gene_column` will be overwritten. Default is `Orthologs`.
- `keep_empty`: A boolean value indicating whether rows with empty cells (where orthologs could not be found) should be kept or deleted. Default is `TRUE`.

### Visualizing Results

#### Overview Plot

The `create_overview_plot` function generates an overview plot of the logging data. This plot provides a high-level summary of the data processing steps.

#### Parameters

- `logging`: A DataFrame containing the overview logging data returned by one of the ProHarMeD methods.
- `out_dir`: (Optional) The directory where the plot will be saved.
- `file_type`: (Optional) The file format for the saved plot. Options: `png`, `pdf`, `jpg`.

#### Detailed Plot for Filtered Protein IDs

The `create_filter_detailed_plot` function creates a detailed plot specifically for the logging data of the `filter_protein_ids` method. This plot provides insights into how the protein IDs were filtered based on various criteria.

#### Parameters

- `logging`: A DataFrame containing detailed logging data returned by the `filter_protein_ids` method.
- `organism`: The organism specified in the `filter_protein_ids` method.
- `reviewed`: The reviewed parameter value used in the `filter_protein_ids` method.
- `decoy`: The rev_con parameter value used in the `filter_protein_ids` method.
- `out_dir`: (Optional) The directory where the plot will be saved.
- `file_type`: (Optional) The file format for the saved plot.

#### Detailed Plot for Remapped Gene Names

The `create_remap_detailed_plot` function generates a detailed plot for the logging data associated with the `remap_genenames` method. This plot provides insights into the gene name remapping process.

#### Parameters

- `logging`: A DataFrame containing detailed logging data returned by the `remap_genenames` method.
- `out_dir`: (Optional) The directory where the plot will be saved.
- `file_type`: (Optional) The file format for the saved plot.

#### Detailed Plot for Mapped Orthologs

The `create_ortholog_detailed_plot` function generates a detailed plot for the logging data associated with the `map_orthologs` method. This plot illustrates the mapping of orthologs from one organism to another.

#### Parameters

- `logging`: A DataFrame containing detailed logging data returned by the `map_orthologs` method.
- `organism`: The source organism used in the `map_orthologs` method.
- `out_dir`: (Optional) The directory where the plot will be saved.
- `file_type`: (Optional) The file format for the saved plot.
