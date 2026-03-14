# Reusable UI helpers: KPI card factory and status icon.

library(shiny)
library(bslib)

kpi_card_ui <- function(ns, header, value_id, trend_id = NULL,
                        label_id = NULL, status_id = NULL) {
  value_children <- list(
    tags$h3(
      textOutput(ns(value_id), inline = TRUE),
      class = "kpi-value",
      style = "display: inline;"
    )
  )
  if (!is.null(status_id)) {
    value_children <- c(value_children, list(
      uiOutput(ns(status_id), style = "display: inline;")
    ))
  }
  if (!is.null(trend_id)) {
    value_children <- c(value_children, list(
      uiOutput(ns(trend_id), style = "display: inline;")
    ))
  }

  label_row <- tags$div(
    if (!is.null(label_id)) uiOutput(ns(label_id)) else tags$span(),
    class = "kpi-label-row"
  )

  card(
    card_header(header),
    tags$div(class = "kpi-value-row", value_children),
    label_row
  )
}

status_icon <- function(value, healthy_threshold, warning_threshold,
                        invert = FALSE) {
  if (is.na(value)) return(tags$span())

  if (invert) {
    # For metrics where lower is better (e.g., Debt/Equity)
    if (value <= healthy_threshold) {
      return(tags$span("\u2713", class = "kpi-status healthy"))
    } else if (value <= warning_threshold) {
      return(tags$span("!", class = "kpi-status warning"))
    } else {
      return(tags$span("\u2717", class = "kpi-status danger"))
    }
  } else {
    # For metrics where higher is better
    if (value >= healthy_threshold) {
      return(tags$span("\u2713", class = "kpi-status healthy"))
    } else if (value >= warning_threshold) {
      return(tags$span("!", class = "kpi-status warning"))
    } else {
      return(tags$span("\u2717", class = "kpi-status danger"))
    }
  }
}
