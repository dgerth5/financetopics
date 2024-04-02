import requests
from bs4 import BeautifulSoup
import pandas as pd

def get_yc(year):
    if year < 1990:
        print("Choose Year greater than 1990.")
        return None

    url = f"https://home.treasury.gov/resource-center/data-chart-center/interest-rates/pages/xml?data=daily_treasury_yield_curve&field_tdr_date_value={year}"
    response = requests.get(url)
    xml_data = BeautifulSoup(response.content, 'xml')

    # Iterate through each entry
    entries = xml_data.find_all('entry')
    for entry in entries:
        date = entry.find('d:NEW_DATE').text[:10]  # Extract date, trimming time part if present
        data = {'Date': date}
        for tag in ['BC_1MONTH', 'BC_2MONTH', 'BC_3MONTH', 'BC_4MONTH', 'BC_6MONTH', 'BC_1YEAR', 'BC_2YEAR', 'BC_3YEAR', 'BC_5YEAR', 'BC_7YEAR', 'BC_10YEAR', 'BC_20YEAR', 'BC_30YEAR']:
            result = entry.find(tag)
            data[tag] = result.text if result else pd.NA
        
        all_data.append(data)

    yc_df = pd.DataFrame(all_data)

    yc_df.set_index('Date', inplace=True)

    return yc_df
