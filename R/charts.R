# Pure ggplot2 chart builder functions — no Shiny imports.

library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)

# Okabe-Ito colour-blind-safe categorical palette
PALETTE <- c(
  "#E69F00", "#56B4E9", "#009E73", "#F0E442",
  "#0072B2", "#D55E00", "#CC79A7", "#334155"
)

theme_fin_health <- function() {
  theme_minimal(base_family = "DM Sans") +
    theme(
      plot.background = element_rect(fill = "transparent", colour = NA),
      panel.background = element_rect(fill = "transparent", colour = NA),
      panel.grid.major = element_line(colour = "#e2e8f0", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      axis.text = element_text(colour = "#475569", size = 10),
      axis.title = element_text(colour = "#0f172a", size = 11),
      axis.text.x = element_text(angle = -45, hjust = 0, vjust = 1),
      plot.title = element_text(
        colour = "#0f172a", size = 12, face = "bold",
        margin = margin(b = 4)
      ),
      legend.text = element_text(colour = "#475569", size = 9),
      legend.title = element_text(colour = "#0f172a", size = 10),
      plot.margin = margin(5, 5, 5, 5)
    )
}

build_sector_bar <- function(data, metric, unit) {
  if (nrow(data) == 0) return(empty_chart())
  avg_by_sector <- data %>%
    group_by(Category) %>%
    summarise(value = mean(.data[[metric]], na.rm = TRUE), .groups = "drop") %>%
    arrange(desc(value))

  if (nrow(avg_by_sector) == 0) return(empty_chart())

  avg_by_sector$Category <- factor(
    avg_by_sector$Category,
    levels = avg_by_sector$Category
  )

  ggplot(avg_by_sector, aes(x = Category, y = value, fill = Category)) +
    geom_col(width = 0.7) +
    scale_fill_manual(values = PALETTE, guide = "none") +
    labs(
      title = paste("Average", metric, "by Sector"),
      x = "Sector",
      y = paste(metric, unit)
    ) +
    theme_fin_health()
}

build_metric_trend <- function(data, metric, unit) {
  if (nrow(data) == 0) return(empty_chart())
  trend <- data %>%
    group_by(Year, Category) %>%
    summarise(value = mean(.data[[metric]], na.rm = TRUE), .groups = "drop")

  if (nrow(trend) == 0) return(empty_chart())

  ggplot(trend, aes(x = factor(Year), y = value, colour = Category, group = Category)) +
    geom_line(linewidth = 0.8) +
    geom_point(size = 2) +
    scale_colour_manual(values = PALETTE) +
    labs(
      title = paste(metric, "Trend by Sector"),
      x = "Year",
      y = paste(metric, unit)
    ) +
    theme_fin_health()
}

build_peer_scatter <- function(data, metric, unit) {
  if (nrow(data) == 0) return(empty_chart())
  ggplot(data, aes(x = Revenue, y = .data[[metric]], colour = Category)) +
    geom_point(size = 3, alpha = 0.7) +
    scale_colour_manual(values = PALETTE) +
    scale_x_continuous(labels = comma) +
    labs(
      title = paste("Revenue vs", metric),
      x = "Revenue ($)",
      y = paste(metric, unit)
    ) +
    theme_fin_health() +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5))
}

build_revenue_over_time <- function(data, company) {
  if (nrow(data) == 0) return(empty_chart())
  melted <- data %>%
    select(Year, Revenue, `Net Income`) %>%
    pivot_longer(cols = c(Revenue, `Net Income`), names_to = "Metric", values_to = "Amount")

  ggplot(melted, aes(x = factor(Year), y = Amount, fill = Metric)) +
    geom_col(position = position_dodge(width = 0.7), width = 0.6) +
    scale_fill_manual(values = c("Revenue" = "#2563eb", "Net Income" = "#009e73")) +
    labs(
      title = paste("Revenue & Net Income \u2014", company),
      x = "Year",
      y = "$ millions"
    ) +
    theme_fin_health()
}

