# Query PHAC Wastewater GraphQL API - Infobase table
# Public endpoint, no API key required

library(httr2)
library(jsonlite)

# Ensure output directory exists
dir.create("data", showWarnings = FALSE, recursive = TRUE)

# GraphQL endpoint
endpoint <- "https://api-ipa.hc-sc.gc.ca/wastewater/"

# GraphQL query for the Infobase table
query <- '
{
  Infobase {
    Date
    Location
    region
    measureid
    fractionid
    viral_load
    seven_day_rolling_avg
    pruid
  }
}
'

cat("Querying PHAC Wastewater GraphQL API (Infobase table)...\n")

# Build and send the request
resp <- request(endpoint) |>

req_headers("Content-Type" = "application/json") |>
  req_body_json(list(query = query)) |>
  req_timeout(120) |>
  req_perform()

# Parse response
body <- resp_body_string(resp)
result <- fromJSON(body, flatten = TRUE)

if (!is.null(result$errors)) {
  cat("GraphQL errors:\n")
  print(result$errors)
  stop("Query returned errors")
}

records <- result$data$Infobase
cat(paste("Retrieved", nrow(records), "records\n"))

# Export to CSV
output_path <- "data/wastewater_infobase_r.csv"
write.csv(records, output_path, row.names = FALSE)
cat(paste("Saved to", output_path, "\n"))
print(head(records))
