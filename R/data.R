# Data loading, cleaning, and shared constants for the fin-health dashboard.

library(readr)
library(dplyr)

DATA_PATH <- file.path("data", "raw", "financial_statement.csv")

load_data <- function(path = DATA_PATH) {
  if (!file.exists(path)) {
    stop(paste("Dataset not found:", path))
  }
  data <- read_csv(path, show_col_types = FALSE)
  colnames(data) <- trimws(colnames(data))
  data <- data %>% mutate(Category = toupper(Category))
  data
}

df <- load_data()

CATEGORY_COMPANIES <- list(
  BANK = c("AIG", "BCS"),
  ELEC = c("INTC", "NVDA"),
  FINANCE = c("SHLDQ"),
  FINTECH = c("PYPL"),
  FOOD = c("MCD"),
  IT = c("AAPL", "GOOG", "MSFT"),
  LOGI = c("AMZN"),
  MANUFACTURING = c("PCG")
)

ALL_SECTORS <- sort(names(CATEGORY_COMPANIES))

METRIC_CHOICES <- c(
  "Net Profit Margin" = "%",
  "ROE" = "%",
  "ROA" = "%",
  "ROI" = "%",
  "Revenue" = "USD",
  "Net Income" = "USD",
  "EBITDA" = "USD",
  "Current Ratio" = "",
  "Debt/Equity Ratio" = ""
)
