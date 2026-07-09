# Packages for SVM
install.packages("caret")
install.packages("e1071")
install.packages("randomForest")

# ============================================================
# ADVANCED SVM WITH GRAPHICS - NO CARET
# ============================================================

install.packages("haven")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("gridExtra")

library(haven)
library(dplyr)
library(e1071)
library(ggplot2)
library(gridExtra)

# Load data
Roster <- read_sav("Weights_Assigned.sav")

# Prepare
data_svm <- Roster %>%
  select(LITERACY_CAN_READ, AGE_IN_YEARS, GENDER, EDUCATION, MARITAL_STATUS) %>%
  filter(!is.na(LITERACY_CAN_READ), !is.na(AGE_IN_YEARS), !is.na(GENDER), !is.na(EDUCATION), !is.na(MARITAL_STATUS)) %>%
  mutate(LITERACY_CAN_READ = factor(case_when(
    LITERACY_CAN_READ == 1 ~ "Literate",
    LITERACY_CAN_READ == 2 ~ "Illiterate",
    TRUE ~ "Unknown"))) %>%
  filter(LITERACY_CAN_READ %in% c("Literate", "Illiterate"))

cat("DATASET: ", nrow(data_svm), "records\n\n")

# Split
set.seed(123)
n <- nrow(data_svm)
train_idx <- sample(1:n, size = 0.8 * n)
train_data <- data_svm[train_idx, ]
test_data <- data_svm[-train_idx, ]

# ============================================================
# 1. TRAIN SVM WITH DIFFERENT KERNELS
# ============================================================

cat("TRAINING MODELS...\n\n")

model_linear <- svm(LITERACY_CAN_READ ~ AGE_IN_YEARS + GENDER + EDUCATION + MARITAL_STATUS,
                    data = train_data, kernel = "linear", probability = TRUE)

model_radial <- svm(LITERACY_CAN_READ ~ AGE_IN_YEARS + GENDER + EDUCATION + MARITAL_STATUS,
                    data = train_data, kernel = "radial", probability = TRUE)

model_poly <- svm(LITERACY_CAN_READ ~ AGE_IN_YEARS + GENDER + EDUCATION + MARITAL_STATUS,
                  data = train_data, kernel = "polynomial", probability = TRUE)

# ============================================================
# 2. PREDICTIONS & METRICS
# ============================================================

calc_metrics <- function(predictions, actual) {
  cm <- table(Predicted = predictions, Actual = actual)
  TP <- cm["Literate", "Literate"]
  TN <- cm["Illiterate", "Illiterate"]
  FP <- cm["Literate", "Illiterate"]
  FN <- cm["Illiterate", "Literate"]
  
  accuracy <- (TP + TN) / sum(cm)
  sensitivity <- TP / (TP + FN)
  specificity <- TN / (TN + FP)
  precision <- TP / (TP + FP)
  f1 <- 2 * (precision * sensitivity) / (precision + sensitivity)
  
  return(list(cm = cm, accuracy = accuracy, sensitivity = sensitivity, 
              specificity = specificity, precision = precision, f1 = f1))
}

pred_linear <- predict(model_linear, test_data)
pred_radial <- predict(model_radial, test_data)
pred_poly <- predict(model_poly, test_data)

m_linear <- calc_metrics(pred_linear, test_data$LITERACY_CAN_READ)
m_radial <- calc_metrics(pred_radial, test_data$LITERACY_CAN_READ)
m_poly <- calc_metrics(pred_poly, test_data$LITERACY_CAN_READ)

# ============================================================
# 3. COMPARISON TABLE
# ============================================================

comparison_df <- data.frame(
  Kernel = c("Linear", "Radial", "Polynomial"),
  Accuracy = c(m_linear$accuracy, m_radial$accuracy, m_poly$accuracy) * 100,
  Sensitivity = c(m_linear$sensitivity, m_radial$sensitivity, m_poly$sensitivity) * 100,
  Specificity = c(m_linear$specificity, m_radial$specificity, m_poly$specificity) * 100,
  Precision = c(m_linear$precision, m_radial$precision, m_poly$precision) * 100,
  F1_Score = c(m_linear$f1, m_radial$f1, m_poly$f1)
)

cat("="*60, "\n")
cat("MODEL COMPARISON\n")
cat("="*60, "\n\n")
print(comparison_df)
cat("\n")

# ============================================================
# 4. GRAPHIC 1: CONFUSION MATRIX HEATMAP (BEST MODEL)
# ============================================================

