library(haven)

cat("\n")
cat("SEX RATIO - ROSTER + WEIGHTS_ASSIGNED\n")
cat("Step 1: Reading files...\n")
roster <- as.data.frame(read_sav("Roster.sav"))
weights_file <- as.data.frame(read_sav("Weights_Assigned.sav"))

cat("b Roster.sav:", nrow(roster), "rows\n")
cat("b Weights_Assigned.sav:", nrow(weights_file), "rows\n\n")
cat("Step 2: Finding columns...\n")
id_col_roster <- grep("HCODE|HH_ID|ID", names(roster), ignore.case = TRUE)[1]
id_col_weights <- grep("HCODE|HH_ID|ID", names(weights_file), ignore.case = TRUE)[1]

if (is.na(id_col_roster) || is.na(id_col_weights)) {
  cat("Roster columns:", paste(names(roster), collapse = ", "), "\n")
  cat("Weights columns:", paste(names(weights_file), collapse = ", "), "\n")
  stop("Cannot find common ID column")
}
cat("b ID column in Roster:", names(roster)[id_col_roster], "\n")
cat("b ID column in Weights:", names(weights_file)[id_col_weights], "\n")
gender_col <- grep("GENDER|SEX", names(roster), ignore.case = TRUE)[1]

if (is.na(gender_col)) {
  cat("ERROR: No gender column in Roster!\n")
  cat("Available columns:", paste(names(roster), collapse = ", "), "\n")
  stop("Cannot find GENDER or SEX column")
}

cat("b Gender column:", names(roster)[gender_col], "\n")
weight_col <- grep("WEIGHT", names(weights_file), ignore.case = TRUE)[1]

if (is.na(weight_col)) {
  cat("ERROR: No weight column in Weights_Assigned!\n")
  cat("Available columns:", paste(names(weights_file), collapse = ", "), "\n")
  stop("Cannot find WEIGHT column")
}
cat("b Weight column:", names(weights_file)[weight_col], "\n\n")
cat("Step 3: Merging Roster + Weights...\n")

data <- merge(roster, weights_file, 
              by.x = names(roster)[id_col_roster],
              by.y = names(weights_file)[id_col_weights],
              all.x = TRUE)

cat("b Merged data:", nrow(data), "rows\n\n")
cat("Step 4: Cleaning data...\n")

data <- data[!is.na(data[[gender_col]]), ]
data <- data[!is.na(data[[weight_col]]), ]

cat("b Valid rows:", nrow(data), "\n\n")
cat("Step 5: Calculating weighted sums...\n")
males_data <- data[data[[gender_col]] == 1, ]
weighted_males <- sum(males_data[[weight_col]], na.rm = TRUE)
females_data <- data[data[[gender_col]] == 2, ]
weighted_females <- sum(females_data[[weight_col]], na.rm = TRUE)

cat("b Weighted Males:  ", round(weighted_males, 2), "\n")
cat("b Weighted Females:", round(weighted_females, 2), "\n\n")

cat("Step 6: Calculating sex ratio...\n")
if (weighted_females > 0) {
  sex_ratio <- (weighted_males / weighted_females) * 100
} else {
  sex_ratio <- NA
}

cat("\n")
cat("RESULTS\n")

cat("Formula: (Weighted Males / Weighted Females) C 100\n\n")

cat("Number of Male Rows:      ", nrow(males_data), "\n")
cat("Number of Female Rows:    ", nrow(females_data), "\n\n")

cat("Sum of Weights - Males:   ", round(weighted_males, 2), "\n")
cat("Sum of Weights - Females: ", round(weighted_females, 2), "\n\n")

cat("SEX RATIO = ", round(sex_ratio, 2), "\n\n")

if (!is.na(sex_ratio)) {
  cat("Interpretation:\n")
  cat("For every 100 females, there are ", round(sex_ratio, 2), " males\n\n")
}
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
cat("b Result saved to: sex_ratio_final.csv\n\n")

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
women_15_49 <- weights %>%
  filter(GENDER == 2, AGE_IN_YEARS >= 15, AGE_IN_YEARS <= 49) %>%
  summarise(total = sum(Weight, na.rm = TRUE)) %>%
  pull(total)
