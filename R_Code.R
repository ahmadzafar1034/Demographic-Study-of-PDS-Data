
library(haven)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(knitr)
library(kableExtra)
library(readr)
library(e1071)

cat("\n========== SECTION 1: LOADING DATA ==========\n")
birth    <- as.data.frame(read_sav("Birth.sav"))
death    <- as.data.frame(read_sav("Death.sav"))
weights  <- as.data.frame(read_sav("Weights_Assigned.sav"))
roster   <- as.data.frame(read_sav("Roster.sav"))
fertility <- as.data.frame(read_sav("Fertility.sav"))
explore_data <- function(df_name, df) {
  cat("\n========== ", df_name, " ==========\n")
  cat("Dimensions:", nrow(df), "rows,", ncol(df), "columns\n")
  cat("Variables:\n")
  print(str(df))
  cat("Summary:\n")
  print(summary(df))
}
explore_data("BIRTH DATA", birth)
explore_data("DEATH DATA", death)
explore_data("WEIGHTS DATA", weights)
explore_data("ROSTER DATA", roster)
explore_data("FERTILITY DATA", fertility)

cat("\n========== SECTION 2: PREPARE WEIGHTS ==========\n")
hh_weights <- weights %>%
  group_by(HCODE) %>%
  summarise(HH_WEIGHT = first(Weight), .groups = "drop")

cat("Household weights created:", nrow(hh_weights), "households\n")

cat("\n========== SECTION 3: DEMOGRAPHIC INDICATORS ==========\n")
cat("\n--- 3.1 SEX RATIO ---\n")
sex_ratio <- weights %>%
  group_by(GENDER) %>%
  summarise(total_weight = sum(Weight, na.rm = TRUE), .groups = "drop")

male_weight <- sex_ratio %>% filter(GENDER == 1) %>% pull(total_weight)
female_weight <- sex_ratio %>% filter(GENDER == 2) %>% pull(total_weight)
sex_ratio_value <- (male_weight / female_weight) * 100
cat("Males (weighted):", round(male_weight, 2), "\n")
cat("Females (weighted):", round(female_weight, 2), "\n")
cat("Sex Ratio (Males per 100 Females):", round(sex_ratio_value, 2), "\n")
sex_ratio_df <- data.frame(
  Metric = c("Males (Weighted)", "Females (Weighted)", "Sex Ratio"),
  Value = c(round(male_weight, 2), round(female_weight, 2), round(sex_ratio_value, 2))
)
write_csv(sex_ratio_df, "sex_ratio_weighted.csv")

cat("\n--- 3.2 CRUDE BIRTH RATE (CBR) 2020 ---\n")
births_2020 <- birth %>%
  filter(BIRTH_YEAR_BI == 2020) %>%
  left_join(hh_weights, by = "HCODE") %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)
total_population <- sum(weights$Weight, na.rm = TRUE)

cbr_2020 <- (births_2020 / total_population) * 1000
cat("Total weighted births 2020:", round(births_2020, 2), "\n")
cat("Total weighted population:", round(total_population, 2), "\n")
cat("CBR 2020:", round(cbr_2020, 2), "per 1,000\n")
cbr_df <- data.frame(
  Metric = c("Births 2020", "Population", "CBR"),
  Value = c(round(births_2020, 2), round(total_population, 2), round(cbr_2020, 2))
)
write_csv(cbr_df, "CBR_2020.csv")



# 3.3 CRUDE DEATH RATE (CDR) 2020
cat("\n--- 3.3 CRUDE DEATH RATE (CDR) 2020 ---\n")

deaths_2020 <- death %>%
  filter(DEATH_YEAR == 2020) %>%
  left_join(hh_weights, by = "HCODE") %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)
cdr_2020 <- (deaths_2020 / total_population) * 1000
cat("Total weighted deaths 2020:", round(deaths_2020, 2), "\n")
cat("CDR 2020:", round(cdr_2020, 2), "per 1,000\n")
cdr_df <- data.frame(
  Metric = c("Deaths 2020", "Population", "CDR"),
  Value = c(round(deaths_2020, 2), round(total_population, 2), round(cdr_2020, 2))
)
write_csv(cdr_df, "CDR_2020.csv")



