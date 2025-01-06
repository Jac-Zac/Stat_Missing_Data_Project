# Statistical Analysis of Missing Data

## Project Overview

This project focuses on analyzing Missing At Random (MAR) data patterns using simulated datasets. The analysis is conducted through various statistical methods to understand and handle missing data scenarios effectively.
... (not only missing at random ...)

## TODO

> Currently many functions are just template pre-made to test things out

- [ ] Review functions inside [`synthetic_data.R`](src/synthetic_data.R)
- [ ] Review functions inside [`missing_data.R`](src/missing_data.R)
- [ ] Test with around to 5% - 20% missing data (standard)
- [ ] Perhaps use something like mice. Might be very interesting for things like `md.pattern(data)` function

Useful resources for mice:

- [First](https://www.youtube.com/watch?v=MpnxwNXGV-E)
- [Second](https://www.youtube.com/watch?v=sNNoTd7xI-4)

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
