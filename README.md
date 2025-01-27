# Dealing with missing data

## Project Overview

This project focuses on analyzing **Missing At Random (MAR)** data patterns using simulated dataset. The analysis is conducted through various statistical methods to understand and handle missing data scenarios effectively.
The entire experiment is guided by many metrics that give us a way to compare the results.

## Presentation Outline

> 5 Minutes

Abstract and study objective. Description of project structure.
Description of project structure.

### Part 1: Synthetic Data Study

> 10 Minutes

Missing value generation mechanisms. Exploration via plots of different mechanisms.

**Imputation strategies:**

- Added noise to to imputation

- Linear with heteroscedasticity

- Polynomial imbalanced

- Non-polynomial (Piecewise)

Explanation of different Metrics for differences between distributional, and why we choose to use them.
To measure the divergence between the original and imputed datasets, two key metrics are utilized: Wasserstein Distance to quantify distributional differences and sqrt of Jensen-Shannon Divergence to measure the similarity between probability distributions.

**Visualization and comparison of imputation strategies**

### Part 2: Case Study

> 10 Minutes

This part will be a case study on a real dataset with missing data. In this section we will apply the techniques we have study previously taking in consideration what we learned.

- Dataset description

  - Highlight missing value mechanisms
  - Exploratory data analysis
  - Train-test split

- Dataset imputation

- Model fitting

- Results comparison

## Project Structure

```bash
.
├── notebooks
│   ├── partial_analyses
│   │   ├── part_1.Rmd
│   │   └── part_2.Rmd
│   └── final_results.rmd
├── src
│   ├── imputation_methods.R
│   ├── metrics.R
│   ├── missing_data.R
│   ├── plots.R
│   ├── setup.R
│   ├── synthetic_data.R
│   └── utils.R
└── README.md
```

- [`README.md`](README.md): Project documentation
- [`part_1.Rmd`](notebooks/imputation_techniqus_visualization.Rmd): Analyzing missing data patterns + imputation on synthetic data
- [`part_2.Rmd`](notebooks/imputation_techniques_visualization.Rmd): This will contain a case study on a real dataset
- [`final_results.Rmd`](notebooks/final_results.Rmd): Comprehensive results and conclusions (the file which puts everything together)
  > Run knit on this file to obtain the final report

#### Utilities

- [`synthetic_data.R`](src/synthetic_data.R): Functions to generate a synthetic dataset
- [`imputation_methods.R`](src/imputation_methods.R): Functions to implement different imputation techniques
- [`missing_data.R`](src/missing_data.R): Functions to artificially generate missing data
- [`metrics.R`](src/metrics.R): Functions to evaluate different strategies to handle missing data
- [`utils.R`](src/utils.R): Functions that are general utilities
- [`plots.R`](src/plots.R): Functions to make plots
- [`setup.R`](src/setup.R): All libraries + setting seed (imported for each notebook)

### Project Map

To add new version ...

#### Resources from literature

> Everything that might be useful even in the future

- [Outliers and missing values](https://sci-hub.ru/10.1111/j.1440-1681.2007.04860.x)
- [Various imputation techniques in detail](https://www.researchgate.net/publication/220579612_Missing_Data_Imputation_Techniques)
- [Generating Synthetic Missing Data: A Review by Missing Mechanism](https://ieeexplore.ieee.org/document/8605316/)
- [Imputation techniques: an overview](https://www.researchgate.net/publication/220579612_Missing_Data_Imputation_Techniques)

## Contributors

- Jacopo Zacchigna, Devid Rosa, Ludovica Bianchi, Cristiano Baldassi

---

_This project is part of the Statistical Methods Examination._
