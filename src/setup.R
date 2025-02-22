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
# install.packages("ggExtra")
# install.packages("plotly")
# install.packages(" ks")
# install.packages("VIM") # (Visualization and Imputation of Missing Values) 

# Inputation methods
# install.packages("mice")
# suppressMessages(library(mice))
# Other alternative

## Load requirements 
suppressMessages(library(ggplot2))
suppressMessages(library(ggExtra))
suppressMessages(library(here))
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
suppressMessages(library(plotly))
suppressMessages(library(dplyr))
suppressMessages(library(caret))
suppressMessages(library(stringr))
suppressMessages(library(cowplot))
# suppressMessages(library(ks))

# suppressMessages(library(caret))

# Load utilities using here()
source(here("src", "synthetic_data.R"))
source(here("src", "missing_data.R"))
source(here("src", "imputation_methods.R"))
source(here("src", "metrics.R"))
source(here("src", "plots.R"))
source(here("src", "utils.R"))

# Select Nord palettes
frost_palette <- nord("frost", 4)
aurora_palette <- nord("aurora", 4)

# Define some basic nord theme colors to use across the document 
blue_nord <- frost_palette[[length(frost_palette)]]
red_nord <- aurora_palette[[1]]
green_nord <- aurora_palette[[3]]
nord_contrast = c(blue_nord, red_nord)

# Fixes the seed for reproducibility
set.seed(42)
