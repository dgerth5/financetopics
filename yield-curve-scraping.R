library(xml2)

get_yc <- function(year){
  
  if(year < 1990){
    print("Choose Year greater than 1990.")
  } else{
  
  # pull in data, read namespace
  url <- paste0("https://home.treasury.gov/resource-center/data-chart-center/interest-rates/pages/xml?data=daily_treasury_yield_curve&field_tdr_date_value=",year)
  xml_data <- read_xml(url)
  ns <- xml_ns(xml_data)
  
  # get exact data
  dates <- xml_find_all(xml_data, ".//d:NEW_DATE", ns) %>% xml_text()
  bc_1month <- xml_find_all(xml_data, ".//d:BC_1MONTH", ns) %>% xml_text()
  bc_2month <- xml_find_all(xml_data, ".//d:BC_2MONTH", ns) %>% xml_text()
  bc_3month <- xml_find_all(xml_data, ".//d:BC_3MONTH", ns) %>% xml_text()
  bc_4month <- xml_find_all(xml_data, ".//d:BC_4MONTH", ns) %>% xml_text()
  bc_6month <- xml_find_all(xml_data, ".//d:BC_6MONTH", ns) %>% xml_text()
  bc_1year <- xml_find_all(xml_data, ".//d:BC_1YEAR", ns) %>% xml_text()
  bc_2year <- xml_find_all(xml_data, ".//d:BC_2YEAR", ns) %>% xml_text()
  bc_3year <- xml_find_all(xml_data, ".//d:BC_3YEAR", ns) %>% xml_text()
  bc_5year <- xml_find_all(xml_data, ".//d:BC_5YEAR", ns) %>% xml_text()
  bc_7year <- xml_find_all(xml_data, ".//d:BC_7YEAR", ns) %>% xml_text()
  bc_10year <- xml_find_all(xml_data, ".//d:BC_10YEAR", ns) %>% xml_text()
  bc_20year <- xml_find_all(xml_data, ".//d:BC_20YEAR", ns) %>% xml_text()
  bc_30year <- xml_find_all(xml_data, ".//d:BC_30YEAR", ns) %>% xml_text()

  vec_list <- list(bc_1month, bc_2month, bc_3month, bc_4month, bc_6month,
                   bc_1year, bc_2year, bc_3year, bc_5year, bc_7year, bc_10year, bc_20year, bc_30year)
  vec_list <- lapply(vec_list, function(x) if(length(x) == 0) rep(NA, length(dates)) else if (length(x) > 0 & length(x) < length(dates)) c(rep(NA, length(dates) - length(x)), as.numeric(x)) else as.numeric(x))
  names(vec_list) <- c("month1", "month2", "month3", "month4", "month6",
                       "year1", "year2", "year3", "year5", "year7", "year10", "year20", "year30")
  yc_df <- data.frame(Date = dates, vec_list)
  
  return(yc_df)
  }
}