# 3.4 GENERAL FERTILITY RATE (GFR)
cat("\n--- 3.4 GENERAL FERTILITY RATE (GFR) ---\n")
total_births <- birth %>%
  left_join(hh_weights, by = "HCODE") %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)
women_15_49 <- weights %>%
  filter(GENDER == 2, AGE_IN_YEARS >= 15, AGE_IN_YEARS <= 49) %>%
  summarise(total = sum(Weight, na.rm = TRUE)) %>%
  pull(total)
gfr <- (total_births / women_15_49) * 1000
cat("Total births (weighted):", round(total_births, 2), "\n")
cat("Women 15-49 (weighted):", round(women_15_49, 2), "\n")
cat("GFR:", round(gfr, 2), "per 1,000 women\n")
gfr_df <- data.frame(
  Metric = c("Births", "Women 15-49", "GFR"),
  Value = c(round(total_births, 2), round(women_15_49, 2), round(gfr, 2))
)
write_csv(gfr_df, "GFR.csv")



# 3.5 AGE-SPECIFIC FERTILITY RATES (ASFR)
cat("\n--- 3.5 AGE-SPECIFIC FERTILITY RATES (ASFR) ---\n")
asfr_data <- birth %>%
  left_join(weights %>% select(ID_CODE, HCODE, AGE_IN_YEARS) %>% 
            rename(MOTHER_AGE = AGE_IN_YEARS),
            by = c("WOMEN_ID" = "ID_CODE", "HCODE" = "HCODE")) %>%
  left_join(hh_weights, by = "HCODE")
asfr_data <- asfr_data %>%
  mutate(age_group = cut(MOTHER_AGE, 
                         breaks = seq(15, 50, by = 5), 
                         right = FALSE))
asfr_results <- asfr_data %>%
  group_by(age_group) %>%
  summarise(
    births_weighted = sum(HH_WEIGHT, na.rm = TRUE),
    .groups = "drop"
  )
women_age_groups <- weights %>%
  filter(GENDER == 2, AGE_IN_YEARS >= 15, AGE_IN_YEARS <= 49) %>%
  mutate(age_group = cut(AGE_IN_YEARS, 
                         breaks = seq(15, 50, by = 5), 
                         right = FALSE)) %>%
  group_by(age_group) %>%
  summarise(women_weighted = sum(Weight, na.rm = TRUE), .groups = "drop")
asfr_results <- asfr_results %>%
  left_join(women_age_groups, by = "age_group") %>%
  mutate(asfr = (births_weighted / women_weighted) * 1000)

cat("ASFR by Age Group (per 1,000 women):\n")
print(asfr_results)
write_csv(asfr_results, "ASFR_all_groups.csv")



# 3.6 TOTAL FERTILITY RATE (TFR)
cat("\n--- 3.6 TOTAL FERTILITY RATE (TFR) ---\n")
tfr <- sum(asfr_results$asfr, na.rm = TRUE) / 1000 * 5
cat("TFR (Total Fertility Rate):", round(tfr, 3), "children per woman\n")
tfr_df <- data.frame(
  Metric = "TFR",
  Value = round(tfr, 3)
)
write_csv(tfr_df, "TFR.csv")


# 3.7 INFANT MORTALITY RATE (IMR)
cat("\n--- 3.7 INFANT MORTALITY RATE (IMR) ---\n")
births_reference <- birth %>%
  filter(BIRTH_YEAR_BI >= 2018, BIRTH_YEAR_BI <= 2020) %>%
  left_join(hh_weights, by = "HCODE") %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)
infant_deaths <- birth %>%
  filter(BIRTH_YEAR_BI >= 2018, BIRTH_YEAR_BI <= 2020) %>%
  filter(IS_ALIVE == 2) %>%  # Dead
  left_join(hh_weights, by = "HCODE") %>%
  summarise(total = sum(HH_WEIGHT, na.rm = TRUE)) %>%
  pull(total)
