# Import libraries
library(tidyverse)
library(rvest) # Basic web scraping with R
library(writexl) # Export excel files

# Ensure output directory exists
dir.create("data", showWarnings = FALSE, recursive = TRUE)

# Scraping static webpages

## Read webpage html
url <- "https://www.worldometers.info/coronavirus/"
page <- read_html(url)

## Scraping tables
tables <- page %>% html_nodes("table") %>% html_table()
table1 <- tables[[1]]

## Save table as CSV for reproducibility
write.csv(table1, "data/covid_data.csv", row.names = FALSE)

## Scraping text
text <- page %>% html_elements("#maincounter-wrap") %>% html_nodes("span") %>% html_text2()

## Scraping many webpages
url <- "https://www.canada.ca/en/public-health/services/diseases/flu-influenza/influenza-surveillance/weekly-influenza-reports.html"
page <- read_html(url)
links <- page %>% html_nodes("a")
link_text <- links %>% html_text2()
link_url <- links %>% html_attr("href")

link_data <- data.frame(link_text, link_url)
link_data <- link_data %>%
  filter(str_detect(link_text, "Weekly report")) %>%
  mutate(
    link_url = paste("https://canada.ca", link_url, sep = "")
  )

for (i in 1:nrow(link_data)) { # Loop 1 start

  url <- link_data$link_url[i]
  text <- link_data$link_text[i]

  print(paste("Navigating to ", text, sep = ""))

  page2 <- read_html(url)
  links2 <- page2 %>% html_nodes("a")
  link_text2 <- links2 %>% html_text()
  link_url2 <- links2 %>% html_attr("href")

  link_data2 <- data.frame(link_text2, link_url2)
  link_data2 <- link_data2 %>%
    filter(str_detect(link_text2, "\\(week")) %>%
    mutate(
      link_url2 = paste("https://canada.ca", link_url2, sep = "")
    )

  for (j in 1:nrow(link_data2)) { # Loop 2 start
    url2 <- link_data2$link_url2[j]
    text2 <- link_data2$link_text2[j]
    print(paste("Navigating to ", text2, sep = ""))

    tables <- read_html(url2) %>% html_nodes("table") %>% html_table()

    # Save first table from each page as CSV
    if (length(tables) > 0) {
      write.csv(tables[[1]], paste0("data/flu_table_", i, "_", j, ".csv"), row.names = FALSE)
    }

    assign(paste("tables", i, j, sep = "_"), tables)

  } # Loop 2 end

} # Loop 1 end



