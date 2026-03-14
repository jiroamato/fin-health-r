# Page 2: Company Financial Health — Shiny module (UI + server).

library(shiny)
library(bslib)
library(plotly)

company_ui <- function(id) {
  ns <- NS(id)

  sidebar_content <- sidebar(
    h4("Analytics Filters"),
    selectInput(
      ns("category"), "Industry",
      choices = ALL_SECTORS,
      selected = ALL_SECTORS[1]
    ),
    selectInput(ns("company"), "Company", choices = NULL),
    uiOutput(ns("year_slider")),
    open = "desktop"
  )

  # Profitability cards
  card_npm <- card(
    card_header("Net Profit Margin"),
    div(
      tags$h3(
        textOutput(ns("npm"), inline = TRUE),
        class = "kpi-value", style = "display: inline;"
      ),
      uiOutput(ns("npm_status"), style = "display: inline;"),
      class = "kpi-value-row"
    ),
    plotlyOutput(ns("npm_chart")),
    full_screen = TRUE
  )
  card_roe <- card(
    card_header("Return on Equity (ROE)"),
    div(
      tags$h3(
        textOutput(ns("roe"), inline = TRUE),
        class = "kpi-value", style = "display: inline;"
      ),
      uiOutput(ns("roe_status"), style = "display: inline;"),
      class = "kpi-value-row"
    ),
    plotlyOutput(ns("roe_chart")),
    full_screen = TRUE
  )
  card_rev_income <- card(
    card_header("Revenue & Net Income"),
    uiOutput(ns("rev_income_summary")),
    plotlyOutput(ns("revenue_chart")),
    full_screen = TRUE
  )
  profitability_section <- div(
    div("PROFITABILITY", class = "section-label section-label-blue"),
    layout_columns(
      card_npm, card_roe, card_rev_income,
      col_widths = c(4, 4, 4)
    ),
    class = "grid-section grid-section-blue"
  )

  # Financial Health cards
  card_current_ratio <- card(
    card_header("Current Ratio"),
    div(
      tags$h3(
        textOutput(ns("current_ratio"), inline = TRUE),
        class = "kpi-value", style = "display: inline;"
      ),
      uiOutput(ns("current_ratio_status"), style = "display: inline;"),
      class = "kpi-value-row"
    ),
    plotlyOutput(ns("current_ratio_chart")),
    full_screen = TRUE
  )
  card_debt_equity <- card(
    card_header("Debt / Equity Ratio"),
    div(
      tags$h3(
        textOutput(ns("debt_equity"), inline = TRUE),
        class = "kpi-value", style = "display: inline;"
      ),
      uiOutput(ns("debt_equity_status"), style = "display: inline;"),
      class = "kpi-value-row"
    ),
    plotlyOutput(ns("debt_equity_chart")),
    full_screen = TRUE
  )
  card_cash_flows <- card(
    card_header("Cash Flows"),
    uiOutput(ns("cash_flows")),
    plotlyOutput(ns("cash_flow_chart")),
    full_screen = TRUE
  )
  health_section <- div(
    div("FINANCIAL HEALTH", class = "section-label section-label-red"),
    layout_columns(
      card_current_ratio, card_debt_equity, card_cash_flows,
      col_widths = c(4, 4, 4)
    ),
    class = "grid-section grid-section-red"
  )

  layout_sidebar(
    sidebar = sidebar_content,
    h2("Financial Health Dashboard"),
    profitability_section,
    health_section
  )
}

