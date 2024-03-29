test_that("gen_results works", {

  set.seed(2023)
  gene_data <- HPOExplorer::load_phenotype_to_genes()
  ctd <- load_example_ctd()
  list_names <- unique(gene_data$hpo_id)[seq(3)]
  all_results <- gen_results(ctd = ctd,
                             gene_data = gene_data,
                             list_names = list_names,
                             reps = 10)
  testthat::expect_true(methods::is(all_results$results,"data.table"))
  testthat::expect_true(methods::is(all_results$gene_data,"data.table"))
  testthat::expect_gte(sum(list_names %in% unique(all_results$results$hpo_id)),
                       length(list_names)-2)
  testthat::expect_gte(nrow(all_results$results[q<=0.05,]),8)
})
