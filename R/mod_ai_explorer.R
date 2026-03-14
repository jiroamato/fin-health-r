# Page 3: fin-chat — natural-language data filtering with querychat (R).

library(shiny)
library(bslib)
library(plotly)
library(DT)
library(RSQLite)

DEFAULT_METRIC <- "Net Profit Margin"

# Keyword -> metric mapping for inferring metric from querychat title/SQL.
METRIC_KEYWORDS <- c(
  "net profit margin" = "Net Profit Margin",
  "profit margin" = "Net Profit Margin",
  "roe" = "ROE",
  "return on equity" = "ROE",
  "roa" = "ROA",
  "return on assets" = "ROA",
  "roi" = "ROI",
  "return on investment" = "ROI",
  "revenue" = "Revenue",
  "net income" = "Net Income",
  "ebitda" = "EBITDA",
  "current ratio" = "Current Ratio",
  "debt/equity" = "Debt/Equity Ratio",
  "debt equity" = "Debt/Equity Ratio",
  "debt to equity" = "Debt/Equity Ratio"
)

infer_metric <- function(title) {
  if (is.null(title) || title == "") return(DEFAULT_METRIC)
  lower <- tolower(title)
  for (keyword in names(METRIC_KEYWORDS)) {
    if (grepl(keyword, lower, fixed = TRUE)) {
      return(METRIC_KEYWORDS[[keyword]])
    }
  }
  DEFAULT_METRIC
}

DATA_DESCRIPTION <- "
US Corporate financial statement data (2009-2023), covering 12 publicly
traded companies across 8 sectors.

Company-sector mapping:
- BANK: AIG, BCS
- ELEC: INTC, NVDA
- FINANCE: SHLDQ
- FINTECH: PYPL
- FOOD: MCD
- IT: AAPL, GOOG, MSFT
- LOGI: AMZN
- MANUFACTURING: PCG

Column descriptions (with approximate value ranges):
- Year: fiscal year (2009-2023)
- Company: ticker symbol (AAPL, GOOG, MSFT, AMZN, INTC, NVDA, PYPL, MCD, AIG, BCS, SHLDQ, PCG)
- Category: sector (BANK, ELEC, FINANCE, FINTECH, FOOD, IT, LOGI, MANUFACTURING)
- Market Cap(in B USD): market capitalization in billions (~$1B-$3,000B)
- Revenue: annual revenue in millions USD (~$500M-$400,000M)
- Gross Profit: gross profit in millions USD (~$100M-$170,000M)
- Net Income: net income in millions USD (~-$25,000M-$100,000M)
- Earning Per Share: earnings per share in USD (~-$30-$6)
- EBITDA: earnings before interest, taxes, depreciation, amortization in millions USD (~-$5,000M-$130,000M)
- Share Holder Equity: total shareholder equity in millions USD (~-$15,000M-$270,000M)
- Cash Flow from Operating: operating cash flow in millions USD (~-$5,000M-$120,000M)
- Cash Flow from Investing: investing cash flow in millions USD (~-$50,000M-$30,000M)
- Cash Flow from Financial Activities: financing cash flow in millions USD (~-$120,000M-$30,000M)
- Current Ratio: current assets / current liabilities; >1 = healthy liquidity (~0.5-4.0)
- Debt/Equity Ratio: total debt / shareholder equity (~-10-30)
- ROE: return on equity in percent (~-80%-+160%)
- ROA: return on assets in percent (~-15%-+30%)
- ROI: return on investment in percent (~-20%-+50%)
- Net Profit Margin: net income / revenue in percent (~-50%-+35%)
- Free Cash Flow per Share: free cash flow per share in USD (~-$5-$7)
- Return on Tangible Equity: return on tangible equity in percent (~-200%-+200%)
- Number of Employees: headcount (~10,000-1,600,000)
- Inflation Rate(in US): US inflation rate for that year in percent (~0.1%-8%)
"

GREETING <- '
Hi! I can help you explore the financial dataset. Try one of these:

**Filter:** <span class="suggestion">Show tech companies with net profit margin above 20%</span>

