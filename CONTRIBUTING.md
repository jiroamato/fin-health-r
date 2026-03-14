# Contributing

Contributions of all kinds are welcome here, and they are greatly appreciated!
Every little bit helps, and credit will always be given.

## Example Contributions

You can contribute in many ways, for example:

* [Report bugs](#report-bugs)
* [Fix Bugs](#fix-bugs)
* [Implement Features](#implement-features)
* [Write Documentation](#write-documentation)
* [Submit Feedback](#submit-feedback)

### Report Bugs

Report bugs at <https://github.com/jiroamato/fin-health-r/issues>.

**If you are reporting a bug, please follow the template guidelines. The more
detailed your report, the easier and thus faster we can help you.**

### Fix Bugs

Look through the GitHub issues for bugs. Anything labelled with `bug` and `help wanted` is open to whoever wants to implement it. When you decide to work on such an issue, please assign yourself to it and add a comment that you'll be working on that, too.

### Implement Features

Look through the GitHub issues for features. Anything labelled with
`enhancement` and `help wanted` is open to whoever wants to implement it. As
for [fixing bugs](#fix-bugs), please assign yourself to the issue and add a comment that you'll be working on that, too.

### Write Documentation

fin-health-r could always use more documentation, whether as
part of the official documentation, in code comments, or even on the web in blog
posts, articles, and such. Just
[open an issue](https://github.com/jiroamato/fin-health-r/issues)
to let us know what you will be working on so that we can provide you with guidance.

### Submit Feedback

The best way to send feedback is to file an issue at
<https://github.com/jiroamato/fin-health-r/issues>.

## Git Workflow

We use a branching workflow based on GitHub Flow. Here's how it works:

### Branch Structure

```
main
 └── dev
      ├── feature/feature-name
      └── fix/bug-name
```

### Workflow Steps

1. **`main` branch**: The stable, production-ready branch. Only receives merges from `dev` after milestone completion.

2. **`dev` branch**: The integration branch where all features and fixes are merged. Branched from `main`.

3. **Feature branches**: For new features, branch from `dev`:

   ```bash
   git switch dev
   git pull origin dev
   git checkout -b feature/your-feature-name
   git push origin feature/your-feature-name
   ```

4. **Fix branches**: For bug fixes, branch from `dev`:

   ```bash
   git switch dev
   git pull origin dev
   git checkout -b fix/bug-name
   git push origin fix/bug-name
   ```

5. **Merging back**: Once your feature is complete, create a PR from `feature/your-feature-name` → `dev`.

### Pull Request Process

1. Ensure the app runs locally before creating a PR
2. Address all review comments before merging
3. After approval, merge and delete the feature branch

## Developer Setup

Ready to contribute? Here's how to set up fin-health-r for
local development.

1. Install [R](https://cran.r-project.org/) (version 4.4+) as a prerequisite.

2. Fork the <https://github.com/jiroamato/fin-health-r>
   repository on GitHub.

3. Clone your fork locally

    ```shell
    git clone git@github.com:your_name_here/fin-health-r.git
    ```

4. Install `renv` if you don't already have it, then restore the project package environment:

   ```r
   # Open R in the project directory, then run:
   install.packages("renv")
   renv::restore()
   ```

5. Create a branch for local development using `dev` as a starting point. Use `fix` or `feature` as a prefix for your branch name.

    ```shell
    git checkout dev
    git checkout -b fix/name-of-your-bugfix
    ```

    Now you can make your changes locally.

6. When you're done making changes, lint your R code with [lintr](https://lintr.r-lib.org/):

    ```r
    lintr::lint_dir("R/")
    ```

7. Commit your changes and push your branch to GitHub. Please use [semantic
   commit messages](https://www.conventionalcommits.org/).

    ```shell
    git add .
    git commit -m "fix: summarize your changes"
    git push -u origin fix/name-of-your-bugfix
    ```

8. Open the link displayed in the message when pushing your new branch in order to submit a pull request.

### Pull Request Guidelines

Before you submit a pull request, check that it meets these guidelines:

1. If the pull request adds functionality, the docs should be updated.
2. Your pull request will automatically be checked by CI. It needs to pass before it can be considered for merging.