best_model_idx <- which.max(comparison_df$Accuracy)
best_kernel <- comparison_df$Kernel[best_model_idx]
best_cm <- if(best_model_idx == 1) m_linear$cm else if(best_model_idx == 2) m_radial$cm else m_poly$cm

cm_df <- as.data.frame(best_cm)
names(cm_df) <- c("Predicted", "Actual", "Count")

plot1 <- ggplot(cm_df, aes(x = Actual, y = Predicted, fill = Count)) +
  geom_tile(color = "black", size = 1) +
  geom_text(aes(label = Count), size = 6, fontface = "bold", color = "white") +
  scale_fill_gradient(low = "#e8f4f8", high = "#003366") +
  labs(title = paste("Confusion Matrix -", best_kernel, "Kernel"),
       subtitle = paste("Accuracy:", round(comparison_df$Accuracy[best_model_idx], 2), "%"),
       x = "Actual", y = "Predicted", fill = "Count") +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 11, hjust = 0.5),
        axis.text = element_text(size = 11, face = "bold"))

ggsave("01_confusion_matrix.png", plot1, width = 8, height = 6, dpi = 300)

# ============================================================
# 5. GRAPHIC 2: PERFORMANCE METRICS COMPARISON
# ============================================================

metrics_long <- data.frame(
  Kernel = rep(comparison_df$Kernel, 5),
  Metric = rep(c("Accuracy", "Sensitivity", "Specificity", "Precision", "F1_Score"), each = 3),
  Value = c(comparison_df$Accuracy, comparison_df$Sensitivity, comparison_df$Specificity, 
            comparison_df$Precision, comparison_df$F1_Score * 100)
)

plot2 <- ggplot(metrics_long, aes(x = Metric, y = Value, fill = Kernel)) +
  geom_bar(stat = "identity", position = "dodge", color = "black", size = 0.7) +
  geom_text(aes(label = round(Value, 1)), position = position_dodge(width = 0.9), 
            vjust = -0.5, size = 3, fontface = "bold") +
  scale_fill_manual(values = c("Linear" = "#3498db", "Radial" = "#e74c3c", "Polynomial" = "#2ecc71")) +
  labs(title = "Performance Metrics Comparison",
       x = "Metric", y = "Score (%)",
       fill = "Kernel") +
  ylim(0, 120) +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
        legend.position = "bottom")

ggsave("02_metrics_comparison.png", plot2, width = 10, height = 6, dpi = 300)

# ============================================================
# 6. GRAPHIC 3: ROC-LIKE CURVE (Sensitivity vs 1-Specificity)
# ============================================================

roc_df <- data.frame(
  FPR = 1 - c(m_linear$specificity, m_radial$specificity, m_poly$specificity),
  TPR = c(m_linear$sensitivity, m_radial$sensitivity, m_poly$sensitivity),
  Kernel = c("Linear", "Radial", "Polynomial")
)

plot3 <- ggplot(roc_df, aes(x = FPR, y = TPR, color = Kernel, size = 2)) +
  geom_point(size = 5) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray50", size = 1) +
  scale_color_manual(values = c("Linear" = "#3498db", "Radial" = "#e74c3c", "Polynomial" = "#2ecc71")) +
  labs(title = "ROC-Like Plot (Sensitivity vs False Positive Rate)",
       x = "False Positive Rate (1-Specificity)",
       y = "True Positive Rate (Sensitivity)") +
  xlim(-0.05, 1.05) + ylim(-0.05, 1.05) +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        legend.position = "bottom")

ggsave("03_roc_plot.png", plot3, width = 8, height = 6, dpi = 300)

# ============================================================
# 7. GRAPHIC 4: DATA DISTRIBUTION
# ============================================================

dist_df <- test_data %>%
  mutate(Gender_Label = ifelse(GENDER == 1, "Male", "Female"))

plot4 <- ggplot(dist_df, aes(x = AGE_IN_YEARS, fill = LITERACY_CAN_READ)) +
  geom_histogram(alpha = 0.6, bins = 30, color = "black") +
  scale_fill_manual(values = c("Literate" = "#2ecc71", "Illiterate" = "#e74c3c")) +
  labs(title = "Age Distribution by Literacy Status",
       x = "Age (Years)", y = "Count", fill = "Literacy") +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5))

ggsave("04_age_distribution.png", plot4, width = 10, height = 6, dpi = 300)

# ============================================================
# 8. GRAPHIC 5: EDUCATION IMPACT
# ============================================================

edu_df <- test_data %>%
  group_by(EDUCATION, LITERACY_CAN_READ) %>%
  summarise(Count = n(), .groups = 'drop')