company_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Update company choices when category changes
    observeEvent(input$category, {
      companies <- CATEGORY_COMPANIES[[input$category]]
      if (is.null(companies)) companies <- character(0)
      selected <- if (length(companies) > 0) companies[1] else NULL
      updateSelectInput(session, "company", choices = companies, selected = selected)
    })

    # Dynamic year slider
    output$year_slider <- renderUI({
      company <- input$company
      req(company)
      company_data <- df %>% filter(Company == company)
      if (nrow(company_data) == 0) {
        yr_min <- min(df$Year)
        yr_max <- max(df$Year)
      } else {
        yr_min <- min(company_data$Year)
        yr_max <- max(company_data$Year)
      }
      if (yr_min == yr_max) {
        div(
          tags$label("Year", class = "control-label"),
          tags$p(as.character(yr_max), style = "font-weight: 600; font-size: 1.1rem;")
        )
      } else {
        sliderInput(ns("year"), "Year",
          min = yr_min, max = yr_max,
          value = yr_max, sep = ""
        )
      }
    })

    # Filtered data (single company, single year)
    filtered_data <- reactive({
      req(input$category, input$company, input$year)
      df %>%
        filter(
          Category == input$category,
          Company == input$company,
          Year == input$year
        )
    })

    # Full company data (all years, for trend charts)
    company_data <- reactive({
      req(input$company)
      df %>% filter(Company == input$company)
    })

    # --- Profitability KPIs ---
    output$npm <- renderText({
      fd <- filtered_data()
      if (nrow(fd) == 0) return("N/A")
      sprintf("%.1f%%", fd$`Net Profit Margin`[1])
    })

    output$roe <- renderText({
      fd <- filtered_data()
      if (nrow(fd) == 0) return("N/A")
      sprintf("%.2f%%", fd$ROE[1])
    })

    output$npm_status <- renderUI({
      fd <- filtered_data()
      if (nrow(fd) == 0) return(tags$span())
      status_icon(fd$`Net Profit Margin`[1], 10, 0)
    })

    output$roe_status <- renderUI({
      fd <- filtered_data()
      if (nrow(fd) == 0) return(tags$span())
      status_icon(fd$ROE[1], 15, 0)
    })

    output$npm_chart <- renderPlotly({
      cd <- company_data()
      if (nrow(cd) == 0) return(ggplotly(empty_chart()))
      ggplotly(
        build_ratio_over_time(cd, input$company, "Net Profit Margin"),
        tooltip = "text"
      ) %>%
        config(displayModeBar = FALSE) %>%
        layout(xaxis = list(fixedrange = TRUE), yaxis = list(fixedrange = TRUE))
    })

    output$roe_chart <- renderPlotly({
      cd <- company_data()
      if (nrow(cd) == 0) return(ggplotly(empty_chart()))
      ggplotly(
        build_ratio_over_time(cd, input$company, "ROE"),
        tooltip = "text"
      ) %>%
        config(displayModeBar = FALSE) %>%
        layout(xaxis = list(fixedrange = TRUE), yaxis = list(fixedrange = TRUE))
    })

    output$rev_income_summary <- renderUI({
      fd <- filtered_data()
      if (nrow(fd) == 0) return(div("N/A"))
      rev <- fd$Revenue[1]
      ni <- fd$`Net Income`[1]
      div(
        span(sprintf("Revenue: $%sM", formatC(rev, format = "f", big.mark = ",", digits = 0)),
          class = "kpi-label"
        ),
        span(" | ", style = "color: var(--slate-400);"),
        span(sprintf("Net Income: $%sM", formatC(ni, format = "f", big.mark = ",", digits = 0)),
          class = "kpi-label"
        ),
        style = "padding: 0.25rem 0; text-align: center;"
      )
    })

    output$revenue_chart <- renderPlotly({
      cd <- company_data()
      if (nrow(cd) == 0) return(ggplotly(empty_chart()))
      ggplotly(
        build_revenue_over_time(cd, input$company),
        tooltip = "text"
      ) %>%
        config(displayModeBar = FALSE) %>%
        layout(xaxis = list(fixedrange = TRUE), yaxis = list(fixedrange = TRUE))
    })

    # --- Financial Health KPIs ---
    output$current_ratio <- renderText({
      fd <- filtered_data()
      if (nrow(fd) == 0) return("N/A")
      sprintf("%.2f", fd$`Current Ratio`[1])
    })

    output$current_ratio_status <- renderUI({
      fd <- filtered_data()
      if (nrow(fd) == 0) return(tags$span())
      status_icon(fd$`Current Ratio`[1], 1.5, 1.0)
    })

    output$current_ratio_chart <- renderPlotly({
      cd <- company_data()
      if (nrow(cd) == 0) return(ggplotly(empty_chart()))
      ggplotly(
        build_ratio_over_time(cd, input$company, "Current Ratio"),
        tooltip = "text"
      ) %>%
        config(displayModeBar = FALSE) %>%
        layout(xaxis = list(fixedrange = TRUE), yaxis = list(fixedrange = TRUE))
    })

    output$debt_equity <- renderText({
      fd <- filtered_data()
      if (nrow(fd) == 0) return("N/A")
      sprintf("%.2f", fd$`Debt/Equity Ratio`[1])
    })

    output$debt_equity_status <- renderUI({
      fd <- filtered_data()
      if (nrow(fd) == 0) return(tags$span())
      status_icon(fd$`Debt/Equity Ratio`[1], 1.0, 2.0, invert = TRUE)
    })

    output$debt_equity_chart <- renderPlotly({
      cd <- company_data()
      if (nrow(cd) == 0) return(ggplotly(empty_chart()))
      ggplotly(
        build_ratio_over_time(cd, input$company, "Debt/Equity Ratio"),
        tooltip = "text"
      ) %>%
        config(displayModeBar = FALSE) %>%
        layout(xaxis = list(fixedrange = TRUE), yaxis = list(fixedrange = TRUE))
    })

    output$cash_flows <- renderUI({
      fd <- filtered_data()
      if (nrow(fd) == 0) return(div("N/A"))
      row <- fd[1, ]
      op <- row$`Cash Flow from Operating`
      inv <- row$`Cash Flow from Investing`
      fin <- row$`Cash Flow from Financial Activities`
      fmt <- function(v) {
        if (v < 0) paste0("-$", formatC(abs(v), format = "f", big.mark = ",", digits = 0), "M")
        else paste0("$", formatC(v, format = "f", big.mark = ",", digits = 0), "M")
      }
      div(
        span(paste("Operating:", fmt(op)), class = "kpi-label"), br(),
        span(paste("Investing:", fmt(inv)), class = "kpi-label"), br(),
        span(paste("Financing:", fmt(fin)), class = "kpi-label"),
        style = "text-align: center;"
      )
    })

    output$cash_flow_chart <- renderPlotly({
      cd <- company_data()
      if (nrow(cd) == 0) return(ggplotly(empty_chart()))
      ggplotly(
        build_cash_flows(cd, input$company),
        tooltip = "text"
      ) %>%
        config(displayModeBar = FALSE) %>%
        layout(xaxis = list(fixedrange = TRUE), yaxis = list(fixedrange = TRUE))
    })
  })
}
