## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##
## Retrieve CI artifacts from GitLab/GitHub
##
## Purpose of script: 
##
##
## Author(s): Yong Won Jin
## Date Created: 2026-06-24
## Email: yong.jin@phac-aspc.gc.ca
##
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(httr2)
library(jsonlite)
library(utils)
library(tidyverse)


# GitLab -----------------------------------------------------------------

gitlab_url <- "https://gitlab.cscscience.ca"
gl_token <- Sys.getenv("gl-token")

# Check project number
gl_projects <- request(gitlab_url) |> 
  req_url_path_append("api", "v4", "projects") |> 
  req_headers(
    "PRIVATE-TOKEN" = gl_token,
    "Content-Type" = "application/json"
  ) |> 
  # req_url_query(per_page=10, page=1) |> 
  req_perform() |> 
  resp_body_string() |> 
  fromJSON(flatten=TRUE)

gl_projects |> View()

# 1662 is the project number


# Check project number
gl_jobs <- request(gitlab_url) |> 
  req_url_path_append("api", "v4", "projects", "1662", "jobs") |> 
  req_headers(
    "PRIVATE-TOKEN" = gl_token,
    "Content-Type" = "application/json"
  ) |> 
  # req_url_query(per_page=10, page=1) |> 
  req_perform() |> 
  resp_body_string() |> 
  fromJSON(flatten=TRUE)

gl_jobs |> 
  filter(status == "success") |> 
  group_by(stage, name) |>
  slice_head(n=1) |> 
  select(id, stage, name)

# Use latest job id 52406

artifacts_to_staging <- function(
    job_id,
    token=gl_token,
    gitlab_url="https://gitlab.cscscience.ca", 
    project_id=1662L
    ){
  require(utils)
  require(httr2)
  
  filename <- tempfile(fileext=".zip")
  on.exit(file.remove(filename))
  
  request(gitlab_url) |>
    req_url_path_append("api", "v4", "projects", project_id, "jobs", job_id, "artifacts") |>
    req_headers(
      "PRIVATE-TOKEN" = token
    ) |>
    req_perform() |> 
    resp_body_raw() |> 
    writeBin(filename)
  
  utils::unzip(filename, junkpaths=TRUE, exdir="staging", overwrite = TRUE)
}

# unzip artifacts to staging folder
artifacts_to_staging(52406L)



# GitHub -----------------------------------------------------------------

github_url <- "https://api.github.com"
gh_token <- Sys.getenv("gh-token")

gh_artifacts <- request(github_url) |> 
  req_url_path_append("repos", "ywjin0707", "web_scraping", "actions", "artifacts") |> 
  req_headers(
    "Authorization" = paste("Bearer", gh_token),
    "Accept" = "application/vnd.github+json",
    "X-GitHub-Api-Version" = "2026-03-10"
  ) |> 
  # req_url_query(per_page=10, page=1) |> 
  req_perform() |> 
  resp_body_string() |> 
  fromJSON(flatten=TRUE)

gh_artifacts