imr <- (infant_deaths / births_reference) * 1000
cat("Births 2018-2020 (reference period):", round(births_reference, 2), "\n")
cat("Infant deaths:", round(infant_deaths, 2), "\n")
cat("IMR:", round(imr, 2), "per 1,000 live births\n")
imr_df <- data.frame(
  Metric = c("Births 2018-2020", "Infant Deaths", "IMR"),
  Value = c(round(births_reference, 2), round(infant_deaths, 2), round(imr, 2))
)
write_csv(imr_df, "IMR.csv")


# SECTION 4: VISUALIZATION SUITE
cat("\n========== SECTION 4: CREATING VISUALIZATIONS ==========\n")
dir.create("graphs", showWarnings = FALSE)

# 4.1 Births by Type
png("graphs/01_births_by_type.png", width = 800, height = 600, res = 100)
birth_type_plot <- birth %>%
  group_by(BIRTH_TYPE) %>%
  summarise(count = n(), .groups = "drop") %>%
  ggplot(aes(x = factor(BIRTH_TYPE), y = count, fill = factor(BIRTH_TYPE))) +
  geom_bar(stat = "identity") +
  labs(title = "Distribution of Birth Types",
       x = "Birth Type", y = "Count") +
  theme_minimal() +
  theme(legend.position = "none")
print(birth_type_plot)
dev.off()



# 4.2 Age Distribution (Roster)
png("graphs/02_age_distribution.png", width = 800, height = 600, res = 100)
age_plot <- roster %>%
  filter(!is.na(AGE_IN_YEARS)) %>%
  ggplot(aes(x = AGE_IN_YEARS)) +
  geom_histogram(bins = 30, fill = "#667eea", alpha = 0.7) +
  labs(title = "Age Distribution of Household Members",
       x = "Age (years)", y = "Frequency") +
  theme_minimal()
print(age_plot)
dev.off()



# 4.3 Gender Distribution (Roster)
png("graphs/03_gender_distribution.png", width = 800, height = 600, res = 100)
gender_plot <- roster %>%
  group_by(GENDER) %>%
  summarise(count = n(), .groups = "drop") %>%
  ggplot(aes(x = factor(GENDER), y = count, fill = factor(GENDER))) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("1" = "#3498db", "2" = "#e74c3c"),
                    labels = c("1" = "Male", "2" = "Female")) +
  labs(title = "Gender Distribution",
       x = "Gender", y = "Count", fill = "Gender") +
  theme_minimal()
print(gender_plot)
dev.off()



# 4.4 Deaths by Year
png("graphs/04_deaths_by_year.png", width = 800, height = 600, res = 100)
death_year_plot <- death %>%
  group_by(DEATH_YEAR) %>%
  summarise(count = n(), .groups = "drop") %>%
  ggplot(aes(x = factor(DEATH_YEAR), y = count, fill = factor(DEATH_YEAR))) +
  geom_bar(stat = "identity") +
  labs(title = "Deaths by Year",
       x = "Year", y = "Count") +
  theme_minimal() +
  theme(legend.position = "none")
print(death_year_plot)
dev.off()



# 4.5 Age at Death Distribution
png("graphs/05_age_at_death.png", width = 800, height = 600, res = 100)
age_death_plot <- death %>%
  filter(!is.na(AGE_AT_DEATH)) %>%
  ggplot(aes(x = AGE_AT_DEATH)) +
  geom_histogram(bins = 30, fill = "#e74c3c", alpha = 0.7) +
  labs(title = "Age at Death Distribution",
       x = "Age (years)", y = "Frequency") +
  theme_minimal()
print(age_death_plot)
dev.off()



# 4.6 Birth Order Distribution
png("graphs/06_birth_order.png", width = 800, height = 600, res = 100)
birth_order_plot <- birth %>%
  filter(!is.na(BIRTH_ORDER)) %>%
  group_by(BIRTH_ORDER) %>%
  summarise(count = n(), .groups = "drop") %>%
  ggplot(aes(x = factor(BIRTH_ORDER), y = count, fill = factor(BIRTH_ORDER))) +
  geom_bar(stat = "identity") +
  labs(title = "Distribution of Birth Order",
       x = "Birth Order", y = "Count") +
  theme_minimal() +
  theme(legend.position = "none")
