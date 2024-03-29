#' Gene and phenotype frequencies bar plot
#'
#' Plot the frequency of gene-phenotype and phenotype-disease associations.
#' @inheritParams prioritise_targets
#' @inheritParams prioritise_targets_network
#' @inheritParams data.table::merge.data.table
#' @return ggplot object
#'
#' @export
#' @importFrom HPOExplorer load_phenotype_to_genes
#' @examples
#' results <- load_example_results()[seq(2500),]
#' fp_res <- plot_frequency_bar(results=results)
plot_frequency_bar <- function(results = load_example_results(),
                              phenotype_to_genes = HPOExplorer::load_phenotype_to_genes(),
                              allow.cartesian = TRUE,
                              show_plot = FALSE,
                              verbose = TRUE){

  hpo_id <- NULL;

  results <- results |>
    HPOExplorer::add_pheno_frequency(allow.cartesian = allow.cartesian) |>
    HPOExplorer::add_ancestor()
  gene_df <- phenotype_to_genes[hpo_id %in% unique(results$hpo_id),] |>
    HPOExplorer::add_gene_frequency() |>
    HPOExplorer::add_ancestor()

  #### barplot #####
  #### Gene frequencies ####
  gene_plt_df <- plot_frequency_prepare(df = gene_df,
                                        col="gene_freq_name")
  gene_plt <- plot_frequency_bar_i(
    plt_df = gene_plt_df,
    remove_x_text = TRUE,
    title="Gene frequency within phenotypes")
  #### Phenotype frequencies ####
  pheno_plt_df <- plot_frequency_prepare(df = results,
                                         col="pheno_freq_mean")
  pheno_plt <- plot_frequency_bar_i(
    plt_df = pheno_plt_df,
    direction = 1,
    title="Phenotype frequency within diseases")

  pw <- patchwork::wrap_plots(list("Gene frequencies"=gene_plt,
                             "Phenotype frequencies"=pheno_plt),
                        ncol = 1) +
    patchwork::plot_annotation(tag_levels = LETTERS)

  if(isTRUE(show_plot)) methods::show(pw)
  return(list(plot=pw,
              data=list(gene_plot=gene_plt_df,
                        pheno_plot_df=pheno_plt_df)))
}