build_ratio_over_time <- function(data, company, metric) {
  if (nrow(data) == 0) return(empty_chart())
  ggplot(data, aes(x = factor(Year), y = .data[[metric]], group = 1)) +
    geom_area(fill = "#2563eb", alpha = 0.08) +
    geom_line(colour = "#2563eb", linewidth = 0.8) +
    geom_point(colour = "#2563eb", size = 2) +
    labs(
      title = paste(metric, "Over Time \u2014", company),
      x = "Year",
      y = metric
    ) +
    theme_fin_health()
}

build_cash_flows <- function(data, company) {
  if (nrow(data) == 0) return(empty_chart())
  cf_cols <- c(
    "Cash Flow from Operating" = "Operating",
    "Cash Flow from Investing" = "Investing",
    "Cash Flow from Financial Activities" = "Financing"
  )
  melted <- data %>%
    select(Year, all_of(names(cf_cols))) %>%
    pivot_longer(cols = -Year, names_to = "Flow Type", values_to = "Amount") %>%
    mutate(`Flow Type` = cf_cols[`Flow Type`])

  melted$`Flow Type` <- factor(
    melted$`Flow Type`,
    levels = c("Operating", "Investing", "Financing")
  )

  ggplot(melted, aes(x = factor(Year), y = Amount, fill = `Flow Type`)) +
    geom_col(position = position_dodge(width = 0.7), width = 0.6) +
    scale_fill_manual(values = c(
      "Operating" = "#2563eb",
      "Investing" = "#c0392b",
      "Financing" = "#f59e0b"
    )) +
    labs(
      title = paste("Cash Flows \u2014", company),
      x = "Year",
      y = "Cash Flow ($ millions)"
    ) +
    theme_fin_health()
}

build_company_comparison_bar <- function(data, metric, unit) {
  if (nrow(data) == 0) return(empty_chart())
  avg_by_company <- data %>%
    group_by(Company) %>%
    summarise(value = mean(.data[[metric]], na.rm = TRUE), .groups = "drop") %>%
    arrange(desc(value))

  avg_by_company$Company <- factor(
    avg_by_company$Company,
    levels = avg_by_company$Company
  )

  ggplot(avg_by_company, aes(x = Company, y = value, fill = Company)) +
    geom_col(width = 0.7) +
    scale_fill_manual(values = PALETTE, guide = "none") +
    labs(
      title = paste(metric, "by Company"),
      x = "Company",
      y = paste(metric, unit)
    ) +
    theme_fin_health()
}

build_single_company_summary <- function(data, metric, unit) {
  if (nrow(data) == 0) return(empty_chart())
  key_metrics <- c("Revenue", "Net Income", "EBITDA", "ROE", "ROA", "Net Profit Margin")
  available <- intersect(key_metrics, colnames(data))
  row <- data[1, ]
  company <- row$Company

  melted <- data.frame(
    Metric = available,
    Value = as.numeric(row[available]),
    stringsAsFactors = FALSE
  )
  melted$Metric <- factor(melted$Metric, levels = rev(available))

  ggplot(melted, aes(x = Value, y = Metric, fill = Metric)) +
    geom_col() +
    scale_fill_manual(values = PALETTE, guide = "none") +
    labs(
      title = paste("Key Metrics \u2014", company),
      x = "Value",
      y = NULL
    ) +
    theme_fin_health() +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5))
}

build_company_trend <- function(data, metric, unit) {
  if (nrow(data) == 0) return(empty_chart())
  trend <- data %>%
    group_by(Year, Company) %>%
    summarise(value = mean(.data[[metric]], na.rm = TRUE), .groups = "drop")

  ggplot(trend, aes(x = factor(Year), y = value, colour = Company, group = Company)) +
    geom_line(linewidth = 0.8) +
    geom_point(size = 2) +
    scale_colour_manual(values = PALETTE) +
    labs(
      title = paste(metric, "Trend by Company"),
      x = "Year",
      y = paste(metric, unit)
    ) +
    theme_fin_health()
}

empty_chart <- function(message = "Data Unavailable") {
  ggplot() +
    annotate("text", x = 0.5, y = 0.5, label = message, size = 6, colour = "#475569") +
    theme_void() +
    xlim(0, 1) + ylim(0, 1)
}
