# fin-health dashboard — entry point (Shiny for R)

library(shiny)
library(bslib)

# Source all R modules
source("R/data.R")
source("R/charts.R")
source("R/helpers.R")
source("R/mod_sector.R")
source("R/mod_company.R")
source("R/mod_ai_explorer.R")

# Custom CSS
css_tag <- tags$link(rel = "stylesheet", href = "custom_styles.css")

# Navbar with page tabs
ui <- page_navbar(
  title = "fin-health",
  id = "main_nav",
  fillable = TRUE,
  header = css_tag,
  nav_panel("Sector Analysis", sector_ui("sector")),
  nav_panel("Company Health", company_ui("company")),
  nav_panel("fin-chat", ai_explorer_ui("ai")),
  footer = tags$footer(
    tags$div(
      tags$p(
        "US Corporate Financial Health Dashboard | ",
        "Jiro Amato | ",
        tags$a("GitHub Repo", href = "https://github.com/jiroamato/fin-health-r"),
        style = "text-align: center; font-size: 0.85em; color: #888;"
      ),
      class = "footer-container"
    )
  )
)

server <- function(input, output, session) {
  sector_server("sector")
  company_server("company")
  ai_explorer_server("ai")
}

shinyApp(ui, server)
