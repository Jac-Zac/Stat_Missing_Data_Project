## Install requirements
# install.packages("ggplot2")
# install.packages("GGally")
# install.packages("reshape2")
# install.packages("corrplot")
# install.packages("here")
# install.packages("pROC")
# install.packages("randomForest")
# install.packages("mgcv")
# install.packages("rpart")
# install.packages("mgcv")
# install.packages("reshape2")
# install.packages("mice")
# install.packages("missMethods")
# install.packages("transport")
# install.packages("philentropy")
# install.package("transport")
# install.packages("gridExtra")
# install.packages("VIM") # (Visualization and Imputation of Missing Values) 

# Inputation methods
# install.packages("mice")
# suppressMessages(library(mice))
# Other alternative

## Load requirements 
suppressMessages(library(ggplot2))
suppressMessages(library(here))
suppressMessages(library(pROC))
suppressMessages(library(corrplot))
suppressMessages(library(reshape2))
suppressMessages(library(VIM))
suppressMessages(library(RColorBrewer))
suppressMessages(library(nord))
suppressMessages(library(GGally))
suppressMessages(library(rpart))
suppressMessages(library(mgcv))
suppressMessages(library(mice))
suppressMessages(library(missMethods))
suppressMessages(library(randomForest))
suppressMessages(library(philentropy))
suppressMessages(library(transport))
suppressMessages(library(gridExtra))
suppressMessages(library(MASS))  # For stepAIC

# suppressMessages(library(caret))

# Load utilities using here()
source(here("src", "synthetic_data.R"))
source(here("src", "missing_data.R"))
source(here("src", "imputation_methods.R"))
source(here("src", "metrics.R"))
source(here("src", "plots.R"))
source(here("src", "utils.R"))

# Fixes the seed for reproducibility
set.seed(42)
