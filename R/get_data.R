#' Get remote data
#'
#' Download remotely stored data via \link[piggyback]{pb_download}.
#' @keywords internal
#' @inheritParams piggyback::pb_download
#' @importFrom tools R_user_dir
get_data <- function(fname,
                     repo = "neurogenomics/MAGMA_Celltyping",
                     storage_dir = tools::R_user_dir(
                       package = "MAGMA.Celltyping",
                       which = "cache"
                     ),
                     overwrite = TRUE,
                     check = FALSE
                     ){
  tmp <- file.path(storage_dir, fname)
  requireNamespace("piggyback")
  requireNamespace("gh")
  Sys.setenv("piggyback_cache_duration" = 10)
  dir.create(storage_dir, showWarnings = FALSE, recursive = TRUE)
  piggyback::pb_download(
    file = fname,
    dest = storage_dir,
    repo = repo,
    overwrite = overwrite
  )
  #### Read/return ####
  if(grepl("\\.rds$",tmp)){
    return(readRDS(tmp))
  } else{
    return(tmp)
  }
}

