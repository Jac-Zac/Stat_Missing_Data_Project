# Statistical Analysis of Missing Data

## Project Overview

This project focuses on analyzing Missing At Random (MAR) data patterns using simulated datasets. The analysis is conducted through various statistical methods to understand and handle missing data scenarios effectively.
... (not only missing at random ...)

# Work summary

# Create synthetic dataset

- regression/classification on complete dataset

Remove data: MCAR, MAR on only 1 cov e + cov (4 Combination)

Techniques for handling missing data:

-Observation removal
-Covariate removal
-Imputation:
---Statistical (mean/mode/median/etc.)
---Conditional statistics (conditional mean, etc.)
---Model-based (regression/GAM/tree/etc.)

After "reconstructing the data", use the exact same code used for regression/classification, input the "new" datasets and observe the differences

#### Redo all the work on a real dataset

## TODO

> Currently many functions are just template pre-made to test things out

- Explore MAR (just mention the other and explain why we choose mar) in the final report

  > Showcase what happens

- Test for two different percentage 5% - 15% for example

- [ ] Review functions inside [`synthetic_data.R`](src/synthetic_data.R)
- [x] Review functions inside [`missing_data.R`](src/missing_data.R)
- [ ] Perhaps use something like mice. Might be very interesting for things like `md.pattern(data)` function

Useful resources for mice:

- [mice package](https://cran.r-project.org/web/packages/mice/mice.pdf)
- [First](https://www.youtube.com/watch?v=MpnxwNXGV-E)
- [Second](https://www.youtube.com/watch?v=sNNoTd7xI-4)

Resources from literature (vi metto tutto ciò che penso possa essere utile, anche per un secondo momento):

- [Outliers and missing values](https://sci-hub.ru/10.1111/j.1440-1681.2007.04860.x)
- [Varie tecniche di imputazione in dettaglio](https://www.researchgate.net/publication/220579612_Missing_Data_Imputation_Techniques)

## Project Structure

```bash
.
├── notebooks
│   ├── final_results.Rmd
│   └── initial_experiments.Rmd
├── src
│   ├── missing_data.R
│   └── synthetic_data.R
│   └── utils.R
└── README.md
```

## Description

The project investigates Missing At Random (MAR) patterns in data through simulation studies. We develop and test our methodological approach using simulated datasets before applying it to real-world scenarios.

##### The analysis includes:

- Data simulation procedures
- Implementation of MAR mechanisms
- Statistical analysis of missing patterns
- Evaluation of handling methods
- Performance metrics and results visualization

## Documentation

Detailed documentation is available in the following notebooks:

- [`initial_experiments.Rmd`](notebooks/initial_experiments.Rmd): Initial analysis and methodology validation
- [`final_results.Rmd`](notebooks/final_results.Rmd): Comprehensive results and conclusions

#### Utilities

- [`synthetic_data.R`](src/synthetic_data.R): Functions to generate a synthetic dataset
- [`missing_data.R`](src/missing_data.R): Functions to artificially generate missing data
- [`utils.R`](src/utils.R): Functions that are general utilities

## Preliminary Results

_Note: Preliminary results should be submitted 10 days before the exam for feedback on next steps._

## Contributors

- Jacopo Zacchigna

---

_This project is part of the Statistical Methods Examination._