print(birth_order_plot)
dev.off()



# 4.7 Birth Outcomes (Living vs Deceased)
png("graphs/07_birth_outcomes.png", width = 800, height = 600, res = 100)
birth_outcomes_plot <- birth %>%
  group_by(IS_ALIVE) %>%
  summarise(count = n(), .groups = "drop") %>%
  ggplot(aes(x = factor(IS_ALIVE), y = count, fill = factor(IS_ALIVE))) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("1" = "#2ecc71", "2" = "#e74c3c"),
                    labels = c("1" = "Living", "2" = "Deceased")) +
  labs(title = "Birth Outcomes: Living vs Deceased",
       x = "Status", y = "Count", fill = "Status") +
  theme_minimal()
print(birth_outcomes_plot)
dev.off()



# 4.8 Total Children Ever Born (Fertility)
png("graphs/08_children_ever_born.png", width = 800, height = 600, res = 100)
if ("TOTAL_CHILDREN_EVER_BORN" %in% names(fertility)) {
  children_plot <- fertility %>%
    filter(!is.na(TOTAL_CHILDREN_EVER_BORN)) %>%
    ggplot(aes(x = TOTAL_CHILDREN_EVER_BORN)) +
    geom_histogram(bins = 15, fill = "#9b59b6", alpha = 0.7) +
    labs(title = "Total Children Ever Born",
         x = "Number of Children", y = "Count") +
    theme_minimal()
  print(children_plot)
}
dev.off()



# 4.9 Population Pyramid
png("graphs/09_population_pyramid.png", width = 1000, height = 700, res = 100)
pyramid_data <- roster %>%
  filter(!is.na(AGE_IN_YEARS)) %>%
  mutate(age_group = cut(AGE_IN_YEARS, 
                         breaks = seq(0, 80, by = 5), 
                         right = FALSE)) %>%
  group_by(age_group, GENDER) %>%
  summarise(count = n(), .groups = "drop") %>%
  mutate(count = ifelse(GENDER == 1, count, -count))

pyramid_plot <- pyramid_data %>%
  ggplot(aes(x = age_group, y = count, fill = factor(GENDER))) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_fill_manual(values = c("1" = "#3498db", "2" = "#e74c3c"),
                    labels = c("1" = "Male", "2" = "Female")) +
  labs(title = "Population Pyramid",
       x = "Age Group", y = "Count", fill = "Gender") +
  theme_minimal()
print(pyramid_plot)
dev.off()



# 4.10 Births vs Deaths Comparison
png("graphs/10_births_vs_deaths.png", width = 800, height = 600, res = 100)
comparison_data <- data.frame(
  Year = c(2018, 2019, 2020),
  Births = c(
    nrow(birth %>% filter(BIRTH_YEAR_BI == 2018)),
    nrow(birth %>% filter(BIRTH_YEAR_BI == 2019)),
    nrow(birth %>% filter(BIRTH_YEAR_BI == 2020))
  ),
  Deaths = c(
    nrow(death %>% filter(DEATH_YEAR == 2018)),
    nrow(death %>% filter(DEATH_YEAR == 2019)),
    nrow(death %>% filter(DEATH_YEAR == 2020))
  )
)
comparison_plot <- comparison_data %>%
  tidyr::pivot_longer(cols = c("Births", "Deaths"), names_to = "Type", values_to = "Count") %>%
  ggplot(aes(x = factor(Year), y = Count, fill = Type)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Births vs Deaths Comparison (2018-2020)",
       x = "Year", y = "Count", fill = "Type") +
  theme_minimal()
print(comparison_plot)
dev.off()



# SECTION 5: ADVANCED SVM CLASSIFICATION ANALYSIS
cat("\n========== SECTION 5: SVM CLASSIFICATION ==========\n")

