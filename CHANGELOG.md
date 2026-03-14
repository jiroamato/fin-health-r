# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.1.0] - (2026-03-15)

### Added
- **R Shiny Dashboard**: Rebuilt the entire application in R using Shiny and bslib, replacing the original Python Shiny implementation.
- **Sector Analysis Page**: Interactive sector-level profitability and revenue growth visualizations using ggplot2 and plotly, with KPI summary cards and trend indicators.
- **Company Health Page**: Company-level deep-dive with reactive financial ratios (Current Ratio, Debt/Equity, ROE), time-series charts for revenue, financial ratios, and cash flows, and automated health status indicators (Healthy/Warning/Danger).
- **Fin-Chat (AI Explorer)**: Natural language querying page powered by querychat and ellmer, enabling conversational data filtering and LLM-driven insights.
- **Custom CSS**: Adapted stylesheet for R Shiny with plotly containers, flat-card aesthetic, and DM Sans typography.
- **CI/CD Pipeline**: GitHub Actions workflow with R lintr for code quality and app validation checks.
- **Package Management**: renv-based dependency management with lockfile and manifest for reproducible environments.
- **Project Documentation**: Updated README, CONTRIBUTING, CODE_OF_CONDUCT, and LICENSE for the R project.

### Changed
- **Language Migration**: Migrated from Python (Shiny for Python, Altair) to R (Shiny for R, ggplot2/plotly).
- **Database Backend**: Replaced DuckDB with RSQLite for Posit Connect compatibility.
- **Package Manager**: Replaced conda/pip with renv for R package management.
