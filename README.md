# CI/CD Pipeline for Reproducible Web Scraping

Demonstrating two approaches to public health data retrieval — **HTML scraping** vs. **GraphQL API queries** — automated via CI/CD pipelines.

## Repository Structure

```
.
├── .github/workflows/scrape.yml   # GitHub Actions pipeline
├── .gitlab-ci.yml                 # GitLab CI pipeline
├── README.md
├── requirements.txt               # Python dependencies
├── renv.lock                      # R dependencies (renv)
├── renv/activate.R                # renv bootstrap
├── .Rprofile                      # R profile (loads renv)
├── src/
│   ├── Web_scraping_with_Python.py   # Example 1: Selenium/BS4 scraping
│   ├── Web_scraping_with_R.R         # Example 1: rvest scraping
│   ├── query_wastewater_python.py    # Example 2: GraphQL (Python)
│   └── query_wastewater_R.R          # Example 2: GraphQL (R)
├── data/                              # Output CSVs (gitignored)
└── presentation/
    └── slides.qmd                     # Quarto revealjs presentation
```

## Example 1: HTML Scraping

Scrapes dynamic and static HTML tables from public health surveillance websites:

- **Python** (`Web_scraping_with_Python.py`): Uses Selenium + BeautifulSoup to load JavaScript-rendered pages from [Canada's Respiratory Virus Surveillance](https://health-infobase.canada.ca/respiratory-virus-surveillance/influenza.html), interacts with pagination, and exports tables to CSV.
- **R** (`Web_scraping_with_R.R`): Uses `rvest` to scrape static tables from [Worldometers](https://www.worldometers.info/coronavirus/) and Canada's influenza weekly reports.

## Example 2: GraphQL Data Retrieval

Queries the PHAC Wastewater Surveillance GraphQL API — **no API key required**.

- **Endpoint:** `https://api-ipa.hc-sc.gc.ca/wastewater/`
- **Table:** `Infobase` (fields: Date, Location, region, measureid, fractionid, viral_load, seven_day_rolling_avg, pruid)
- **Python** (`query_wastewater_python.py`): Uses `requests` + `pandas`
- **R** (`query_wastewater_R.R`): Uses `httr2` + `jsonlite`

## Reproducing Locally

### Python

```bash
python -m venv .venv
# Windows: .venv\Scripts\activate
# Linux/macOS: source .venv/bin/activate
pip install -r requirements.txt

# Run HTML scraping (requires Chrome installed)
python src/Web_scraping_with_Python.py

# Run GraphQL query
python src/query_wastewater_python.py
```

### R

```r
# Install renv if not present
install.packages("renv")

# Restore project library from lockfile
renv::restore()

# Run HTML scraping
source("src/Web_scraping_with_R.R")

# Run GraphQL query
source("src/query_wastewater_R.R")
```

## CI/CD Pipelines

### GitHub Actions (`.github/workflows/scrape.yml`)

- **Triggers:** Manual (`workflow_dispatch`) + weekly cron schedule (Mondays 06:00 UTC)
- **Jobs:**
  - `python-scrape` — Sets up Python + Chrome/ChromeDriver, runs Selenium script
  - `python-graphql` — Runs GraphQL query with requests/pandas
  - `r-scrape` — Sets up R + renv, runs rvest script
  - `r-graphql` — Sets up R + renv, runs httr2/jsonlite script
- **Artifacts:** Each job uploads `data/` as a downloadable artifact (30-day retention)

### GitLab CI (`.gitlab-ci.yml`)

- **Stages:** `scrape`, `graphql`
- **Images:** `python:3.12` and `r-base:4.4` Docker images
- **Chrome:** Installed in the Python scrape job for Selenium
- **Artifacts:** Output CSVs stored for 30 days

## References

- Original repo: [epiguy5000/web_scraping](https://github.com/epiguy5000/web_scraping)
- PHAC Wastewater API: [PHACDataHub/wastewater-graphql](https://github.com/PHACDataHub/wastewater-graphql)
- [Selenium Python docs](https://selenium-python.readthedocs.io/)
- [rvest documentation](https://rvest.tidyverse.org/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
