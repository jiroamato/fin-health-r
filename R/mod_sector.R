# Page 1: Sector Analysis — Shiny module (UI + server).

library(shiny)
library(bslib)
library(plotly)
library(DT)

sector_ui <- function(id) {
  ns <- NS(id)

  # Sidebar inputs
  sidebar_content <- sidebar(
    h4("Analytics Filters"),
    sliderInput(
      ns("year_range"), "Period",
      min = min(df$Year), max = max(df$Year),
      value = c(min(df$Year), max(df$Year)),
      sep = ""
    ),
    selectizeInput(
      ns("sector"), "Sector",
      choices = ALL_SECTORS,
      selected = NULL,
      multiple = TRUE,
      options = list(
        plugins = list("remove_button"),
        placeholder = "All sectors"
      )
    ),
    selectizeInput(
      ns("metric"), "Metric",
      choices = names(METRIC_CHOICES),
      selected = "Net Profit Margin"
    ),
    actionButton(ns("reset"), "Reset Filters"),
    open = "desktop"
  )

  # KPI cards
  card_avg_margin <- kpi_card_ui(
    ns, "Avg Profit Margin",
    value_id = "avg_margin",
    trend_id = "margin_trend",
    label_id = "margin_badge"
  )
  card_top_sector <- kpi_card_ui(
    ns, "Top Sector",
    value_id = "top_sector",
    label_id = "index_performance"
  )
  card_revenue_growth <- kpi_card_ui(
    ns, "Revenue Growth",
    value_id = "revenue_growth_value",
    trend_id = "revenue_trend",
    label_id = "revenue_growth_label"
  )
  kpi_row <- div(
    layout_columns(
      card_avg_margin, card_top_sector, card_revenue_growth,
      col_widths = c(4, 4, 4)
    ),
    class = "kpi-card-row"
  )

  # Chart cards
  chart_row <- layout_columns(
    card(
      card_header("Sector Comparison"),
      plotlyOutput(ns("chart_a")),
      full_screen = TRUE
    ),
    card(
      card_header("Historical Trend"),
      plotlyOutput(ns("chart_b")),
      full_screen = TRUE
    ),
    col_widths = c(6, 6)
  )

  # Peer + Table
  peer_row <- layout_columns(
    card(
      card_header("Peer Benchmarking"),
      plotlyOutput(ns("chart_c")),
      full_screen = TRUE
    ),
    card(
      card_header("Company Details"),
      DTOutput(ns("table_d"))
    ),
    col_widths = c(6, 6)
  )

  layout_sidebar(
    sidebar = sidebar_content,
    h2("US Corporate Profitability Analytics"),
    kpi_row,
    chart_row,
    peer_row
  )
}