# 5.1 Data Preparation
cat("\n--- 5.1 Data Preparation ---\n")
data_svm <- weights %>%
  select(HCODE, ID_CODE, GENDER, AGE_IN_YEARS, EDUCATION_LEVEL, 
         LITERACY_CAN_READ, Weight) %>%
  filter(!is.na(LITERACY_CAN_READ),
         !is.na(AGE_IN_YEARS),
         !is.na(GENDER),
         !is.na(EDUCATION_LEVEL)) %>%
  mutate(LITERACY = factor(case_when(
    LITERACY_CAN_READ == 1 ~ "Literate",
    LITERACY_CAN_READ == 2 ~ "Illiterate",
    TRUE ~ NA_character_
  ))) %>%
  na.omit()
cat("SVM dataset created:", nrow(data_svm), "records\n")



# 5.2 Train-Test Split (70-30)
cat("\n--- 5.2 Train-Test Split ---\n")
set.seed(42)
train_idx <- sample(1:nrow(data_svm), size = 0.7 * nrow(data_svm))
train_data <- data_svm[train_idx, ]
test_data <- data_svm[-train_idx, ]
cat("Training set:", nrow(train_data), "records\n")
cat("Testing set:", nrow(test_data), "records\n")



# 5.3 Train SVM Models with Different Kernels
cat("\n--- 5.3 Training SVM Models ---\n")
cat("Training LINEAR kernel...\n")
svm_linear <- svm(
  LITERACY ~ AGE_IN_YEARS + GENDER + EDUCATION_LEVEL,
  data = train_data,
  kernel = "linear",
  cost = 1,
  probability = TRUE
)

cat("Training RADIAL kernel...\n")
svm_radial <- svm(
  LITERACY ~ AGE_IN_YEARS + GENDER + EDUCATION_LEVEL,
  data = train_data,
  kernel = "radial",
  cost = 1,
  gamma = 0.1,
  probability = TRUE
)

cat("Training POLYNOMIAL kernel...\n")
svm_poly <- svm(
  LITERACY ~ AGE_IN_YEARS + GENDER + EDUCATION_LEVEL,
  data = train_data,
  kernel = "polynomial",
  cost = 1,
  degree = 2,
  probability = TRUE
)



# 5.4 Model Predictions
cat("\n--- 5.4 Making Predictions ---\n")
pred_linear <- predict(svm_linear, test_data)
pred_radial <- predict(svm_radial, test_data)
pred_poly <- predict(svm_poly, test_data)

# 5.5 Accuracy Calculation (Manual - No caret dependency)
cat("\n--- 5.5 Model Performance ---\n")
calc_metrics <- function(actual, predicted, model_name) {
  tp <- sum((actual == "Literate") & (predicted == "Literate"))
  tn <- sum((actual == "Illiterate") & (predicted == "Illiterate"))
  fp <- sum((actual == "Illiterate") & (predicted == "Literate"))
  fn <- sum((actual == "Literate") & (predicted == "Illiterate"))
  accuracy <- (tp + tn) / (tp + tn + fp + fn)
  sensitivity <- tp / (tp + fn)
  specificity <- tn / (tn + fp)
  precision <- tp / (tp + fp)
  f1 <- 2 * (precision * sensitivity) / (precision + sensitivity)
  
  cat("\n", model_name, "Performance:\n")
  cat("  Accuracy:", round(accuracy * 100, 2), "%\n")
  cat("  Sensitivity:", round(sensitivity * 100, 2), "%\n")
  cat("  Specificity:", round(specificity * 100, 2), "%\n")
  cat("  Precision:", round(precision * 100, 2), "%\n")
  cat("  F1-Score:", round(f1, 3), "\n")
  return(list(
    accuracy = accuracy,
    sensitivity = sensitivity,
    specificity = specificity,
    precision = precision,
    f1 = f1
  ))
}

metrics_linear <- calc_metrics(test_data$LITERACY, pred_linear, "LINEAR")
metrics_radial <- calc_metrics(test_data$LITERACY, pred_radial, "RADIAL")
metrics_poly <- calc_metrics(test_data$LITERACY, pred_poly, "POLYNOMIAL")