plot5 <- ggplot(edu_df, aes(x = EDUCATION, y = Count, fill = LITERACY_CAN_READ)) +
  geom_bar(stat = "identity", position = "dodge", color = "black", size = 0.7) +
  scale_fill_manual(values = c("Literate" = "#2ecc71", "Illiterate" = "#e74c3c")) +
  labs(title = "Literacy Status by Education Level",
       x = "Education Level", y = "Count", fill = "Literacy") +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5))

ggsave("05_education_impact.png", plot5, width = 10, height = 6, dpi = 300)

# ============================================================
# 9. GRAPHIC 6: PREDICTION BY GENDER
# ============================================================

gender_pred <- data.frame(
  Gender = ifelse(test_data$GENDER == 1, "Male", "Female"),
  Actual = test_data$LITERACY_CAN_READ,
  Predicted = pred_radial
) %>%
  mutate(Correct = Actual == Predicted) %>%
  group_by(Gender, Correct) %>%
  summarise(Count = n(), .groups = 'drop')

plot6 <- ggplot(gender_pred, aes(x = Gender, y = Count, fill = Correct)) +
  geom_bar(stat = "identity", color = "black", size = 0.7) +
  geom_text(aes(label = Count), position = position_stack(vjust = 0.5), 
            size = 4, fontface = "bold", color = "white") +
  scale_fill_manual(values = c("TRUE" = "#2ecc71", "FALSE" = "#e74c3c"),
                    labels = c("Correct", "Wrong")) +
  labs(title = "Prediction Accuracy by Gender (Best Model)",
       x = "Gender", y = "Count", fill = "Status") +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5))

ggsave("06_gender_accuracy.png", plot6, width = 8, height = 6, dpi = 300)

# ============================================================
# 10. PREDICTIONS FOR NEW DATA
# ============================================================

cat("\n", "="*60, "\n")
cat("PREDICTIONS FOR NEW PEOPLE (Using", best_kernel, "Kernel)\n")
cat("="*60, "\n\n")

best_model <- if(best_model_idx == 1) model_linear else if(best_model_idx == 2) model_radial else model_poly

new_people <- data.frame(
  AGE_IN_YEARS = c(8, 12, 15, 25, 35, 45, 55, 65, 75),
  GENDER = c(1, 2, 1, 2, 1, 2, 1, 2, 1),
  EDUCATION = c(0, 0, 1, 3, 5, 6, 4, 2, 1),
  MARITAL_STATUS = c(1, 1, 1, 2, 2, 2, 2, 2, 2)
)

pred_new <- predict(best_model, new_people, probability = TRUE)
pred_prob <- attr(pred_new, "probabilities")

new_results <- data.frame(
  Age = new_people$AGE_IN_YEARS,
  Gender = ifelse(new_people$GENDER == 1, "Male", "Female"),
  Education = new_people$EDUCATION,
  Prediction = pred_new,
  Confidence = round(pmax(pred_prob[, "Literate"], pred_prob[, "Illiterate"]), 3) * 100
)

print(new_results)

# ============================================================
# 11. SAVE ALL RESULTS
# ============================================================

write.csv(comparison_df, "SVM_Model_Comparison.csv", row.names = FALSE)
write.csv(new_results, "SVM_New_Predictions.csv", row.names = FALSE)
saveRDS(best_model, "SVM_Best_Model.rds")

cat("\n", "="*60, "\n")
cat("FILES SAVED:\n")
cat("="*60, "\n")
cat("✓ 01_confusion_matrix.png\n")
cat("✓ 02_metrics_comparison.png\n")
cat("✓ 03_roc_plot.png\n")
cat("✓ 04_age_distribution.png\n")
cat("✓ 05_education_impact.png\n")
cat("✓ 06_gender_accuracy.png\n")
cat("✓ SVM_Model_Comparison.csv\n")
cat("✓ SVM_New_Predictions.csv\n")
cat("✓ SVM_Best_Model.rds\n\n")

cat("BEST MODEL:", best_kernel, "Kernel\n")
cat("ACCURACY:", round(comparison_df$Accuracy[best_model_idx], 2), "%\n")


#graph
# ============================================================================
# ERROR-FREE SOFT MARGIN SVM & PREDICTIVE GRAPH
# Uses EXACT original column names without renaming
# ============================================================================

# 1. Load required libraries
if(!require(e1071)) install.packages("e1071")
if(!require(ggplot2)) install.packages("ggplot2")
if(!require(haven)) install.packages("haven")

library(haven)
library(e1071)
library(ggplot2)