**Compare:** <span class="suggestion">Rank all companies by ROE in 2022</span>

**Aggregate:** <span class="suggestion">What is the average revenue by sector?</span>

**Health check:** <span class="suggestion">Which companies have a current ratio below 1?</span>
'

EXTRA_INSTRUCTIONS <- '
You are a financial data analyst assistant. Follow these rules strictly:

1. **Tool selection rules - read carefully:**
   - Use `querychat_query` for any question needing aggregation (GROUP BY, AVG,
     SUM, COUNT, ranking, TOP N, etc.) or when reporting statistics.
   - Use `querychat_update_dashboard` ONLY for filtering the dashboard.
   - **CRITICAL: `querychat_update_dashboard` queries MUST always start with
     `SELECT * FROM financial_data WHERE ...`.**  Never select specific columns.
     Never use GROUP BY, CTEs, JOINs, or subqueries. The query must return
     every column in the table or it will fail.
   - Never guess or hallucinate numbers. If you cannot answer from the data,
     say so.

2. **Always quote column names** that contain spaces, slashes, or parentheses
   with double quotes in SQL. For example: "Current Ratio", "Debt/Equity Ratio",
   "Market Cap(in B USD)", "Cash Flow from Operating", "Earning Per Share",
   "Cash Flow from Investing", "Cash Flow from Financial Activities",
   "Inflation Rate(in US)", "Share Holder Equity", "Net Profit Margin",
   "Free Cash Flow per Share", "Return on Tangible Equity",
   "Number of Employees", "Gross Profit", "Net Income".

3. **Response format - choose ONE based on the question type:**

   **TYPE A - Data queries** (user says "show", "filter", "rank", "list",
   "compare", "top N", "which companies have..."):
   Use the four-bullet markdown format, each on its own line:
   - **Filters applied:** ...
   - **Key stats:** ...
   - **Insight:** ...
   - **Try next:** `<span class="suggestion">...</span>`

   **TYPE B - Explanation / interpretation questions** (user asks "what does X
   mean?", "is Y concerning?", "explain", "what is a healthy range?",
   "why does Z have..."):
   Do NOT use the bullet format. Write natural prose paragraphs instead.
   Cite definitions, formulas, healthy ranges, and industry-specific benchmarks
   from the domain context. Compare values against the relevant sector average
   and explain *why* different industries have different norms. End with one
   clickable suggestion: `<span class="suggestion">...</span>`

   **TYPE C - Mixed** (data + explanation in one question):
   Answer ALL parts. Use bullets for the data part and separate prose
   paragraphs for the explanation part.

4. When the user asks about a sector, use the Category column (e.g., IT, BANK).
   When they mention a company name, map it to the ticker in the Company column.

5. Keep responses concise - no more than 5 sentences per section.

6. **Never include raw HTML, SQL code blocks, or `<button>` markup in your
   response text.** Do not echo the SQL query or the button element back to the
   user. Just call the appropriate tool and provide the structured summary.
'

has_token <- function() {
  nzchar(Sys.getenv("GITHUB_TOKEN", ""))
}

# Create QueryChat R6 instance at source time (like Python version)
qc_instance <- NULL
get_qc <- function() {
  if (is.null(qc_instance)) {
    qc_instance <<- querychat::QueryChat$new(
      df,
      table_name = "financial_data",
      data_description = DATA_DESCRIPTION,
      extra_instructions = EXTRA_INSTRUCTIONS,
      greeting = GREETING,
      client = ellmer::chat_github(model = "gpt-4.1-mini")
    )
  }
  qc_instance
}

