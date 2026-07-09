# ============================================================================
# SEX RATIO WITH WEIGHTS FROM WEIGHTS_ASSIGNED.SAV
# Roster.sav for gender, Weights_Assigned.sav for weights
# Formula: (Sum of Weights for Males / Sum of Weights for Females) * 100
# ============================================================================

library(haven)

cat("\n")
cat("SEX RATIO - ROSTER + WEIGHTS_ASSIGNED\n")

# STEP 1: READ FILES
cat("Step 1: Reading files...\n")
roster <- as.data.frame(read_sav("Roster.sav"))
weights_file <- as.data.frame(read_sav("Weights_Assigned.sav"))

cat("✓ Roster.sav:", nrow(roster), "rows\n")
cat("✓ Weights_Assigned.sav:", nrow(weights_file), "rows\n\n")

# STEP 2: FIND COLUMNS
cat("Step 2: Finding columns...\n")

# Find ID column to merge
id_col_roster <- grep("HCODE|HH_ID|ID", names(roster), ignore.case = TRUE)[1]
id_col_weights <- grep("HCODE|HH_ID|ID", names(weights_file), ignore.case = TRUE)[1]

if (is.na(id_col_roster) || is.na(id_col_weights)) {
  cat("Roster columns:", paste(names(roster), collapse = ", "), "\n")
  cat("Weights columns:", paste(names(weights_file), collapse = ", "), "\n")
  stop("Cannot find common ID column")
}

cat("✓ ID column in Roster:", names(roster)[id_col_roster], "\n")
cat("✓ ID column in Weights:", names(weights_file)[id_col_weights], "\n")

# Find gender column
gender_col <- grep("GENDER|SEX", names(roster), ignore.case = TRUE)[1]

if (is.na(gender_col)) {
  cat("ERROR: No gender column in Roster!\n")
  cat("Available columns:", paste(names(roster), collapse = ", "), "\n")
  stop("Cannot find GENDER or SEX column")
}

cat("✓ Gender column:", names(roster)[gender_col], "\n")

# Find weight column
weight_col <- grep("WEIGHT", names(weights_file), ignore.case = TRUE)[1]

if (is.na(weight_col)) {
  cat("ERROR: No weight column in Weights_Assigned!\n")
  cat("Available columns:", paste(names(weights_file), collapse = ", "), "\n")
  stop("Cannot find WEIGHT column")
}

cat("✓ Weight column:", names(weights_file)[weight_col], "\n\n")

# STEP 3: MERGE DATA
cat("Step 3: Merging Roster + Weights...\n")

data <- merge(roster, weights_file, 
              by.x = names(roster)[id_col_roster],
              by.y = names(weights_file)[id_col_weights],
              all.x = TRUE)

cat("✓ Merged data:", nrow(data), "rows\n\n")

# STEP 4: CLEAN DATA
cat("Step 4: Cleaning data...\n")

data <- data[!is.na(data[[gender_col]]), ]
data <- data[!is.na(data[[weight_col]]), ]

cat("✓ Valid rows:", nrow(data), "\n\n")

# STEP 5: CALCULATE WEIGHTED SUMS
cat("Step 5: Calculating weighted sums...\n")

# Males (gender = 1)
males_data <- data[data[[gender_col]] == 1, ]
weighted_males <- sum(males_data[[weight_col]], na.rm = TRUE)

# Females (gender = 2)
females_data <- data[data[[gender_col]] == 2, ]
weighted_females <- sum(females_data[[weight_col]], na.rm = TRUE)

cat("✓ Weighted Males:  ", round(weighted_males, 2), "\n")
cat("✓ Weighted Females:", round(weighted_females, 2), "\n\n")

# STEP 6: CALCULATE SEX RATIO
cat("Step 6: Calculating sex ratio...\n")

if (weighted_females > 0) {
  sex_ratio <- (weighted_males / weighted_females) * 100
} else {
  sex_ratio <- NA
}

# STEP 7: DISPLAY RESULTS
cat("\n")
cat("RESULTS\n")

cat("Formula: (Weighted Males / Weighted Females) × 100\n\n")

cat("Number of Male Rows:      ", nrow(males_data), "\n")
cat("Number of Female Rows:    ", nrow(females_data), "\n\n")

cat("Sum of Weights - Males:   ", round(weighted_males, 2), "\n")
cat("Sum of Weights - Females: ", round(weighted_females, 2), "\n\n")

