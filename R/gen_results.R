#' Generate results
#'
#' Generates EWCE results on multiple gene lists in parallel by calling
#' \code{ewce_para}. It allows you to stop the analysis and then continue later
#' from where you left off as it checks the results output directory for
#'finished gene lists and removes them from the input.
#' It also excludes gene lists with
#' less than 4 unique genes (which cause errors in EWCE analysis).
#'
#' The gene_data should be a data frame that contains a column of gene
#' list names (e.g. the column may be called "Phenotype"), and a column of
#' genes (e.g. "Gene"). For example:
#'
#' | Phenotype        | Gene   |
#' | ---------------- | ------ |
#' | "Abnormal heart" | gene X |
#' | "Abnormal heart" | gene Y |
#' | "Poor vision"    | gene Z |
#' | "Poor vision"    | gene Y |
#' etc...
#'
#' For more information on this see docs for get_gene_list
#' (\link[MultiEWCE]{get_gene_list}).
#' @param overwrite_past_analysis overwrite previous results
#'  in the results dir \code{bool}.
#' @param save_dir Folder to save merged results in.
#' @inheritParams ewce_para
#' @inheritParams EWCE::bootstrap_enrichment_test
#' @returns All results as a dataframe.
#'
#' @export
#' @importFrom HPOExplorer load_phenotype_to_genes
#' @importFrom stringr str_replace_all
#' @examples
#' gene_data <- HPOExplorer::load_phenotype_to_genes()
#' ctd <- load_example_ctd()
#' list_names <- unique(gene_data$Phenotype)[seq_len(3)]
#' all_results <- gen_results(ctd = ctd,
#'                            gene_data = gene_data,
#'                            list_names = list_names,
#'                            reps = 10)
gen_results <- function(ctd,
                        gene_data,
                        list_name_column = "Phenotype",
                        gene_column = "Gene",
                        list_names = unique(gene_data[[list_name_column]]),
                        bg = unique(gene_data[[gene_column]]),
                        overwrite_past_analysis = FALSE,
                        reps = 100,
                        annotLevel = 1,
                        genelistSpecies = "human",
                        sctSpecies = "human",
                        seed = 2022,
                        cores = 1,
                        save_dir_tmp = NULL,
                        save_dir = tempdir(),
                        verbose = FALSE) {
  # templateR:::source_all()
  # templateR:::args2vars(gen_results)

  #### remove gene lists that do not have enough valid genes (>= 4) ####
  list_names <- get_valid_gene_lists(ctd = ctd,
                                     annotLevel = annotLevel,
                                     list_names = list_names,
                                     gene_data = gene_data,
                                     list_name_column = list_name_column,
                                     gene_column = gene_column)

  #### Create results directory and remove finished gene lists ####
  if (!file.exists(save_dir)) {
    dir.create(save_dir, showWarnings = FALSE, recursive = TRUE)
  }
  if (!overwrite_past_analysis) {
    list_names <- get_unfinished_list_names(list_names = list_names,
                                            save_dir_tmp = save_dir_tmp)
  }
  #### Run analysis ####
  res_files <- ewce_para(ctd = ctd,
                         list_names = list_names,
                         gene_data = gene_data,
                         list_name_column = list_name_column,
                         gene_column = gene_column,
                         bg = bg,
                         reps = reps,
                         annotLevel= annotLevel,
                         genelistSpecies = genelistSpecies,
                         sctSpecies = sctSpecies,
                         seed = seed,
                         cores = cores,
                         save_dir_tmp = save_dir_tmp,
                         verbose = verbose)
  #### Merge results into one dataframe ####
  results_final <- merge_results(res_files = res_files,
                                 list_name_column = list_name_column)
  #### Save merged results ####
  if (!is.null(save_dir)) {
    save_path <- file.path(
      save_dir,
      gsub(" ","_",
        paste0("results_",stringr::str_replace_all(Sys.time(),":","-"),".rds")
      )
      )
    messager("Saving results ==>",save_path,v=verbose)
    saveRDS(results_final,save_path)
  }
  return(results_final)
}