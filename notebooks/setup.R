## Install requirements
# install.packages("ggplot2")
# install.packages("GGally")
# install.packages("reshape2")
# install.packages("corrplot")
# install.packages("here")
# install.packages("pROC")
# install.packages("randomForest")
# install.packages("mgcv")
# install.packages("nord")
# install ...

# Inputation methods
# install.packages("mice")
# Other alternative
# install.packages("VIM") # (Visualization and Imputation of Missing Values) 


## Load requirements 
suppressMessages(library(ggplot2))
suppressMessages(library(here))
suppressMessages(library(GGally))
suppressMessages(library(pROC))
suppressMessages(library(corrplot))
suppressMessages(library(reshape2))
suppressMessages(library(mice))
suppressMessages(library(VIM))
suppressMessages(library(RColorBrewer))
suppressMessages(library(nord))

# Load utilities using here()
source(here("src", "synthetic_data.R"))
source(here("src", "missing_data.R"))
source(here("src", "inputation_methods.R"))
source(here("src", "metrics.R"))
source(here("src", "utils.R"))

# Fixes the seed for reproducibility
set.seed(42)
