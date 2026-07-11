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
