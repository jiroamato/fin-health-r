# fin-health dashboard — entry point (Shiny for R)

library(shiny)
library(bslib)

# Source modules
source("R/data.R")

# Custom CSS
css_tag <- tags$link(rel = "stylesheet", href = "custom_styles.css")

# Navbar with page tabs
ui <- page_navbar(
  title = "fin-health",
  id = "main_nav",
  fillable = TRUE,
  header = css_tag,
  nav_panel("Sector Analysis", h3("Sector Analysis — coming soon")),
  nav_panel("Company Health", h3("Company Health — coming soon")),
  nav_panel("fin-chat", h3("fin-chat — coming soon")),
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
  # Module servers will be added here
}

shinyApp(ui, server)