gfr_2020 <- (births_2020 / women_15_49) * 1000

cat("\n============= GENERAL FERTILITY RATE 2020 =============\n")
cat("Total Weighted Births 2020         :", format(round(births_2020, 2), big.mark = ","), "\n")
cat("Total Weighted Women aged 15-49    :", format(round(women_15_49, 2), big.mark = ","), "\n\n")
cat("GFR 2020 = (", round(births_2020, 2), "/", round(women_15_49, 2), ") x 1000\n")
cat("GFR 2020 =", round(gfr_2020, 2), "per 1000 women\n")
cat("=========================================================\n\n")

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
birth   <- as.data.frame(read_sav("Birth.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))
hh_weight <- weights %>%
  group_by(HCODE) %>%
  summarise(HH_WEIGHT = first(Weight), .groups = "drop")
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
women_20_24 <- weights %>%
  filter(GENDER == 2, AGE_IN_YEARS >= 20, AGE_IN_YEARS <= 24) %>%
  summarise(total = sum(Weight, na.rm = TRUE)) %>%
  pull(total)
asfr_20_24 <- (births_20_24 / women_20_24) * 1000
cat("\n========== ASFR (20-24) FOR 2020 ==========\n")
cat("Weighted Births to women 20-24 :", round(births_20_24, 2), "\n")
cat("Weighted Women aged 20-24      :", round(women_20_24, 2), "\n\n")
cat("ASFR (20-24) =", round(asfr_20_24, 2), "per 1000 women\n")
cat("=============================================\n\n")

results <- data.frame(
  Metric = c("Weighted Births (20-24)", "Weighted Women (20-24)", "ASFR 20-24 (per 1000)"),
  Value  = c(round(births_20_24, 2), round(women_20_24, 2), round(asfr_20_24, 2))
)
write.csv(results, "ASFR_20_24.csv", row.names = FALSE)




#Infant Morality Rate
library(haven)
library(dplyr)

birth   <- as.data.frame(read_sav("Birth.sav"))
death   <- as.data.frame(read_sav("Death.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))
hh_weight <- weights %>%
  group_by(HCODE) %>%
  summarise(HH_WEIGHT = first(Weight), .groups = "drop")
infant_deaths_2020 <- death %>%
  filter(DEATH_YEAR == 2020, AGE_AT_DEATH == 0) %>%
  left_join(hh_weight, by = "HCODE") %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)
births_2020 <- birth %>%
  filter(BIRTH_YEAR_BI == 2020) %>%
  left_join(hh_weight, by = "HCODE") %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)
imr_2020 <- (infant_deaths_2020 / births_2020) * 1000
cat("\n============= INFANT MORTALITY RATE 2020 =============\n")
cat("Weighted Infant Deaths (age 0) :", format(round(infant_deaths_2020, 2), big.mark = ","), "\n")
cat("Weighted Live Births            :", format(round(births_2020, 2), big.mark = ","), "\n\n")
cat("IMR 2020 = (", round(infant_deaths_2020, 2), "/", round(births_2020, 2), ") x 1000\n")
cat("IMR 2020 =", round(imr_2020, 2), "per 1000 live births\n")
cat("========================================================\n\n")
results <- data.frame(
  Metric = c("Weighted Infant Deaths 2020 (age 0)", "Weighted Live Births 2020", "Infant Mortality Rate 2020 (per 1000)"),
  Value  = c(round(infant_deaths_2020, 2), round(births_2020, 2), round(imr_2020, 2))
)
write.csv(results, "IMR_2020.csv", row.names = FALSE)
cat("Saved: IMR_2020.csv\n")



# ASFR
library(haven)
library(dplyr)
birth   <- as.data.frame(read_sav("Birth.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))
hh_weight <- weights %>%
  group_by(HCODE) %>%
  summarise(HH_WEIGHT = first(Weight), .groups = "drop")
age_breaks <- c(15, 20, 25, 30, 35, 40, 45, 50)
age_labels <- c("15-19","20-24","25-29","30-34","35-39","40-44","45-49")
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
cat("\n================ AGE-SPECIFIC FERTILITY RATES 2020 ================\n\n")
print(asfr_table)

cat("\n================ TOTAL FERTILITY RATE 2020 ================\n\n")
cat("Sum of ASFR (per 1000) :", round(sum_asfr, 2), "\n")
cat("TFR = 5 x (", round(sum_asfr, 2), "/ 1000 )\n")
cat("TFR =", round(tfr, 3), "children per woman\n")
cat("=============================================================\n\n")
write.csv(asfr_table, "ASFR_2020.csv", row.names = FALSE)
tfr_result <- data.frame(
  Metric = c("Sum of ASFR (per 1000)", "Total Fertility Rate (children per woman)"),
  Value  = c(round(sum_asfr, 2), round(tfr, 3))
)
write.csv(tfr_result, "TFR_2020.csv", row.names = FALSE)
cat("Saved: ASFR_2020.csv and TFR_2020.csv\n")




##IMR 2018-2020
library(haven)
library(dplyr)
cat("Reading files...\n")
birth   <- as.data.frame(read_sav("Birth.sav"))
weights <- as.data.frame(read_sav("Weights_Assigned.sav"))
hh_weight <- weights %>%
  group_by(HCODE) %>%
  slice(1) %>%
  select(HCODE, Weight) %>%
  rename(HH_WEIGHT = Weight)

cat("Total births:", nrow(birth), "\n")
cat("Total weights:", nrow(weights), "\n\n")
births_filter <- birth %>%
  filter(BIRTH_YEAR_BI >= 2018, BIRTH_YEAR_BI <= 2020) %>%
  left_join(hh_weight, by = "HCODE")

cat("Births from 2018-2020:", nrow(births_filter), "\n")
births_filter <- births_filter %>%
  mutate(
    IMR_Rate = case_when(
      IS_ALIVE == 1 ~ 0,
      
      IS_ALIVE == 2 & (YEARS_BABY_LIVED >= 1 | MONTHS_BABY_LIVED == 12) ~ 0,
      
      IS_ALIVE == 2 & (
        (MONTHS_BABY_LIVED > 0 & MONTHS_BABY_LIVED <= 11) |
          (DAYS_BABY_LIVED > 0 & DAYS_BABY_LIVED <= 30)
      ) ~ 1000,
      IS_ALIVE == 2 & (!is.na(DAYS_BABY_LIVED)) & (DAYS_BABY_LIVED >= 0 & DAYS_BABY_LIVED <= 30) ~ 1000,
      TRUE ~ 0
    )
  )
alive_count <- sum(births_filter$IS_ALIVE == 1, na.rm = TRUE)
dead_count <- sum(births_filter$IS_ALIVE == 2, na.rm = TRUE)
infant_death_count <- sum(births_filter$IMR_Rate == 1000, na.rm = TRUE)

cat("Alive babies:", alive_count, "\n")
cat("Dead babies:", dead_count, "\n")
cat("Infant deaths (under 1 year):", infant_death_count, "\n\n")
weighted_infant_deaths <- sum(births_filter$HH_WEIGHT * (births_filter$IMR_Rate == 1000), na.rm = TRUE)
total_weighted_births <- sum(births_filter$HH_WEIGHT, na.rm = TRUE)
imr <- (weighted_infant_deaths / total_weighted_births) * 1000

cat("Total Weighted Births (2018-2020):", format(round(total_weighted_births, 2), big.mark = ","), "\n")
cat("Total Weighted Infant Deaths:", format(round(weighted_infant_deaths, 2), big.mark = ","), "\n\n")
cat("IMR = (", format(round(weighted_infant_deaths, 2), big.mark = ","), " / ", 
    format(round(total_weighted_births, 2), big.mark = ","), ") C 1000\n")
cat("IMR =", round(imr, 2), "per 1000 live births\n")
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