ai_explorer_ui <- function() {
  if (!has_token()) {
    return(
      div(
        h2("fin-chat"),
        card(
          card_header("Configuration Required"),
          p("Set the GITHUB_TOKEN environment variable to enable fin-chat.")
        )
      )
    )
  }

  qc <- get_qc()

  data_card <- card(
    card_header(
      div(
        div(
          textOutput("ai_title", inline = TRUE),
          span(" | "),
          textOutput("ai_row_count", inline = TRUE)
        ),
        downloadButton(
          "ai_download",
          span(
            HTML(
              '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14"
               viewBox="0 0 24 24" fill="none" stroke="currentColor"
               stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
               style="vertical-align: -1px; margin-right: 4px;">
               <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>
               <polyline points="17 21 17 13 7 13 7 21"/>
               <polyline points="7 3 7 8 15 8"/>
               </svg>'
            ),
            "Download CSV"
          ),
          class = "btn-sm btn-csv-download"
        ),
        class = "d-flex justify-content-between align-items-center w-100"
      )
    ),
    DTOutput("ai_data_table"),
    full_screen = TRUE
  )

  chart_row <- layout_columns(
    card(
      card_header("Sector Profitability"),
      plotlyOutput("ai_chart_a"),
      full_screen = TRUE
    ),
    card(
      card_header("Metric Trend"),
      plotlyOutput("ai_chart_b"),
      full_screen = TRUE
    ),
    col_widths = c(6, 6)
  )

  layout_sidebar(
    sidebar = qc$sidebar(open = "desktop", width = 400),
    h2("fin-chat"),
    data_card,
    chart_row
  )
}

ai_explorer_server <- function(input, output, session) {
  if (!has_token()) return()

  qc <- get_qc()
  qc_vals <- qc$server()

  output$ai_title <- renderText({
    title <- qc_vals$title()
    if (is.null(title) || title == "") "Filtered Data" else title
  })

  output$ai_row_count <- renderText({
    filtered <- qc_vals$df()
    paste(nrow(filtered), "rows")
  })

  output$ai_data_table <- renderDT({
    filtered <- qc_vals$df()
    datatable(
      head(filtered, 10),
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        dom = "t"
      ),
      rownames = FALSE
    )
  })

  output$ai_download <- downloadHandler(
    filename = function() "filtered_financial_data.csv",
    content = function(file) {
      write.csv(qc_vals$df(), file, row.names = FALSE)
    }
  )

  # Helper to determine data shape
  data_shape <- function(filtered) {
    list(
      n_companies = length(unique(filtered$Company)),
      n_sectors = length(unique(filtered$Category)),
      n_years = length(unique(filtered$Year))
    )
  }

  output$ai_chart_a <- renderPlotly({
    filtered <- qc_vals$df()
    metric <- infer_metric(qc_vals$title())
    unit <- METRIC_CHOICES[metric]
    if (nrow(filtered) == 0) return(ggplotly(empty_chart()))

    shape <- data_shape(filtered)
    p <- if (shape$n_companies == 1) {
      build_single_company_summary(filtered, metric, unit)
    } else if (shape$n_sectors == 1 || shape$n_years == 1) {
      build_company_comparison_bar(filtered, metric, unit)
    } else {
      build_sector_bar(filtered, metric, unit)
    }
    ggplotly(p) %>%
      config(displayModeBar = FALSE) %>%
      layout(xaxis = list(fixedrange = TRUE), yaxis = list(fixedrange = TRUE))
  })

  output$ai_chart_b <- renderPlotly({
    filtered <- qc_vals$df()
    metric <- infer_metric(qc_vals$title())
    unit <- METRIC_CHOICES[metric]
    if (nrow(filtered) == 0) return(ggplotly(empty_chart()))

    shape <- data_shape(filtered)
    p <- if (shape$n_companies == 1) {
      company <- filtered$Company[1]
      if (shape$n_years > 1) {
        build_company_trend(filtered, metric, unit)
      } else {
        build_cash_flows(filtered, company)
      }
    } else if (shape$n_years == 1) {
      build_peer_scatter(filtered, metric, unit)
    } else if (shape$n_companies <= 5) {
      build_company_trend(filtered, metric, unit)
    } else {
      build_metric_trend(filtered, metric, unit)
    }
    ggplotly(p) %>%
      config(displayModeBar = FALSE) %>%
      layout(xaxis = list(fixedrange = TRUE), yaxis = list(fixedrange = TRUE))
  })
}