# 2. Load the data
birth_data <- read_sav("Birth.sav")

# 3. Use Exact Columns - but cast them to native R types
# SVM crashes on SPSS 'haven_labelled' types, so we must wrap them in 
# as.numeric() and as.factor() without changing their names.
svm_df <- data.frame(
  BIRTH_YE = as.numeric(birth_data$BIRTH_YE),
  BIRTH_MO = as.numeric(birth_data$BIRTH_MO),
  # Target variable MUST be a factor, otherwise SVM tries to do regression instead of classification
  GENDER = as.factor(as.numeric(birth_data$GENDER)) 
)

# 4. Remove Missing Values (NAs will crash the SVM)
svm_df <- na.omit(svm_df)

# Check to ensure we have at least 2 classes to classify
if(length(unique(svm_df$GENDER)) < 2) {
  stop("Error: The Target variable does not have at least 2 different classes to classify.")
}

# 5. Train the Soft Margin SVM
# cost = 1 allows misclassifications (Soft Margin)
# scale = FALSE is required to extract the exact mathematical margin lines
svm_model <- svm(GENDER ~ BIRTH_YE + BIRTH_MO, 
                 data = svm_df, 
                 type = "C-classification", 
                 kernel = "linear", 
                 cost = 1, 
                 scale = FALSE)

# 6. Extract Weights (w) and Bias (b) to manually draw the margin lines
w <- t(svm_model$coefs) %*% svm_model$SV
b <- -svm_model$rho

# Prevent division by zero if a feature has zero weight
w2 <- ifelse(w[1, 2] == 0, 1e-5, w[1, 2])

# Calculate slopes and intercepts for the mathematical boundaries
slope <- -w[1, 1] / w2
intercept <- -b / w2
margin_up <- intercept + 1 / w2
margin_down <- intercept - 1 / w2

# 7. Create Background Prediction Grid
# This creates the shaded color regions showing where the model predicts Gender 1 vs 2
year_range <- seq(min(svm_df$BIRTH_YE) - 1, max(svm_df$BIRTH_YE) + 1, length.out = 150)
month_range <- seq(min(svm_df$BIRTH_MO) - 1, max(svm_df$BIRTH_MO) + 1, length.out = 150)
grid_data <- expand.grid(BIRTH_YE = year_range, BIRTH_MO = month_range)
grid_data$Predicted_GENDER <- predict(svm_model, grid_data)

# 8. Create the Advanced Graph using exact original columns
p_svm <- ggplot() +
  
  # LAYER 1: Background shading based on model predictions
  geom_tile(data = grid_data, aes(x = BIRTH_YE, y = BIRTH_MO, fill = Predicted_GENDER), alpha = 0.2) +
  
  # LAYER 2: Actual data points
  # We use jitter here because Birth Year & Month are whole numbers; jitter prevents them from stacking invisibly
  geom_jitter(data = svm_df, aes(x = BIRTH_YE, y = BIRTH_MO, color = GENDER), 
              size = 3, width = 0.25, height = 0.25, alpha = 0.8) +
  
  # LAYER 3: Circle the Support Vectors
  geom_point(data = svm_df[svm_model$index, ], aes(x = BIRTH_YE, y = BIRTH_MO), 
             shape = 1, size = 6, color = "black", stroke = 1.2) +
  
  # LAYER 4: The Decision Boundary and Soft Margins
  geom_abline(intercept = intercept, slope = slope, color = "black", linewidth = 1.2) +
  geom_abline(intercept = margin_up, slope = slope, color = "black", linetype = "dashed", linewidth = 0.8) +
  geom_abline(intercept = margin_down, slope = slope, color = "black", linetype = "dashed", linewidth = 0.8) +
  
  # LAYER 5: Styling & Labels
  scale_color_manual(values = c("1" = "#2980b9", "2" = "#c0392b"), name = "Actual Gender Code") +
  scale_fill_manual(values = c("1" = "#3498db", "2" = "#e74c3c"), name = "Predicted Region") +
  labs(
    title = "Predictive Soft Margin SVM",
    subtitle = "Decision Boundary & Margins using Original Columns: BIRTH_YE & BIRTH_MO",
    x = "Birth Year (BIRTH_YE)",
    y = "Birth Month (BIRTH_MO)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(color = "grey40", hjust = 0.5),
    legend.position = "right"
  )

# 9. Save output
ggsave("Original_Columns_SVM_Graph.png", p_svm, width = 11, height = 8, dpi = 300)
cat("\n✓ SUCCESS: Error-free SVM graph successfully created as 'Original_Columns_SVM_Graph.png'\n")
