# Import libraries

from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import os
import pandas as pd
import requests
import csv

# Ensure output directory exists
os.makedirs("data", exist_ok=True)

# Configure headless Chrome for CI environments
chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")
chrome_options.add_argument("--disable-gpu")
chrome_options.add_argument("--window-size=1920,1080")


# Attempt 1: Load dynamic webpage and pull resulting html code

url = "https://health-infobase.canada.ca/respiratory-virus-surveillance/influenza.html"

## Create driver object with headless options
driver = webdriver.Chrome(options=chrome_options)

## Use get method to open url in chrome
driver.get(url)

## Wait 5 sec to allow JS to load
time.sleep(5)

## Get html code after loading JS
html = driver.page_source

## Close browser
driver.quit()

## Create BeautifulSoup object for easy html parsing
soup = BeautifulSoup(html, "lxml")

## Find all tables in html
tables = soup.find_all("table")
print(f"Found {len(tables)} tables")

## Iterate through list of tables
for i, table in enumerate(tables):

    ### Find all table rows (tr) in table
    rows = table.find_all("tr")
    
    ### Initialize dataframe as list
    data = []
    
    ### Iterate through list of table rows
    for row in rows:
        #### Get all columns
        cols = [col.get_text(strip=True) for col in row.find_all(["td", "th"])]
        if cols:  # skip empty rows
            #### Add all columns to data list
            data.append(cols)

    ### Convert list of columns to dataframe object
    df = pd.DataFrame(data)

    ### Create output showing number of rows and table head
    print(f"\nTable {i}")
    print(f"table_{i} has {len(data)} rows")
    for r in data[:5]:  # preview first 5 rows
        print(r)
 
    
## Problem: Not all rows are shown


# Attempt 2: Interact with dynamic webpage to get all table rows

url = "https://health-infobase.canada.ca/respiratory-virus-surveillance/influenza.html"

## Create driver object with headless options
driver = webdriver.Chrome(options=chrome_options)

## Use get method to open url in chrome
driver.get(url)

## Wait 5 sec to allow JS to load
time.sleep(5)

## Find all sections that include tables AND pagination buttons
sections = driver.find_elements(By.TAG_NAME, "details")
print(f"Found {len(sections)} sections")

## Iterate through list of sections
for i, section in enumerate(sections):

    ### Scroll to section
    driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", section)
    time.sleep(1)

    ### Open the section
    driver.execute_script("arguments[0].open = true;", section)
    time.sleep(1)

    ### Initialize dataframe as list
    data = []

    ### Use while loop to stop execution upon errors
    while True:

        #### Find table inside this section
        tables = section.find_elements(By.TAG_NAME, "table")

        #### Exit loop if no table found
        if not tables:
            break

        #### Create table object
        table = tables[0]

        #### Find all table body (tbody) and table row (tr) elements
        rows = table.find_elements(By.CSS_SELECTOR, "tbody tr")

        #### Iterate through list of table rows
        for row in rows:
            ##### Get all columns (td and th elements)
            cols = [c.text for c in row.find_elements(By.TAG_NAME, "td")]
            if cols:  # skip empty rows
                ##### Add all columns to data list
                data.append(cols)

        #### Use try to handle errors
        try:
            ##### Find pagination button
            next_btn = section.find_element(
                By.CSS_SELECTOR,
                "a.paginate_button.next"
            )
            ##### Exit loop if pagination button is disabled
            if "disabled" in next_btn.get_attribute("class"):
                break
            
            ##### Click pagination button
            driver.execute_script("arguments[0].click();", next_btn)
            time.sleep(2)

        except:
            break

    ### Convert list of columns to dataframe object
    df = pd.DataFrame(data)

    ### Export data as csv
    df.to_csv(f"data/table_{i}.csv", index=False)
    print(f"Saved table_{i}.csv with {len(data)} rows")

## Close browser
driver.quit()