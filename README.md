> [!WARNING]
> The project structure is under maintenance we will provide a new updated structure soon

> [!IMPORTANT]
> Since most of the problems are data dependent, this work is a preliminary analysis that aims to show the flowchart of the project. Thus, some analysis are approximate and the models aren't tuned. The final experiment will be on a complete different dataset.

# Dealing with missing data

## Project Overview

This project focuses on analyzing **Missing At Random (MAR)** data patterns using simulated dataset. The analysis is conducted through various statistical methods to understand and handle missing data scenarios effectively.
The entire experiment is guided by many metrics that give us a way to compare the results.

### Presentation Outline

> 5 Minutes

Abstract and study objective. Description of project structure.
Description of project structure.

- #### Part 1: Synthetic Data Study
  > 10 Minutes

Missing value generation mechanisms.
**Imputation strategies:**

- Linear with heteroscedasticity

- Polynomial imbalanced

- Categorical

- Non-polynomial

Explanation of different Metrics for differences between distributional, and why we choose to use them.
To measure the divergence between the original and imputed datasets, two key metrics are utilized: Wasserstein Distance to quantify distributional differences and sqrt of Jensen-Shannon Divergence to measure the similarity between probability distributions.

**Visualization and comparison of imputation strategies**

- #### Part 2: Case Study
  > 10 Minutes

This part will be a case study on a real dataset with missing data. In this section we will apply the techniques we have study previously taking in consideration what we learned.

- Dataset description

  - Highlight missing value mechanisms
  - Exploratory data analysis
  - Train-test split

- Dataset imputation

- Model fitting

- Results comparison using distance-based metrics

After imputation, the datasets generated under different conditions (e.g., 5% and 15% missing data) are analyzed, and models are fitted to assess the quality of reconstruction. Finally, using standard prediction metrics, the performance of models trained on the imputed datasets is compared to those trained on the original dataset. This comparison allows for a comprehensive evaluation of the effectiveness of different imputation techniques.

## Project Structure

```bash
.
├── notebooks
│   ├── dataset_analysis
│   │   └── ...
│   ├── final_results.Rmd
│   └── imputation_techniques_visualization.Rmd
├── src
│   ├── inputation_methods.R
│   ├── metrics.R
│   ├── setup.R
│   ├── plots.R
│   ├── missing_data.R
│   ├── synthetic_data.R
│   └── utils.R
└── README.md
```

## Documentation

Detailed documentation is available in the following notebooks:

- [`imputation_techniques_visualization.Rmd`](notebooks/imputation_techniques_visualization.Rmd): First part of the project, Analyzing imputation on synthetic data
- [`case_study.Rmd`](notebooks/imputation_techniques_visualization.Rmd): This will contain a case study on a real dataset
- [`final_results.Rmd`](notebooks/final_results.Rmd): Comprehensive results and conclusions

#### Utilities

- [`synthetic_data.R`](src/synthetic_data.R): Functions to generate a synthetic dataset
- [`inputation_methods.R`](src/inputation_methods.R): Functions to implement different imputation techniques
- [`missing_data.R`](src/missing_data.R): Functions to artificially generate missing data
- [`metrics.R`](src/metrics.R): Functions to evaluate different strategies to handle missing data
- [`utils.R`](src/utils.R): Functions that are general utilities

### Project Map

To add new version ...

## TODO

> Currently many functions are just template pre-made to test things out

- Explore MAR (just mention the other and explain why we choose mar in the final report)

  > Showcase what happens

- [ ] Perform the study on the real dataset
- [ ] Continue the exploration of synthetic data

#### Useful resources for mice:

> Possibly note needed

- [mice package](https://cran.r-project.org/web/packages/mice/mice.pdf)
- [First](https://www.youtube.com/watch?v=MpnxwNXGV-E)
- [Second](https://www.youtube.com/watch?v=sNNoTd7xI-4)

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