sector_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Selected metric with fallback
    selected_metric <- reactive({
      m <- input$metric
      if (is.null(m) || !(m %in% names(METRIC_CHOICES))) {
        return("Net Profit Margin")
      }
      m
    })

    # Reset filters
    observeEvent(input$reset, {
      updateSliderInput(session, "year_range",
        value = c(min(df$Year), max(df$Year))
      )
      updateSelectizeInput(session, "sector", selected = character(0))
      updateSelectizeInput(session, "metric", selected = "Net Profit Margin")
    })

    # Filtered data
    filtered_data <- reactive({
      yr <- input$year_range
      sectors <- input$sector
      filtered <- df %>%
        filter(Year >= yr[1], Year <= yr[2])
      if (length(sectors) > 0) {
        filtered <- filtered %>% filter(Category %in% sectors)
      }
      filtered
    })

    # --- KPI: Avg Profit Margin ---
    output$avg_margin <- renderText({
      fd <- filtered_data()
      if (nrow(fd) == 0) return("Data Unavailable")
      avg <- mean(fd$`Net Profit Margin`, na.rm = TRUE)
      sprintf("%.1f%%", avg)
    })

    output$margin_trend <- renderUI({
      fd <- filtered_data()
      if (nrow(fd) == 0) return(tags$span())
      years <- sort(unique(fd$Year))
      if (length(years) < 2) return(tags$span())
      current <- mean(fd$`Net Profit Margin`[fd$Year == tail(years, 1)], na.rm = TRUE)
      previous <- mean(fd$`Net Profit Margin`[fd$Year == years[length(years) - 1]], na.rm = TRUE)
      if (is.na(current) || is.na(previous)) return(tags$span())
      is_positive <- current >= previous
      trend_char <- if (is_positive) "\u25b2" else "\u25bc"
      trend_class <- if (is_positive) "up" else "down"
      tags$span(trend_char, class = paste("trend-indicator", trend_class))
    })

    output$margin_badge <- renderUI({
      fd <- filtered_data()
      if (nrow(fd) == 0) return(tags$span())
      n <- length(unique(fd$Company))
      tags$p(
        paste("BASED ON", n, "COMPANIES"),
        class = "kpi-label",
        style = "margin-top: 0.5rem;"
      )
    })

    # --- KPI: Top Sector ---
    output$top_sector <- renderText({
      fd <- filtered_data()
      if (nrow(fd) == 0) return("Data Unavailable")
      top <- fd %>%
        group_by(Category) %>%
        summarise(avg = mean(`Net Profit Margin`, na.rm = TRUE), .groups = "drop") %>%
        slice_max(avg, n = 1)
      top$Category[1]
    })

    index_margin <- reactive({
      fd <- filtered_data()
      if (nrow(fd) == 0) return(0)
      total_revenue <- sum(fd$Revenue, na.rm = TRUE)
      total_net_income <- sum(fd$`Net Income`, na.rm = TRUE)
      if (total_revenue == 0) return(0)
      (total_net_income / total_revenue) * 100
    })

    output$index_performance <- renderUI({
      margin <- index_margin()
      tags$p(
        "INDEX PERFORMANCE: ",
        tags$strong(sprintf("%.1f%%", margin)),
        " NET PROFIT MARGIN",
        class = "kpi-label"
      )
    })

    # --- KPI: Revenue Growth ---
    revenue_change <- reactive({
      fd <- filtered_data()
      yearly_rev <- fd %>%
        group_by(Year) %>%
        summarise(total = sum(Revenue, na.rm = TRUE), .groups = "drop") %>%
        arrange(desc(Year))
      if (nrow(yearly_rev) < 2) return(NULL)
      current <- yearly_rev$total[1]
      previous <- yearly_rev$total[2]
      if (is.na(current) || is.na(previous) || previous == 0) return(NULL)
      growth <- (current - previous) / previous * 100
      list(value = growth, is_positive = growth >= 0)
    })

    output$revenue_growth_value <- renderText({
      change <- revenue_change()
      if (is.null(change)) return("Data Unavailable")
      sign <- if (change$is_positive) "+" else ""
      sprintf("%s%.1f%%", sign, change$value)
    })

    output$revenue_growth_label <- renderUI({
      tags$p("YEAR OVER YEAR", class = "kpi-label", style = "margin-top: 0.5rem;")
    })

    output$revenue_trend <- renderUI({
      change <- revenue_change()
      if (is.null(change)) return(tags$span())
      trend_char <- if (change$is_positive) "\u25b2" else "\u25bc"
      trend_class <- if (change$is_positive) "up" else "down"
      tags$span(trend_char, class = paste("trend-indicator", trend_class))
    })

    # --- Charts ---
    output$chart_a <- renderPlotly({
      fd <- filtered_data()
      metric <- selected_metric()
      unit <- METRIC_CHOICES[metric]
      ggplotly(build_sector_bar(fd, metric, unit), tooltip = "text") %>%
        config(displayModeBar = FALSE) %>%
        layout(
          xaxis = list(fixedrange = TRUE),
          yaxis = list(fixedrange = TRUE)
        )
    })

    output$chart_b <- renderPlotly({
      fd <- filtered_data()
      metric <- selected_metric()
      unit <- METRIC_CHOICES[metric]
      ggplotly(build_metric_trend(fd, metric, unit)) %>%
        config(displayModeBar = FALSE) %>%
        layout(
          xaxis = list(fixedrange = TRUE),
          yaxis = list(fixedrange = TRUE)
        )
    })

    output$chart_c <- renderPlotly({
      fd <- filtered_data()
      metric <- selected_metric()
      unit <- METRIC_CHOICES[metric]
      ggplotly(build_peer_scatter(fd, metric, unit)) %>%
        config(displayModeBar = FALSE) %>%
        layout(
          xaxis = list(fixedrange = TRUE),
          yaxis = list(fixedrange = TRUE)
        )
    })

    # --- Table ---
    output$table_d <- renderDT({
      fd <- filtered_data()
      cols <- c("Company", "Category", "Year", "Revenue", "Net Income", "Net Profit Margin")
      datatable(
        fd[, cols],
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    })
  })
}