# 5.6 Best Model Selection
cat("\n--- 5.6 Best Model Selection ---\n")
accuracies <- c(
  linear = metrics_linear$accuracy,
  radial = metrics_radial$accuracy,
  poly = metrics_poly$accuracy
)

best_model_name <- names(which.max(accuracies))
best_model <- switch(best_model_name,
                     linear = svm_linear,
                     radial = svm_radial,
                     poly = svm_poly)

cat("\nBest Model:", toupper(best_model_name), "\n")
cat("Accuracy:", round(max(accuracies) * 100, 2), "%\n")
saveRDS(best_model, "best_svm_model.rds")



# 5.7 Predictions on New Data
cat("\n--- 5.7 Predictions on Hypothetical Individuals ---\n")
new_individuals <- data.frame(
  AGE_IN_YEARS = c(25, 35, 45, 20, 30, 40, 55, 18, 50),
  GENDER = c(1, 1, 1, 2, 2, 2, 1, 2, 2),
  EDUCATION_LEVEL = c(5, 8, 9, 3, 6, 7, 4, 2, 8)
)
predictions_new <- predict(best_model, new_individuals)
predictions_df <- new_individuals %>%
  mutate(
    Predicted_Literacy = predictions_new,
    Probability = "Computed"
  )
cat("\nPredictions for New Individuals:\n")
print(predictions_df)
write_csv(predictions_df, "svm_predictions_new.csv")



# Save metrics summary
metrics_summary <- data.frame(
  Model = c("Linear", "Radial", "Polynomial"),
  Accuracy = c(
    round(metrics_linear$accuracy * 100, 2),
    round(metrics_radial$accuracy * 100, 2),
    round(metrics_poly$accuracy * 100, 2)
  ),
  F1_Score = c(
    round(metrics_linear$f1, 3),
    round(metrics_radial$f1, 3),
    round(metrics_poly$f1, 3)
  )
)
write_csv(metrics_summary, "svm_model_comparison.csv")



# SECTION 6: COMPREHENSIVE SUMMARY
cat("\n========== SECTION 6: SUMMARY ==========\n")
summary_df <- data.frame(
  Indicator = c(
    "Sex Ratio",
    "Crude Birth Rate",
    "Crude Death Rate",
    "General Fertility Rate",
    "Total Fertility Rate",
    "Infant Mortality Rate"
  ),
  Value = c(
    round(sex_ratio_value, 2),
    round(cbr_2020, 2),
    round(cdr_2020, 2),
    round(gfr, 2),
    round(tfr, 3),
    round(imr, 2)
  ),
  Unit = c(
    "M per 100F",
    "per 1,000",
    "per 1,000",
    "per 1,000 women",
    "children/woman",
    "per 1,000 births"
  )
)
cat("\n=== DEMOGRAPHIC INDICATORS SUMMARY ===\n")
print(summary_df)
write_csv(summary_df, "demographic_indicators_summary.csv")



# OUTPUT FILES SUMMARY
cat("\n========== OUTPUT FILES CREATED ==========\n")
cat("
CSV Files (Demographic Indicators):
  - sex_ratio_weighted.csv
  - CBR_2020.csv
  - CDR_2020.csv
  - GFR.csv
  - ASFR_all_groups.csv
  - TFR.csv
  - IMR.csv
  - demographic_indicators_summary.csv

PNG Files (Visualizations in /graphs folder):
  - 01_births_by_type.png
  - 02_age_distribution.png
  - 03_gender_distribution.png
  - 04_deaths_by_year.png
  - 05_age_at_death.png
  - 06_birth_order.png
  - 07_birth_outcomes.png
  - 08_children_ever_born.png
  - 09_population_pyramid.png
  - 10_births_vs_deaths.png

SVM Model Files:
  - best_svm_model.rds
  - svm_predictions_new.csv
  - svm_model_comparison.csv

✓ Project analysis complete!
")