
local({
  # Activate renv
  renv_version <- "1.0.7"
  renv_lib <- file.path(Sys.getenv("RENV_PATHS_LIBRARY_ROOT", unset = "renv/library"),
                        R.version$platform, paste(R.version$major, R.version$minor, sep = "."))

  if (!requireNamespace("renv", quietly = TRUE)) {
    install.packages("renv", repos = "https://cloud.r-project.org")
  }

  renv::activate()
})
