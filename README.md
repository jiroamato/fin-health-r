# fin-health-r

| | |
| --- | --- |
| CI/CD | [![CI](https://github.com/jiroamato/fin-health-r/actions/workflows/ci.yml/badge.svg)](https://github.com/jiroamato/fin-health-r/actions/workflows/ci.yml) |
| Project | [![GitHub Release](https://img.shields.io/github/v/release/jiroamato/fin-health-r?color=green)](https://github.com/jiroamato/fin-health-r/releases) [![R Version](https://img.shields.io/badge/R-4.4+-blue)](https://cran.r-project.org/) [![Repo Status](https://img.shields.io/badge/repo%20status-Active-brightgreen)](https://github.com/jiroamato/fin-health-r) |
| Meta | [![Code of Conduct](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md) [![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) |

## Project Synopsis

`fin-health-r` is an interactive Shiny for R dashboard that visualizes the financial health of publicly traded companies. It allows users to explore key financial metrics such as revenue, profitability, debt ratios, and cash flow across companies and time periods. fin-health-r supports investors and analysts in making data-driven comparisons and evaluating corporate financial performance across sectors and time.

## Motivation
Investment analysts and portfolio managers often need to compare financial performance across sectors and individual companies to support data-driven investment decisions. However, extracting insights from financial statements typically requires manually compiling data and creating ad-hoc visualizations, a process that can be both time-consuming and prone to errors.

`fin-health-r` addresses this challenge by providing a centralized, interactive dashboard that enables users to explore financial performance efficiently. By allowing users to filter data by time period, sector, and financial metrics, the dashboard facilitates rapid analysis of profitability trends, peer benchmarking, and key financial indicators.

## Features and User Interface
- **Sector Analysis (Strategic Overview)**
    - **Peer Benchmarking**: Visualize sector profitability and revenue growth using reactive ggplot2/plotly scatter plots and bar charts.
    - **Trend Indicators**: Real-time KPI cards showing margin trends with visual directional cues.

- **Company Health (Operational Deep-Dive)**
    - **Reactive Financial Ratios**: Instant calculation of Liquidity (Current Ratio), Solvency (Debt/Equity), and Profitability (ROE) metrics.
    - **Automated Status Auditing**: Visual health icons (Healthy/Warning/Danger) based on industry-standard financial thresholds.

- **Fin-Chat: Natural Language Querying**
    - **Conversational Filtering**: Instead of manual sliders, use the fin-chat interface to ask questions like "Which companies in the Tech sector had a net profit margin above 15%?".
    - **LLM-Powered Insights**: Integrated querychat logic translates natural language into precise data filters, lowering the barrier for non-technical users.

## Deployment

| Build | URL |
|-------|-----|
| Stable (`main`) | [https://jiroamato-fin-health-r-stable.share.connect.posit.cloud](https://jiroamato-fin-health-r-stable.share.connect.posit.cloud) |
| Preview (`dev`) | [https://jiroamato-fin-health-r-dev.share.connect.posit.cloud](https://jiroamato-fin-health-r-dev.share.connect.posit.cloud) |

## Developer Setup

### Dependencies

-   R (version 4.4 or higher)
-   [`renv`](https://rstudio.github.io/renv/) for package management

For a more comprehensive guide on development guidelines for this project, check out our contributing page [here](./CONTRIBUTING.md).

1. Install [R](https://cran.r-project.org/) (version 4.4+) as a prerequisite.

2. Open terminal and run the following commands.

3. Clone the repository:

```bash
git clone https://github.com/jiroamato/fin-health-r.git
cd fin-health-r
```

4. Install `renv` if you don't already have it, then restore the project package environment:

```r
# Open R in the project directory, then run:
install.packages("renv")
renv::restore()
```

5. Create a `.Renviron` file in the project root with your API key (required for the fin-chat feature):

```
GITHUB_API_KEY=your-api-key-here
```

6. Run the fin-health Shiny dashboard locally:

```r
shiny::runApp()
```

## Author

- Jiro Amato

## Contributing

Interested in contributing? Check out the contributing guidelines [here](./CONTRIBUTING.md). Please note that this project is released with a Code of Conduct. By contributing to this project, you agree to abide by its terms.

## License

- Copyright (c) 2026 Jiro Amato

- Free software distributed under the [MIT License](./LICENSE.md).
- Documentation made available under **Creative Commons By 4.0 - Attribution 4.0 International** ([CC-BY-4.0](./LICENSE.md))
