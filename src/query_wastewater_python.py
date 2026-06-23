# Query PHAC Wastewater GraphQL API - Infobase table
# Public endpoint, no API key required

import requests
import pandas as pd
import os

# Ensure output directory exists
os.makedirs("data", exist_ok=True)

# GraphQL endpoint
ENDPOINT = "https://api-ipa.hc-sc.gc.ca/wastewater/"

# GraphQL query for the Infobase table
QUERY = """
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
"""

def main():
    print("Querying PHAC Wastewater GraphQL API (Infobase table)...")

    response = requests.post(
        ENDPOINT,
        json={"query": QUERY},
        headers={"Content-Type": "application/json"},
        timeout=120
    )
    response.raise_for_status()

    result = response.json()

    if "errors" in result:
        print(f"GraphQL errors: {result['errors']}")
        return

    records = result.get("data", {}).get("Infobase", [])
    print(f"Retrieved {len(records)} records")

    df = pd.DataFrame(records)
    output_path = "data/wastewater_infobase.csv"
    df.to_csv(output_path, index=False)
    print(f"Saved to {output_path}")
    print(df.head())


if __name__ == "__main__":
    main()
