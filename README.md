# Pakistani Household Demographic Analysis
## Comprehensive Survey Data Analysis in R

![R Version](https://img.shields.io/badge/R-4.3.3+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Status](https://img.shields.io/badge/status-Complete-brightgreen.svg)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Project Description](#project-description)
- [Key Features](#key-features)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Data Description](#data-description)
- [Methodology](#methodology)
- [Key Findings](#key-findings)
- [Installation](#installation)
- [Usage](#usage)
- [Output Files](#output-files)
- [Advanced Features](#advanced-features)
- [Results & Visualizations](#results--visualizations)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Overview

This project provides a **comprehensive demographic analysis** of Pakistani household survey data using R. It calculates standard demographic indicators from weighted survey data, produces professional visualizations, and includes an advanced machine learning classification model.

**Key Outputs:**
- 7 demographic indicators (Sex Ratio, CBR, CDR, GFR, ASFR, TFR, IMR)
- 10 publication-ready visualizations
- 3 machine learning models (SVM with different kernels)
- 8 CSV data files with complete calculations

---

## Project Description

### Purpose

Analyze household survey data from Pakistan to compute essential demographic indicators that inform policy, research, and program planning. The analysis employs survey-weighted calculations to ensure population representativeness.

### Target Audience

- Demographers and population researchers
- Policy makers and program planners
- Data analysts and statisticians
- R programmers learning survey analysis

### Survey Characteristics

- **Region:** Pakistan
- **Population:** Household members across multiple provinces
- **Survey Design:** Weighted household survey
- **Data Format:** SPSS (.sav files)
- **Reference Period:** 2018-2020 (births and deaths)

---

## Key Features

### 📊 Demographic Indicators

| Indicator | Formula | Source | Result |
|-----------|---------|--------|--------|
| **Sex Ratio** | Males/Females × 100 | Roster.sav | 102.57 |
| **CBR** | Births/Population × 1000 | Birth.sav | 26.88 per 1,000 |
| **CDR** | Deaths/Population × 1000 | Death.sav | 6.67 per 1,000 |
| **GFR** | Births/Women 15-49 × 1000 | Birth.sav | 111.80 per 1,000 |
| **ASFR** | Age-group births/women × 1000 | Birth.sav | 10 age groups |
| **TFR** | Sum(ASFR) / 1000 × 5 | Birth.sav | 3.685 children/woman |
| **IMR** | Infant deaths/Births × 1000 | Birth.sav | 55.75 per 1,000 |

### 🎨 Visualizations

- Distribution charts (births, deaths, ages)
- Population pyramid
- Fertility patterns by age group
- Gender-stratified demographics
- Births vs. deaths comparison
- Educational attainment distribution

### 🤖 Machine Learning

- Support Vector Machine (SVM) classification
- Three kernel types: Linear, Radial (RBF), Polynomial
- Automatic best model selection
- Literacy prediction for new individuals
- Model performance metrics (Accuracy, F1, Sensitivity, Specificity)

### 🔧 Methodological Advantages

✅ **Survey-weighted calculations** - Accounts for survey design  
✅ **No external dependencies** - Manual metrics calculation (caret-free)  
✅ **Reproducible** - Fixed random seed for ML models  
✅ **Well-documented** - Comprehensive code comments  
✅ **Production-ready** - Tested and verified calculations  

---

## Quick Start

### 1️⃣ Prerequisites
- R 4.0+
- RStudio (optional but recommended)
- Required packages: haven, dplyr, ggplot2, gridExtra, e1071

### 2️⃣ Installation

```bash
# Clone repository
git clone https://github.com/yourusername/pakistan-demographic-analysis.git
cd pakistan-demographic-analysis

# Install required packages (if not already installed)
R --vanilla << 'EOF'
packages <- c("haven", "dplyr", "ggplot2", "gridExtra", "knitr", "kableExtra", "readr", "e1071")
install.packages(packages)
EOF
```

### 3️⃣ Prepare Data

Place SPSS files in your working directory:
```
your-working-directory/
├── Birth.sav
├── Death.sav
├── Weights_Assigned.sav
├── Roster.sav
├── Fertility.sav
└── PROJECT_COMPLETE_R_CODE.R
```

### 4️⃣ Run Analysis

```r
# In R/RStudio
setwd("path/to/your/data")
source("PROJECT_COMPLETE_R_CODE.R")
```

### 5️⃣ View Results

```bash
# CSV files with demographic indicators
ls *.csv

# PNG visualizations
ls graphs/

# SVM model
ls *.rds
```

---

## Project Structure

```
pakistan-demographic-analysis/
│
├── README.md                          # This file
├── PROJECT_COMPLETE_R_CODE.R          # Main consolidated script
├── PROJECT_CODE_GUIDE.md              # Detailed documentation
├── PROJECT_CODE_INDEX.md              # Comprehensive code index
│
├── data/                              # Input SPSS files
│   ├── Birth.sav                      # Birth records (2018-2020)
│   ├── Death.sav                      # Death records (2018-2020)
│   ├── Weights_Assigned.sav           # Survey weights & demographics
│   ├── Roster.sav                     # Household roster
│   └── Fertility.sav                  # Fertility history
│
├── outputs/                           # Generated results
│   ├── *.csv                          # Demographic indicators (8 files)
│   ├── graphs/                        # Visualizations (10 PNG files)
│   ├── *.rds                          # SVM model objects
│   └── demographic_indicators_summary.csv
│
└── docs/                              # Additional documentation
    ├── METHODOLOGY.md                 # Detailed formulas
    ├── DATA_DICTIONARY.md             # Variable descriptions
    └── EXAMPLES.md                    # Usage examples
```

---

## Data Description

### Input Files (SPSS Format)

#### **Birth.sav**
- **Records:** ~3,000+ births
- **Time Period:** 2018-2020
- **Key Variables:**
  - BIRTH_YEAR_BI: Year of birth (2018-2020)
  - BIRTH_ORDER: Birth order (1, 2, 3, ...)
  - IS_ALIVE: Survival status (1=Living, 2=Deceased)
  - WOMEN_ID: Link to mother's record
  - BIRTH_TYPE: Single or multiple birth
  - MONTHS_BABY_LIVED, DAYS_BABY_LIVED: Infant age at death

#### **Death.sav**
- **Records:** ~2,000+ deaths
- **Time Period:** 2018-2020
- **Key Variables:**
  - DEATH_YEAR: Year of death
  - AGE_AT_DEATH: Age in completed years
  - GENDER: Sex of deceased (1=Male, 2=Female)
  - YEARS_BABY_LIVED, MONTHS_BABY_LIVED, DAYS_BABY_LIVED: Infant age

#### **Weights_Assigned.sav**
- **Records:** ~225,900 persons (entire population)
- **Key Variables:**
  - HCODE: Household ID
  - ID_CODE: Individual ID
  - Weight: Survey weight (for weighting calculations)
  - GENDER: 1=Male, 2=Female
  - AGE_IN_YEARS: Age in completed years (0-90+)
  - EDUCATION_LEVEL: 0-9 ordinal scale
  - LITERACY_CAN_READ: 1=Yes, 2=No
  - MARITAL_STATUS: 1-6 categories

#### **Roster.sav**
- **Records:** ~225,900 household members
- **Key Variables:**
  - HCODE: Household ID
  - GENDER: 1=Male, 2=Female
  - AGE_IN_YEARS: Age in completed years
  - RELATIONSHIP: Relationship to household head
  - EDUCATION_LEVEL: Highest education level
  - MARITAL_STATUS: Current marital status

#### **Fertility.sav**
- **Records:** ~1,500+ women
- **Key Variables:**
  - HCODE: Household ID
  - WOMEN_ID: Individual ID
  - AGE_AT_FIRST_BIRTH: Age when first child born
  - TOTAL_CHILDREN_EVER_BORN: Parity
  - CURRENT_FERTILITY_STATUS: Pregnant/Not pregnant

### Survey Weights

All demographic calculations use **survey weights** to account for:
- Survey sampling design
- Non-response patterns
- Population distribution adjustments

**Weight Extraction:**
```r
# One weight per household (first Weight value per HCODE)
hh_weights <- weights %>%
  group_by(HCODE) %>%
  summarise(HH_WEIGHT = first(Weight), .groups = "drop")
```

---

## Methodology

### Demographic Indicators Formulas

#### 1. Sex Ratio

$$\text{Sex Ratio} = \frac{\sum \text{Weight}_{\text{GENDER=Male}}}{\sum \text{Weight}_{\text{GENDER=Female}}} \times 100$$

**Interpretation:** Males per 100 females in the population

---

#### 2. Crude Birth Rate (CBR)

$$\text{CBR} = \frac{\text{Total Weighted Births in Year}}{\text{Total Weighted Population}} \times 1000$$

**Numerator:** Birth.sav filtered to calendar year  
**Denominator:** All persons in Weights_Assigned.sav

---

#### 3. Crude Death Rate (CDR)

$$\text{CDR} = \frac{\text{Total Weighted Deaths in Year}}{\text{Total Weighted Population}} \times 1000$$

**Numerator:** Death.sav filtered to calendar year  
**Denominator:** Same as CBR

---

#### 4. General Fertility Rate (GFR)

$$\text{GFR} = \frac{\text{Total Births (all years)}}{\text{Women aged 15-49}} \times 1000$$

**Denominator:** Filter GENDER=2, AGE_IN_YEARS ∈ [15,49]

---

#### 5. Age-Specific Fertility Rates (ASFR)

$$\text{ASFR}_{\text{age}} = \frac{\text{Births to women age X}}{\text{Number of women age X}} \times 1000$$

**Age Groups:** [15,20), [20,25), [25,30), ..., [45,50)  
**Method:** right=FALSE for standard demographic practice  
**Mother's Age Link:** WOMEN_ID = ID_CODE join

---

#### 6. Total Fertility Rate (TFR)

$$\text{TFR} = \sum_{\text{age groups}} \text{ASFR}_{\text{age}} / 1000 \times 5$$

**Width Factor:** 5 years for each age group  
**Interpretation:** Average children per woman lifetime

---

#### 7. Infant Mortality Rate (IMR)

$$\text{IMR} = \frac{\text{Deaths of children aged < 1 year}}{\text{Births in reference period}} \times 1000$$

**Reference Period:** 2018-2020 (3-year average)  
**Infant Definition:** IS_ALIVE = 2 in Birth.sav

---

### Survey Weighting

All rates employ **survey-weighted calculations**:

```r
# Example: CBR calculation
births_weighted <- birth %>%
  filter(BIRTH_YEAR_BI == 2020) %>%
  left_join(hh_weights, by = "HCODE") %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)

cbr <- (births_weighted / total_population) * 1000
```

**Why Weighting?**
- Accounts for survey sampling design
- Corrects for non-response bias
- Produces population-representative estimates

---

### Machine Learning: SVM Classification

#### Model Purpose
Predict literacy status (Literate/Illiterate) based on demographic features

#### Features Used
- AGE_IN_YEARS: Age in completed years
- GENDER: 1=Male, 2=Female
- EDUCATION_LEVEL: 0-9 scale

#### Target Variable
- LITERACY_CAN_READ: 1=Yes, 2=No → Factor(Literate/Illiterate)

#### Kernels Tested

| Kernel | Function | Use Case | Best For |
|--------|----------|----------|----------|
| **Linear** | K(x,y) = x·y | Linear relationships | Simple patterns |
| **Radial (RBF)** | K(x,y) = exp(-γ\|x-y\|²) | Non-linear patterns | Complex, curved boundaries |
| **Polynomial** | K(x,y) = (x·y + 1)^d | Polynomial relationships | Intermediate complexity |

#### Model Selection
- **Train/Test Split:** 70% training / 30% testing
- **Evaluation:** Manual metrics calculation (no caret)
- **Reproducibility:** set.seed(42)
- **Best Model:** Kernel with highest accuracy

#### Performance Metrics
- **Accuracy:** (TP + TN) / Total
- **Sensitivity:** TP / (TP + FN) — True positive rate
- **Specificity:** TN / (TN + FP) — True negative rate
- **Precision:** TP / (TP + FP) — Positive predictive value
- **F1-Score:** 2 × (Precision × Recall) / (Precision + Recall)

---

## Key Findings

### Summary Statistics (2020 Data)

| Indicator | Value | Interpretation |
|-----------|-------|-----------------|
| **Sex Ratio** | 102.57 M:100F | Slightly male-skewed population |
| **CBR** | 26.88 per 1,000 | High fertility (global avg ~18) |
| **CDR** | 6.67 per 1,000 | Low mortality (young population) |
| **GFR** | 111.80 per 1,000 | High reproductive capacity |
| **TFR** | 3.685 children | Unsustainable fertility rate |
| **Peak ASFR** | 209.34 (age 25-29) | Fertility concentrated in late 20s |
| **IMR** | 55.75 per 1,000 | High infant mortality (concern area) |

### Key Demographic Patterns

1. **Young Population Structure**
   - 43% under age 15
   - Population momentum for continued growth
   - High dependency ratio

2. **High Fertility**
   - TFR 3.685 exceeds replacement level (2.1)
   - Peak fertility in ages 25-29
   - Early marriage affects youth fertility

3. **Mortality Patterns**
   - Low general mortality (CDR 6.67)
   - High infant mortality (IMR 55.75)
   - Concentrated in under-5 population

4. **Education Gaps**
   - >40% population with zero education
   - Strong correlation with literacy and mortality
   - Gender disparities in educational attainment

5. **Marriage Patterns**
   - 40% of women married before age 20
   - 20% child marriage (before age 18)
   - Early marriage linked to high fertility

---

## Installation

### System Requirements

- **OS:** Windows, macOS, or Linux
- **R Version:** 4.0 or higher (tested on 4.3.3)
- **RAM:** Minimum 2GB (4GB+ recommended)
- **Disk Space:** ~500MB for data + outputs

### Package Installation

```r
# Install required packages
packages <- c(
  "haven",      # Read SPSS files
  "dplyr",      # Data manipulation
  "ggplot2",    # Visualizations
  "gridExtra",  # Multi-plot layouts
  "knitr",      # Report generation
  "kableExtra", # Table formatting
  "readr",      # CSV I/O
  "e1071"       # SVM models
)

install.packages(packages)
```

### Verify Installation

```r
# Check all packages load successfully
library(haven)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(e1071)

cat("✓ All packages loaded successfully!")
```

---

## Usage

### Basic Workflow

#### Step 1: Set Working Directory

```r
# Point R to directory containing SPSS files
setwd("D:/Ahmad/Downloads/SPSS Data/SPSS Data/")

# Verify files exist
list.files(pattern = ".sav$")
```

#### Step 2: Run Complete Analysis

```r
# Execute consolidated script
source("PROJECT_COMPLETE_R_CODE.R")

# Script will:
# 1. Load all 5 SPSS files
# 2. Calculate 7 demographic indicators
# 3. Create 10 visualizations
# 4. Train 3 SVM models
# 5. Save all outputs
```

#### Step 3: Review Results

```r
# Check generated files
list.files(pattern = ".csv$")   # Demographic indicators
list.files("graphs/")            # Visualizations
list.files(pattern = ".rds$")    # SVM model

# View summary
summary_data <- read_csv("demographic_indicators_summary.csv")
print(summary_data)
```

### Calculate Single Indicator

#### Example: CBR Only

```r
library(haven)
library(dplyr)

# Load data
birth <- as.data.frame(read_sav("Birth.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))

# Prepare weights
hh_weights <- weights %>%
  group_by(HCODE) %>%
  summarise(HH_WEIGHT = first(Weight), .groups = "drop")

# Calculate CBR
births_2020 <- birth %>%
  filter(BIRTH_YEAR_BI == 2020) %>%
  left_join(hh_weights, by = "HCODE") %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)

total_population <- sum(weights$Weight, na.rm = TRUE)

cbr_2020 <- (births_2020 / total_population) * 1000

cat("CBR 2020:", round(cbr_2020, 2), "per 1,000\n")
```

### Make SVM Predictions

#### Example: Predict Literacy for New Individual

```r
# Load trained model
best_model <- readRDS("best_svm_model.rds")

# Create new individual
new_person <- data.frame(
  AGE_IN_YEARS = 35,
  GENDER = 1,        # Male
  EDUCATION_LEVEL = 7
)

# Predict
prediction <- predict(best_model, new_person)
cat("Literacy Status:", prediction, "\n")
```

### Create Custom Visualization

#### Example: Births by Age Group

```r
library(ggplot2)
library(haven)

birth <- as.data.frame(read_sav("Birth.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))

# Link births to mother age
plot_data <- birth %>%
  left_join(weights %>% select(ID_CODE, HCODE, AGE_IN_YEARS) %>% 
            rename(MOTHER_AGE = AGE_IN_YEARS),
            by = c("WOMEN_ID" = "ID_CODE", "HCODE" = "HCODE")) %>%
  filter(!is.na(MOTHER_AGE)) %>%
  mutate(age_group = cut(MOTHER_AGE, 
                         breaks = seq(15, 50, by = 5), 
                         right = FALSE))

# Visualize
ggplot(plot_data, aes(x = age_group, fill = age_group)) +
  geom_bar() +
  labs(title = "Births by Mother's Age Group",
       x = "Age Group", y = "Number of Births") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("births_by_age_group.png", width = 10, height = 6)
```

---

## Output Files

### CSV Files (Demographic Results)

#### 1. demographic_indicators_summary.csv
Complete summary of all 6 indicators in one file
```
Indicator,Value,Unit
Sex Ratio,102.57,M per 100F
Crude Birth Rate,26.88,per 1,000
Crude Death Rate,6.67,per 1,000
General Fertility Rate,111.80,per 1,000 women
Total Fertility Rate,3.685,children/woman
Infant Mortality Rate,55.75,per 1,000 births
```

#### 2. sex_ratio_weighted.csv
- Males (Weighted)
- Females (Weighted)
- Sex Ratio

#### 3. CBR_2020.csv, CDR_2020.csv
- Event counts (births/deaths)
- Population denominator
- Rate value

#### 4. GFR.csv
- Total births
- Women aged 15-49
- Rate value

#### 5. ASFR_all_groups.csv
10 rows (one per age group):
- Age group identifier [15,20), [20,25), etc.
- Births in age group
- Women in age group
- ASFR rate

#### 6. TFR.csv, IMR.csv
Single calculation per file with components and final rate

### PNG Visualizations (graphs/ folder)

| File | Description | Dimensions |
|------|-------------|-----------|
| 01_births_by_type.png | Birth type distribution (single/multiple) | 800×600 |
| 02_age_distribution.png | Age histogram of household members | 800×600 |
| 03_gender_distribution.png | Gender composition bar chart | 800×600 |
| 04_deaths_by_year.png | Deaths across 2018-2020 | 800×600 |
| 05_age_at_death.png | Age distribution of deaths | 800×600 |
| 06_birth_order.png | Birth order distribution | 800×600 |
| 07_birth_outcomes.png | Living vs deceased births | 800×600 |
| 08_children_ever_born.png | Parity distribution | 800×600 |
| 09_population_pyramid.png | Age-sex population structure | 1000×700 |
| 10_births_vs_deaths.png | Births and deaths comparison 2018-2020 | 800×600 |

**Quality:** 100 dpi, suitable for reports and presentations

### SVM Model Files

#### best_svm_model.rds
Binary R object containing trained SVM model
```r
# Load and use
best_model <- readRDS("best_svm_model.rds")
new_predictions <- predict(best_model, new_data)
```

#### svm_model_comparison.csv
Performance comparison of 3 kernels:
- Model (Linear/Radial/Polynomial)
- Accuracy (%)
- F1-Score

#### svm_predictions_new.csv
Example predictions for 9 hypothetical individuals

---

## Advanced Features

### Custom Analysis

#### Calculate Age-Specific Mortality Rates (ASMR)

```r
# Similar to ASFR but for deaths
library(dplyr)
library(haven)

death <- as.data.frame(read_sav("Death.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))

hh_weights <- weights %>%
  group_by(HCODE) %>%
  summarise(HH_WEIGHT = first(Weight), .groups = "drop")

# Calculate ASMR by age group
asmr_data <- death %>%
  left_join(hh_weights, by = "HCODE") %>%
  filter(DEATH_YEAR == 2020) %>%
  mutate(age_group = cut(AGE_AT_DEATH, 
                         breaks = seq(0, 90, by = 5), 
                         right = FALSE)) %>%
  group_by(age_group) %>%
  summarise(deaths_weighted = sum(HH_WEIGHT, na.rm = TRUE))

# Get population by age group
pop_age <- weights %>%
  mutate(age_group = cut(AGE_IN_YEARS, 
                         breaks = seq(0, 90, by = 5), 
                         right = FALSE)) %>%
  group_by(age_group) %>%
  summarise(pop_weighted = sum(Weight, na.rm = TRUE))

# ASMR = (deaths/population) * 1000
asmr_results <- asmr_data %>%
  left_join(pop_age, by = "age_group") %>%
  mutate(asmr = (deaths_weighted / pop_weighted) * 1000)

print(asmr_results)
```

#### Gender-Stratified Indicators

```r
# Calculate CBR separately for males and females
cbr_by_gender <- birth %>%
  filter(BIRTH_YEAR_BI == 2020) %>%
  left_join(hh_weights, by = "HCODE") %>%
  left_join(weights %>% select(HCODE, ID_CODE, GENDER) %>% 
            rename(MOTHER_GENDER = GENDER),
            by = c("WOMEN_ID" = "ID_CODE", "HCODE" = "HCODE")) %>%
  group_by(MOTHER_GENDER) %>%
  summarise(births = sum(HH_WEIGHT, na.rm = TRUE))

# Similar for population by gender
pop_by_gender <- weights %>%
  group_by(GENDER) %>%
  summarise(population = sum(Weight, na.rm = TRUE))
```

#### Time Series Analysis

```r
# CBR trend 2018-2020
cbr_by_year <- birth %>%
  filter(BIRTH_YEAR_BI >= 2018, BIRTH_YEAR_BI <= 2020) %>%
  left_join(hh_weights, by = "HCODE") %>%
  group_by(BIRTH_YEAR_BI) %>%
  summarise(births = sum(HH_WEIGHT, na.rm = TRUE))

# Visualize trend
ggplot(cbr_by_year, aes(x = BIRTH_YEAR_BI, y = births)) +
  geom_line(size = 1) +
  geom_point(size = 3) +
  labs(title = "Birth Trend 2018-2020", x = "Year", y = "Births") +
  theme_minimal()
```

### Extend Machine Learning

#### Hyperparameter Tuning

```r
# Tune SVM cost parameter
library(e1071)

cost_values <- c(0.1, 0.5, 1, 5, 10)
accuracies <- numeric(length(cost_values))

for (i in seq_along(cost_values)) {
  model <- svm(LITERACY ~ AGE_IN_YEARS + GENDER + EDUCATION_LEVEL,
               data = train_data,
               kernel = "radial",
               cost = cost_values[i])
  
  predictions <- predict(model, test_data)
  accuracies[i] <- sum(predictions == test_data$LITERACY) / nrow(test_data)
}

# Find best cost
best_cost <- cost_values[which.max(accuracies)]
cat("Optimal cost:", best_cost, "\n")
```

#### Confusion Matrix Visualization

```r
# Create detailed confusion matrix
library(ggplot2)

predictions <- predict(best_model, test_data)

cm <- table(actual = test_data$LITERACY, predicted = predictions)

cm_df <- as.data.frame(as.table(cm))

ggplot(cm_df, aes(x = predicted, y = actual, fill = Freq)) +
  geom_tile() +
  geom_text(aes(label = Freq), vjust = 1) +
  scale_fill_gradient(low = "white", high = "steelblue") +
  labs(title = "Confusion Matrix", x = "Predicted", y = "Actual") +
  theme_minimal()
```

---

## Results & Visualizations

### Demographic Indicators Summary

All indicators calculated at the population level using survey weights:

```
┌─────────────────────────────────────────┐
│  DEMOGRAPHIC INDICATORS (2020 Data)    │
├──────────────────────────────┬──────────┤
│ Sex Ratio                    │ 102.57   │
│ Crude Birth Rate             │ 26.88    │
│ Crude Death Rate             │  6.67    │
│ General Fertility Rate       │111.80    │
│ Total Fertility Rate         │  3.685   │
│ Infant Mortality Rate        │ 55.75    │
└──────────────────────────────┴──────────┘
```

### Population Pyramid

Shows classic "pyramid" shape indicating:
- High proportion of children (0-15): 43%
- Young working-age population
- Few elderly (65+)
- Slightly male-skewed at young ages

### Fertility Patterns

- **Peak age:** 25-29 (209.34 per 1,000)
- **Secondary peak:** 20-24 (195+ per 1,000)
- **Low fertility:** 15-19 and 40-49 age groups
- **Pattern:** Concentrated in prime reproductive years

### Mortality by Age

- **Infant deaths:** Dominant cause of deaths < 5 years
- **Adult mortality:** Relatively low (young population)
- **Elderly:** Few deaths (small population)

---

## Troubleshooting

### Common Issues & Solutions

#### ❌ Error: "cannot open file 'Birth.sav'"

**Cause:** Working directory doesn't contain SPSS files

**Solution:**
```r
# Check current directory
getwd()

# List files to verify
list.files()

# Set correct directory
setwd("path/to/SPSS/data")
```

---

#### ❌ Error: "object 'hh_weights' not found"

**Cause:** Running code sections out of order

**Solution:**
- Run complete script from beginning: `source("PROJECT_COMPLETE_R_CODE.R")`
- Or ensure Section 2 completes before Section 3

---

#### ❌ Package installation fails

**Cause:** Missing system dependencies or network issues

**Solution:**
```r
# Try installing with dependencies
install.packages("package_name", dependencies = TRUE)

# For macOS: May need R tools
# Download from: https://mac.r-project.org/tools/

# For Windows: May need Rtools
# Download from: https://cran.r-project.org/bin/windows/Rtools/
```

---

#### ❌ PNG files not created

**Cause:** No write permissions or directory doesn't exist

**Solution:**
```r
# Create graphs directory
dir.create("graphs", showWarnings = FALSE)

# Check write permissions
file.create("test.txt")
file.remove("test.txt")

# Verify paths
getwd()
list.dirs()
```

---

#### ❌ SVM predicts only one class

**Cause:** Features not predictive or severe class imbalance

**Solution:**
```r
# Check data distribution
table(data_svm$LITERACY)
summary(data_svm[, c("AGE_IN_YEARS", "EDUCATION_LEVEL")])

# Verify no missing values
sum(is.na(data_svm))

# Try different kernel
svm_linear <- svm(..., kernel = "linear")  # May work better
```

---

### Getting Help

1. **Check Documentation Files:**
   - `PROJECT_CODE_GUIDE.md` - Detailed explanations
   - `PROJECT_CODE_INDEX.md` - Complete code reference

2. **Review Example Code:**
   - See "Usage" section above
   - Check inline comments in R script

3. **Verify Data Format:**
   - Ensure SPSS files are valid `.sav` format
   - Check for corrupted files: `haven::read_sav("file.sav")`

4. **Reproduce Example:**
   - Run script with provided sample data
   - Verify outputs match documentation

---

## Contributing

### How to Contribute

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourusername/pakistan-demographic-analysis.git
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Add new indicators or visualizations
   - Improve documentation
   - Fix bugs or optimize code

4. **Commit with clear messages**
   ```bash
   git commit -am "Add: New demographic indicator calculation"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Submit a Pull Request**
   - Describe changes clearly
   - Reference any related issues
   - Include test results

### Contribution Guidelines

- **Code Style:** Follow R tidyverse style guide
- **Documentation:** Add comments for complex code
- **Testing:** Verify changes with sample data
- **Validation:** Check mathematical accuracy
- **Performance:** Monitor memory usage for large operations

### Reporting Issues

Found a bug? Report it!

1. Check existing issues first
2. Provide:
   - Clear description of problem
   - Steps to reproduce
   - Expected vs. actual behavior
   - R version and OS
   - Error messages/screenshots

---

## License

This project is licensed under the **MIT License** - see LICENSE file for details.

### MIT License Summary

✅ **Permissions:**
- Commercial use
- Modification
- Distribution
- Private use

⚠️ **Conditions:**
- License and copyright notice required

❌ **Limitations:**
- No warranty or liability

---

## Contact

### Author & Maintainer

**Faisal**  
📧 Email: [your-email@example.com]  
🐙 GitHub: [@yourusername](https://github.com/yourusername)  
🏢 Organization: [Your Organization]  

### Support

- 📖 **Documentation:** See PROJECT_CODE_GUIDE.md
- 🐛 **Bug Reports:** Open an issue on GitHub
- 💡 **Feature Requests:** Discuss in Discussions
- 📧 **Questions:** Email or open a Discussion

### Acknowledgments

- **Data Source:** Pakistani Household Survey (2018-2020)
- **R Community:** haven, dplyr, ggplot2 developers
- **Methodology:** Standard demographic calculation procedures (UN, WHO)

---

## Citation

If you use this project in your research, please cite:

```bibtex
@software{faisal2026pakistan,
  title={Pakistani Household Demographic Analysis},
  author={Faisal},
  year={2026},
  url={https://github.com/yourusername/pakistan-demographic-analysis}
}
```

---

## Changelog

### Version 1.0 (July 2026)

**Initial Release:**
- ✅ 7 demographic indicators calculated
- ✅ 10 publication-ready visualizations
- ✅ 3 SVM classification models
- ✅ Complete documentation
- ✅ Reproducible analysis pipeline

---

## Additional Resources

### Learning Resources

- [R for Data Science](https://r4ds.had.co.nz/) - Hadley Wickham
- [Survey Analysis in R](https://www.un.org/en/development/desa/population/publications/) - UN Demographic Resources
- [SVM Tutorial](https://www.datacamp.com/community/tutorials/svm-classification-scikit-learn-python) - Support Vector Machines
- [Demographic Methods](https://www.un.org/en/development/desa/population/) - UN Methods

### Related Projects

- [Demographic Analysis Templates](https://github.com/...)
- [Survey Data Analysis](https://github.com/...)
- [R Visualization Gallery](https://www.r-graph-gallery.com/)

### Tools Used

- **R & RStudio** - Statistical computing and IDE
- **SPSS** - Original data format
- **GitHub** - Version control and collaboration
- **Markdown** - Documentation format

---