cat("SEX RATIO = ", round(sex_ratio, 2), "\n\n")

if (!is.na(sex_ratio)) {
  cat("Interpretation:\n")
  cat("For every 100 females, there are ", round(sex_ratio, 2), " males\n\n")
}

# STEP 8: SAVE RESULT
result <- data.frame(
  Metric = c(
    "Number of Male Rows",
    "Number of Female Rows",
    "Sum of Weights - Males",
    "Sum of Weights - Females",
    "Sex Ratio (Weighted)"
  ),
  Value = c(
    nrow(males_data),
    nrow(females_data),
    round(weighted_males, 2),
    round(weighted_females, 2),
    round(sex_ratio, 2)
  )
)

write.csv(result, "sex_ratio_final.csv", row.names = FALSE)
cat("✓ Result saved to: sex_ratio_final.csv\n\n")

print(result)

cat("\n")


#Crude Birth Rate
library(haven)
library(dplyr)

birth   <- as.data.frame(read_sav("Birth.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))

hh_weight <- weights %>%
  group_by(HCODE) %>%
  summarise(HH_WEIGHT = first(Weight), .groups = "drop")

births_2020 <- birth %>%
  filter(BIRTH_YEAR_BI == 2020) %>%
  left_join(hh_weight, by = "HCODE") %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)

total_population <- sum(weights$Weight, na.rm = TRUE)

cbr_2020 <- (births_2020 / total_population) * 1000

cat("Total Weighted Births 2020 :", round(births_2020, 2), "\n")
cat("Total Weighted Population  :", round(total_population, 2), "\n")
cat("CBR 2020 =", round(cbr_2020, 2), "per 1000 population\n")

results <- data.frame(
  Metric = c("Total Weighted Births 2020", "Total Weighted Population", "Crude Birth Rate 2020 (per 1000)"),
  Value  = c(round(births_2020, 2), round(total_population, 2), round(cbr_2020, 2))
)
write.csv(results, "CBR_2020_standard.csv", row.names = FALSE)


#Gernral Fertility Rate
# ============================================================================
# GENERAL FERTILITY RATE (GFR) FOR 2020
#
# GFR = (Total Weighted Births in 2020 / Total Weighted Women aged 15-49) * 1000
#
# Numerator   : Birth.sav   -> BIRTH_YEAR_BI == 2020, weighted by Weight
# Denominator : Weights_Assigned.sav -> GENDER == 2 (Female) & AGE_IN_YEARS 15-49
# ============================================================================

library(haven)
library(dplyr)

# STEP 1: Read files
birth   <- as.data.frame(read_sav("Birth.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))

# STEP 2: One weight per household (weights file is at person level)
hh_weight <- weights %>%
  group_by(HCODE) %>%
  summarise(HH_WEIGHT = first(Weight), .groups = "drop")

# STEP 3: Total Weighted Births in 2020
births_2020 <- birth %>%
  filter(BIRTH_YEAR_BI == 2020) %>%
  left_join(hh_weight, by = "HCODE") %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)

# STEP 4: Total Weighted Women aged 15-49
women_15_49 <- weights %>%
  filter(GENDER == 2, AGE_IN_YEARS >= 15, AGE_IN_YEARS <= 49) %>%
  summarise(total = sum(Weight, na.rm = TRUE)) %>%
  pull(total)

# STEP 5: General Fertility Rate
gfr_2020 <- (births_2020 / women_15_49) * 1000

# STEP 6: Show results
cat("\n============= GENERAL FERTILITY RATE 2020 =============\n")
cat("Total Weighted Births 2020         :", format(round(births_2020, 2), big.mark = ","), "\n")
cat("Total Weighted Women aged 15-49    :", format(round(women_15_49, 2), big.mark = ","), "\n\n")
cat("GFR 2020 = (", round(births_2020, 2), "/", round(women_15_49, 2), ") x 1000\n")
cat("GFR 2020 =", round(gfr_2020, 2), "per 1000 women\n")
cat("=========================================================\n\n")

# STEP 7: Save results
results <- data.frame(
  Metric = c("Total Weighted Births 2020", "Total Weighted Women aged 15-49", "General Fertility Rate 2020 (per 1000)"),
  Value  = c(round(births_2020, 2), round(women_15_49, 2), round(gfr_2020, 2))
)

write.csv(results, "GFR_2020.csv", row.names = FALSE)
cat("Saved: GFR_2020.csv\n")


#Crude Death Year
library(haven)
library(dplyr)

death   <- as.data.frame(read_sav("Death.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))

hh_weight <- weights %>%
  group_by(HCODE) %>%
  summarise(HH_WEIGHT = first(Weight), .groups = "drop")

deaths_2020 <- death %>%
  filter(DEATH_YEAR == 2020) %>%
  left_join(hh_weight, by = "HCODE") %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)

total_population <- sum(weights$Weight, na.rm = TRUE)

cdr_2020 <- (deaths_2020 / total_population) * 1000

cat("Total Weighted Deaths 2020 :", round(deaths_2020, 2), "\n")
cat("Total Weighted Population  :", round(total_population, 2), "\n")
cat("CDR 2020 =", round(cdr_2020, 2), "per 1000 population\n")

results <- data.frame(
  Metric = c("Total Weighted Deaths 2020", "Total Weighted Population", "Crude Death Rate 2020 (per 1000)"),
  Value  = c(round(deaths_2020, 2), round(total_population, 2), round(cdr_2020, 2))
)
write.csv(results, "CDR_2020_standard.csv", row.names = FALSE)


#Age Specific Fertility Rate
library(haven)
library(dplyr)

# STEP 1: Read files
birth   <- as.data.frame(read_sav("Birth.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))

# STEP 2: One weight per household
hh_weight <- weights %>%
  group_by(HCODE) %>%
  summarise(HH_WEIGHT = first(Weight), .groups = "drop")

# STEP 3: Births in 2020 to women aged 20-24
births_20_24 <- birth %>%
  filter(BIRTH_YEAR_BI == 2020) %>%
  left_join(
    weights %>% select(HCODE, ID_CODE, AGE_IN_YEARS),
    by = c("HCODE" = "HCODE", "WOMEN_ID" = "ID_CODE")
  ) %>%
  left_join(hh_weight, by = "HCODE") %>%
  filter(AGE_IN_YEARS >= 20, AGE_IN_YEARS <= 24) %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)

# STEP 4: Total women aged 20-24 (denominator)
women_20_24 <- weights %>%
  filter(GENDER == 2, AGE_IN_YEARS >= 20, AGE_IN_YEARS <= 24) %>%
  summarise(total = sum(Weight, na.rm = TRUE)) %>%
  pull(total)

# STEP 5: ASFR for 20-24
asfr_20_24 <- (births_20_24 / women_20_24) * 1000

# STEP 6: Show results
cat("\n========== ASFR (20-24) FOR 2020 ==========\n")
cat("Weighted Births to women 20-24 :", round(births_20_24, 2), "\n")
cat("Weighted Women aged 20-24      :", round(women_20_24, 2), "\n\n")
cat("ASFR (20-24) =", round(asfr_20_24, 2), "per 1000 women\n")
cat("=============================================\n\n")

# STEP 7: Save results
results <- data.frame(
  Metric = c("Weighted Births (20-24)", "Weighted Women (20-24)", "ASFR 20-24 (per 1000)"),
  Value  = c(round(births_20_24, 2), round(women_20_24, 2), round(asfr_20_24, 2))
)
write.csv(results, "ASFR_20_24.csv", row.names = FALSE)


#Infant Morality Rate
# ============================================================================
# INFANT MORTALITY RATE (IMR) FOR 2020
#
# IMR = (Weighted Infant Deaths in 2020 / Weighted Live Births in 2020) * 1000
#
# Numerator   : Death.sav -> DEATH_YEAR == 2020 & AGE_AT_DEATH == 0, weighted by Weight
# Denominator : Birth.sav -> BIRTH_YEAR_BI == 2020, weighted by Weight
# ============================================================================

library(haven)
library(dplyr)

# STEP 1: Read files
birth   <- as.data.frame(read_sav("Birth.sav"))
death   <- as.data.frame(read_sav("Death.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))

# STEP 2: One weight per household (weights file is at person level)
hh_weight <- weights %>%
  group_by(HCODE) %>%
  summarise(HH_WEIGHT = first(Weight), .groups = "drop")

# STEP 3: Weighted Infant Deaths in 2020 (AGE_AT_DEATH == 0 means under 1 year)
infant_deaths_2020 <- death %>%
  filter(DEATH_YEAR == 2020, AGE_AT_DEATH == 0) %>%
  left_join(hh_weight, by = "HCODE") %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)

# STEP 4: Weighted Live Births in 2020
births_2020 <- birth %>%
  filter(BIRTH_YEAR_BI == 2020) %>%
  left_join(hh_weight, by = "HCODE") %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)

# STEP 5: Infant Mortality Rate
imr_2020 <- (infant_deaths_2020 / births_2020) * 1000

# STEP 6: Show results
cat("\n============= INFANT MORTALITY RATE 2020 =============\n")
cat("Weighted Infant Deaths (age 0) :", format(round(infant_deaths_2020, 2), big.mark = ","), "\n")
cat("Weighted Live Births            :", format(round(births_2020, 2), big.mark = ","), "\n\n")
cat("IMR 2020 = (", round(infant_deaths_2020, 2), "/", round(births_2020, 2), ") x 1000\n")
cat("IMR 2020 =", round(imr_2020, 2), "per 1000 live births\n")
cat("========================================================\n\n")

# STEP 7: Save results
results <- data.frame(
  Metric = c("Weighted Infant Deaths 2020 (age 0)", "Weighted Live Births 2020", "Infant Mortality Rate 2020 (per 1000)"),
  Value  = c(round(infant_deaths_2020, 2), round(births_2020, 2), round(imr_2020, 2))
)

write.csv(results, "IMR_2020.csv", row.names = FALSE)
cat("Saved: IMR_2020.csv\n")

# ASFR
# ============================================================================
# TOTAL FERTILITY RATE (TFR) FOR 2020
#
# TFR = 5 * SUM of ASFR (per woman, i.e. ASFR_per_1000 / 1000) across all age groups
#
# Steps:
#   1. Calculate ASFR for each 5-year age group (15-19, 20-24, ..., 45-49)
#   2. Sum all ASFR values (per 1000)
#   3. TFR = 5 * (Sum of ASFR / 1000)
# ============================================================================

library(haven)
library(dplyr)

# STEP 1: Read files
birth   <- as.data.frame(read_sav("Birth.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))

# STEP 2: One weight per household
hh_weight <- weights %>%
  group_by(HCODE) %>%
  summarise(HH_WEIGHT = first(Weight), .groups = "drop")

# STEP 3: Define age groups
age_breaks <- c(15, 20, 25, 30, 35, 40, 45, 50)
age_labels <- c("15-19","20-24","25-29","30-34","35-39","40-44","45-49")

# STEP 4: Births in 2020, linked to mother's age
births_2020 <- birth %>%
  filter(BIRTH_YEAR_BI == 2020) %>%
  left_join(
    weights %>% select(HCODE, ID_CODE, AGE_IN_YEARS),
    by = c("HCODE" = "HCODE", "WOMEN_ID" = "ID_CODE")
  ) %>%
  left_join(hh_weight, by = "HCODE") %>%
  mutate(AgeGroup = cut(AGE_IN_YEARS, breaks = age_breaks, labels = age_labels, right = FALSE))

births_by_age <- births_2020 %>%
  filter(!is.na(AgeGroup)) %>%
  group_by(AgeGroup) %>%
  summarise(Weighted_Births = sum(HH_WEIGHT, na.rm = TRUE), .groups = "drop")

# STEP 5: Total women by age group (denominator)
women_by_age <- weights %>%
  filter(GENDER == 2) %>%
  mutate(AgeGroup = cut(AGE_IN_YEARS, breaks = age_breaks, labels = age_labels, right = FALSE)) %>%
  filter(!is.na(AgeGroup)) %>%
  group_by(AgeGroup) %>%
  summarise(Weighted_Women = sum(Weight, na.rm = TRUE), .groups = "drop")

# STEP 6: Combine and calculate ASFR for each age group
asfr_table <- full_join(women_by_age, births_by_age, by = "AgeGroup") %>%
  mutate(
    AgeGroup = factor(AgeGroup, levels = age_labels),
    Weighted_Births = ifelse(is.na(Weighted_Births), 0, Weighted_Births),
    ASFR_per_1000 = round((Weighted_Births / Weighted_Women) * 1000, 2)
  ) %>%
  arrange(AgeGroup)

# STEP 7: Calculate Total Fertility Rate
sum_asfr <- sum(asfr_table$ASFR_per_1000, na.rm = TRUE)
tfr <- 5 * (sum_asfr / 1000)

# STEP 8: Show results
cat("\n================ AGE-SPECIFIC FERTILITY RATES 2020 ================\n\n")
print(asfr_table)

cat("\n================ TOTAL FERTILITY RATE 2020 ================\n\n")
cat("Sum of ASFR (per 1000) :", round(sum_asfr, 2), "\n")
cat("TFR = 5 x (", round(sum_asfr, 2), "/ 1000 )\n")
cat("TFR =", round(tfr, 3), "children per woman\n")
cat("=============================================================\n\n")

# STEP 9: Save results
write.csv(asfr_table, "ASFR_2020.csv", row.names = FALSE)

tfr_result <- data.frame(
  Metric = c("Sum of ASFR (per 1000)", "Total Fertility Rate (children per woman)"),
  Value  = c(round(sum_asfr, 2), round(tfr, 3))
)
write.csv(tfr_result, "TFR_2020.csv", row.names = FALSE)

cat("Saved: ASFR_2020.csv and TFR_2020.csv\n")



##IMR 2018-2020
# ============================================================================
# INFANT MORTALITY RATE (IMR) - BASED ON SPSS FORMULA
#
# IMR = Number of Infant Deaths / Total Number of Live Births × 1000
#
# Logic:
# 1. Include births from 2018-2020
# 2. Living babies (IS_ALIVE=1) → rate = 0 (no death)
# 3. Dead babies with survival >= 1 year → rate = 0 (not infant mortality)
# 4. Dead babies with survival < 1 year → rate = 1000 (infant death)
#    Identified by: MONTHS_BABY_LIVED (0-11) OR DAYS_BABY_LIVED (0-30)
# 5. Apply survey weights
# ============================================================================

library(haven)
library(dplyr)

# STEP 1: Read files
cat("Reading files...\n")
birth   <- as.data.frame(read_sav("Birth.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))

# STEP 2: Get household-level weight (one weight per HCODE)
hh_weight <- weights %>%
  group_by(HCODE) %>%
  slice(1) %>%
  select(HCODE, Weight) %>%
  rename(HH_WEIGHT = Weight)

cat("Total births:", nrow(birth), "\n")
cat("Total weights:", nrow(weights), "\n\n")

# STEP 3: Filter births from 2018-2020
births_filter <- birth %>%
  filter(BIRTH_YEAR_BI >= 2018, BIRTH_YEAR_BI <= 2020) %>%
  left_join(hh_weight, by = "HCODE")

cat("Births from 2018-2020:", nrow(births_filter), "\n")

# STEP 4: Create mortality indicator based on SPSS logic
# Rate = 0 if alive
# Rate = 0 if dead but lived >= 1 year
# Rate = 1000 if dead but lived < 1 year (infant death)

births_filter <- births_filter %>%
  mutate(
    IMR_Rate = case_when(
      # Condition 1: Baby is alive (IS_ALIVE = 1)
      IS_ALIVE == 1 ~ 0,
      
      # Condition 2: Baby is dead (IS_ALIVE = 2) but lived >= 1 year
      # (Either YEARS_BABY_LIVED >= 1 OR MONTHS_BABY_LIVED = 12)
      IS_ALIVE == 2 & (YEARS_BABY_LIVED >= 1 | MONTHS_BABY_LIVED == 12) ~ 0,
      
      # Condition 3: Baby is dead but lived < 1 year (INFANT DEATH)
      # Check if MONTHS_BABY_LIVED is between 0-11 OR DAYS_BABY_LIVED is between 0-30
      IS_ALIVE == 2 & (
        (MONTHS_BABY_LIVED > 0 & MONTHS_BABY_LIVED <= 11) |
          (DAYS_BABY_LIVED > 0 & DAYS_BABY_LIVED <= 30)
      ) ~ 1000,
      
      # Condition 4: Use DAYS_BABY_LIVED as fallback (if 0-30 days, it's an infant death)
      IS_ALIVE == 2 & (!is.na(DAYS_BABY_LIVED)) & (DAYS_BABY_LIVED >= 0 & DAYS_BABY_LIVED <= 30) ~ 1000,
      
      # Default: not an infant death
      TRUE ~ 0
    )
  )

# STEP 5: Summary of records
alive_count <- sum(births_filter$IS_ALIVE == 1, na.rm = TRUE)
dead_count <- sum(births_filter$IS_ALIVE == 2, na.rm = TRUE)
infant_death_count <- sum(births_filter$IMR_Rate == 1000, na.rm = TRUE)

cat("Alive babies:", alive_count, "\n")
cat("Dead babies:", dead_count, "\n")
cat("Infant deaths (under 1 year):", infant_death_count, "\n\n")

# STEP 6: Calculate weighted IMR
# Total weighted infant deaths
weighted_infant_deaths <- sum(births_filter$HH_WEIGHT * (births_filter$IMR_Rate == 1000), na.rm = TRUE)

# Total weighted births
total_weighted_births <- sum(births_filter$HH_WEIGHT, na.rm = TRUE)

# IMR calculation
imr <- (weighted_infant_deaths / total_weighted_births) * 1000

cat("Total Weighted Births (2018-2020):", format(round(total_weighted_births, 2), big.mark = ","), "\n")
cat("Total Weighted Infant Deaths:", format(round(weighted_infant_deaths, 2), big.mark = ","), "\n\n")

cat("IMR = (", format(round(weighted_infant_deaths, 2), big.mark = ","), " / ", 
    format(round(total_weighted_births, 2), big.mark = ","), ") × 1000\n")
cat("IMR =", round(imr, 2), "per 1000 live births\n")

# STEP 8: Save results
results <- data.frame(
  Metric = c(
    "Study Period",
    "Total Weighted Births",
    "Total Weighted Infant Deaths",
    "Infant Mortality Rate (per 1000)"
  ),
  Value = c(
    "2018-2020",
    round(total_weighted_births, 2),
    round(weighted_infant_deaths, 2),
    round(imr, 2)
  )
)

write.csv(results, "IMR_2018_2020.csv", row.names = FALSE)
cat("Results saved to: IMR_2018_2020.csv\n")
print(results)


##ASFR 2018-2020
library(haven)
library(dplyr)

birth   <- as.data.frame(read_sav("Birth.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))

hh_weight <- weights %>%
  group_by(HCODE) %>%
  summarise(HH_WEIGHT = first(Weight), .groups = "drop")

age_breaks <- c(15, 20, 25, 30, 35, 40, 45, 50)
age_labels <- c("15-19","20-24","25-29","30-34","35-39","40-44","45-49")

births_filtered <- birth %>%
  filter(BIRTH_YEAR_BI >= 2018, BIRTH_YEAR_BI <= 2020) %>%
  left_join(
    weights %>% select(HCODE, ID_CODE, AGE_IN_YEARS),
    by = c("HCODE" = "HCODE", "WOMEN_ID" = "ID_CODE")
  ) %>%
  left_join(hh_weight, by = "HCODE") %>%
  mutate(AgeGroup = cut(AGE_IN_YEARS, breaks = age_breaks, labels = age_labels, right = FALSE))

n_years <- 3   # 2018, 2019, 2020

births_by_age <- births_filtered %>%
  filter(!is.na(AgeGroup)) %>%
  group_by(AgeGroup) %>%
  summarise(Weighted_Births = sum(HH_WEIGHT, na.rm = TRUE) / n_years, .groups = "drop")

women_by_age <- weights %>%
  filter(GENDER == 2) %>%
  mutate(AgeGroup = cut(AGE_IN_YEARS, breaks = age_breaks, labels = age_labels, right = FALSE)) %>%
  filter(!is.na(AgeGroup)) %>%
  group_by(AgeGroup) %>%
  summarise(Weighted_Women = sum(Weight, na.rm = TRUE), .groups = "drop")

asfr_table <- full_join(women_by_age, births_by_age, by = "AgeGroup") %>%
  mutate(
    AgeGroup = factor(AgeGroup, levels = age_labels),
    Weighted_Births = ifelse(is.na(Weighted_Births), 0, Weighted_Births),
    ASFR_per_1000 = round((Weighted_Births / Weighted_Women) * 1000, 2)
  ) %>%
  arrange(AgeGroup)

sum_asfr <- sum(asfr_table$ASFR_per_1000, na.rm = TRUE)
tfr <- 5 * (sum_asfr / 1000)

cat("TFR (2018-2020) =", round(tfr, 3), "children per woman\n")

write.csv(asfr_table, "ASFR_2018_2020.csv", row.names = FALSE)