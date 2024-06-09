import requests
from bs4 import BeautifulSoup
import pandas as pd
from dateutil import parser

def get_yc(year):
    if year < 1990:
        print("Choose Year greater than 1990.")
        return None

    # pull in data, read namespace
    url = f"https://home.treasury.gov/resource-center/data-chart-center/interest-rates/pages/xml?data=daily_treasury_yield_curve&field_tdr_date_value={year}"
    response = requests.get(url)
    xml_data = BeautifulSoup(response.content, 'xml')

    all_data = []  # list to hold all the row data

    #  get each bond yield, insert 'n/a' if not found
    entries = xml_data.find_all('entry')
    for entry in entries:
        date = entry.find('d:NEW_DATE').text[:10]  
        data = {'Date': date}

        for tag in ['BC_1MONTH', 'BC_2MONTH', 'BC_3MONTH', 'BC_4MONTH', 'BC_6MONTH', 'BC_1YEAR', 'BC_2YEAR', 'BC_3YEAR', 'BC_5YEAR', 'BC_7YEAR', 'BC_10YEAR', 'BC_20YEAR', 'BC_30YEAR']:
            result = entry.find(tag)
            data[tag] = result.text if result else pd.NA

        all_data.append(data)

    # convert to DataFrame
    yc_df = pd.DataFrame(all_data)
    return yc_df
    

def hist_tsy_yield(start_date, end_date):

  # confirm that start_date and end_date are dates
  try:
    parser.parse(start_date)
    pass
  except ValueError:
    return "Provide Valid Date"

  try:
    parser.parse(end_date)
    pass
  except ValueError:
    return "Provide Valid Date"

  # check that start_date is before end_date

  if parser.parse(start_date) > parser.parse(end_date):
    return "Start date needs to be older than end date"

  # get years

  start_year = parser.parse(start_date).year
  end_year = parser.parse(end_date).year

  years = list(range(start_year, end_year+1))

  year_df = pd.DataFrame()

  for i in years:
      df = get_yc(i)
      year_df = pd.concat([year_df, df], ignore_index=True)

  # filter data to between selected dates
  fmt_start_date = parser.parse(start_date).strftime("%Y-%m-%d")
  fmt_end_date = parser.parse(end_date).strftime("%Y-%m-%d")

  filter_df = year_df[(year_df['Date'] >= fmt_start_date) & (year_df['Date'] <= fmt_end_date)]

  # convert the rest of the columns to numeric, coerce errors to NaN
  for column in filter_df.columns[1:]:
      filter_df[column] = pd.to_numeric(filter_df[column], errors='coerce')

  return filter_df.reset_index(drop=True)


# Example usage
print(hist_tsy_yield("2024-01-01", "2024-04-01").head(20))

