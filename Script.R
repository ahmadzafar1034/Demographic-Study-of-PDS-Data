read_sav("Sample.sav")


# Different columns of new table through death.sav as death_comprehensive_table.sav
library(haven)
library(dplyr)

Death <- read_sav("/mnt/user-data/uploads/Death.sav")

# TABLE 1: Deaths by Year
deaths_by_year <- Death %>%
  group_by(DEATH_YEAR) %>%
  summarise(Count = n(), .groups = 'drop') %>%
  mutate(Percentage = round(Count / sum(Count) * 100, 2)) %>%
  rename(Year = DEATH_YEAR)
print(deaths_by_year)

# TABLE 2: Deaths by Place
deaths_by_place <- Death %>%
  mutate(
    Place_Label = case_when(
      DEATH_PLACE == 1 ~ "Home",
      DEATH_PLACE == 2 ~ "Hospital/Clinic/Dispensary",
      DEATH_PLACE == 3 ~ "On Road",
      DEATH_PLACE == 4 ~ "Others",
      TRUE ~ "Missing"
    )
  ) %>%
  group_by(Place_Label) %>%
  summarise(Count = n(), .groups = 'drop') %>%
  mutate(Percentage = round(Count / sum(Count) * 100, 2)) %>%
  arrange(desc(Count))
print(deaths_by_place)

# TABLE 3: Deaths by Gender
deaths_by_gender <- Death %>%
  mutate(
    Gender_Label = case_when(
      GENDER == 1 ~ "Male",
      GENDER == 2 ~ "Female",
      TRUE ~ "Missing"
    )
  ) %>%
  group_by(Gender_Label) %>%
  summarise(Count = n(), .groups = 'drop') %>%
  mutate(Percentage = round(Count / sum(Count) * 100, 2))
print(deaths_by_gender)

# TABLE 4: Deaths by Year and Gender
deaths_year_gender <- Death %>%
  mutate(
    Gender_Label = case_when(
      GENDER == 1 ~ "Male",
      GENDER == 2 ~ "Female",
      TRUE ~ "Missing"
    )
  ) %>%
  group_by(DEATH_YEAR, Gender_Label) %>%
  summarise(Count = n(), .groups = 'drop') %>%
  rename(Year = DEATH_YEAR) %>%
  arrange(Year, desc(Count))
print(deaths_year_gender)

# TABLE 5: Deaths by Year and Place
deaths_year_place <- Death %>%
  mutate(
    Place_Label = case_when(
      DEATH_PLACE == 1 ~ "Home",
      DEATH_PLACE == 2 ~ "Hospital/Clinic/Dispensary",
      DEATH_PLACE == 3 ~ "On Road",
      DEATH_PLACE == 4 ~ "Others",
      TRUE ~ "Missing"
    )
  ) %>%
  group_by(DEATH_YEAR, Place_Label) %>%
  summarise(Count = n(), .groups = 'drop') %>%
  rename(Year = DEATH_YEAR) %>%
  arrange(Year, desc(Count))
print(deaths_year_place)

# TABLE 6: Deaths by Gender and Place
deaths_gender_place <- Death %>%
  mutate(
    Gender_Label = case_when(
      GENDER == 1 ~ "Male",
      GENDER == 2 ~ "Female",
      TRUE ~ "Missing"
    ),
    Place_Label = case_when(
      DEATH_PLACE == 1 ~ "Home",
      DEATH_PLACE == 2 ~ "Hospital/Clinic/Dispensary",
      DEATH_PLACE == 3 ~ "On Road",
      DEATH_PLACE == 4 ~ "Others",
      TRUE ~ "Missing"
    )
  ) %>%
  group_by(Gender_Label, Place_Label) %>%
  summarise(Count = n(), .groups = 'drop') %>%
  arrange(Gender_Label, desc(Count))
print(deaths_gender_place)

# TABLE 7: Comprehensive (Year, Place, Gender)
comprehensive_table <- Death %>%
  mutate(
    Gender_Label = case_when(
      GENDER == 1 ~ "Male",
      GENDER == 2 ~ "Female",
      TRUE ~ "Missing"
    ),
    Place_Label = case_when(
      DEATH_PLACE == 1 ~ "Home",
      DEATH_PLACE == 2 ~ "Hospital/Clinic/Dispensary",
      DEATH_PLACE == 3 ~ "On Road",
      DEATH_PLACE == 4 ~ "Others",
      TRUE ~ "Missing"
    )
  ) %>%
  group_by(DEATH_YEAR, Place_Label, Gender_Label) %>%
  summarise(Count = n(), .groups = 'drop') %>%
  rename(Year = DEATH_YEAR) %>%
  arrange(Year, Place_Label, Gender_Label)
print(comprehensive_table)

# SAVE
write_sav(comprehensive_table, "death_comprehensive_table.sav")
cat("Saved: death_comprehensive_table.sav\n")



#Different Charts for Death.sav file
library(haven)
library(dplyr)
library(ggplot2)

Death <- read_sav("Death.sav")

# CHART 1: Deaths by Year
deaths_by_year <- Death %>%
  group_by(DEATH_YEAR) %>%
  summarise(Count = n(), .groups = 'drop')

chart1 <- ggplot(deaths_by_year, aes(x = factor(DEATH_YEAR), y = Count, fill = factor(DEATH_YEAR))) +
  geom_bar(stat = "identity", color = "black", linewidth = 1) +
  geom_text(aes(label = Count), vjust = -0.5, size = 5, fontface = "bold") +
  scale_fill_manual(values = c("2018" = "#3498db", "2019" = "#e74c3c", "2020" = "#2ecc71")) +
  labs(title = "Deaths by Year (2018-2020)", x = "Year", y = "Number of Deaths", fill = "Year") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14), axis.title = element_text(face = "bold", size = 12), legend.position = "bottom")

ggsave("chart1_deaths_by_year.png", chart1, width = 10, height = 7, dpi = 300)

# CHART 2: Deaths by Place
deaths_by_place <- Death %>%
  mutate(Place_Label = case_when(DEATH_PLACE == 1 ~ "Home", DEATH_PLACE == 2 ~ "Hospital/Clinic", DEATH_PLACE == 3 ~ "On Road", DEATH_PLACE == 4 ~ "Others", TRUE ~ "Missing")) %>%
  group_by(Place_Label) %>%
  summarise(Count = n(), .groups = 'drop') %>%
  arrange(desc(Count))

chart2 <- ggplot(deaths_by_place, aes(x = reorder(Place_Label, -Count), y = Count, fill = Place_Label)) +
  geom_bar(stat = "identity", color = "black", linewidth = 1) +
  geom_text(aes(label = Count), vjust = -0.5, size = 5, fontface = "bold") +
  scale_fill_manual(values = c("Home" = "#e74c3c", "Hospital/Clinic" = "#3498db", "On Road" = "#f39c12", "Others" = "#95a5a6")) +
  labs(title = "Deaths by Place of Death", x = "Place of Death", y = "Number of Deaths", fill = "Place") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14), axis.title = element_text(face = "bold", size = 12), axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "bottom")

ggsave("chart2_deaths_by_place.png", chart2, width = 10, height = 7, dpi = 300)

# CHART 3: Deaths by Gender
deaths_by_gender <- Death %>%
  mutate(Gender_Label = case_when(GENDER == 1 ~ "Male", GENDER == 2 ~ "Female", TRUE ~ "Missing")) %>%
  group_by(Gender_Label) %>%
  summarise(Count = n(), .groups = 'drop')

chart3 <- ggplot(deaths_by_gender, aes(x = Gender_Label, y = Count, fill = Gender_Label)) +
  geom_bar(stat = "identity", color = "black", linewidth = 1) +
  geom_text(aes(label = Count), vjust = -0.5, size = 5, fontface = "bold") +
  scale_fill_manual(values = c("Male" = "#3498db", "Female" = "#e91e63")) +
  labs(title = "Deaths by Gender", x = "Gender", y = "Number of Deaths", fill = "Gender") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14), axis.title = element_text(face = "bold", size = 12), legend.position = "bottom")

ggsave("chart3_deaths_by_gender.png", chart3, width = 10, height = 7, dpi = 300)

# CHART 4: Deaths by Year and Gender
deaths_year_gender <- Death %>%
  mutate(Gender_Label = case_when(GENDER == 1 ~ "Male", GENDER == 2 ~ "Female", TRUE ~ "Missing")) %>%
  group_by(DEATH_YEAR, Gender_Label) %>%
  summarise(Count = n(), .groups = 'drop')

chart4 <- ggplot(deaths_year_gender, aes(x = factor(DEATH_YEAR), y = Count, fill = Gender_Label)) +
  geom_bar(stat = "identity", position = "dodge", color = "black", linewidth = 0.8) +
  geom_text(aes(label = Count), vjust = -0.3, size = 4, position = position_dodge(width = 0.9)) +
  scale_fill_manual(values = c("Male" = "#3498db", "Female" = "#e91e63")) +
  labs(title = "Deaths by Year and Gender", x = "Year", y = "Number of Deaths", fill = "Gender") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14), axis.title = element_text(face = "bold", size = 12), legend.position = "bottom")

ggsave("chart4_deaths_year_gender.png", chart4, width = 10, height = 7, dpi = 300)

# CHART 5: Deaths by Year and Place
deaths_year_place <- Death %>%
  mutate(Place_Label = case_when(DEATH_PLACE == 1 ~ "Home", DEATH_PLACE == 2 ~ "Hospital/Clinic", DEATH_PLACE == 3 ~ "On Road", DEATH_PLACE == 4 ~ "Others", TRUE ~ "Missing")) %>%
  group_by(DEATH_YEAR, Place_Label) %>%
  summarise(Count = n(), .groups = 'drop')

chart5 <- ggplot(deaths_year_place, aes(x = factor(DEATH_YEAR), y = Count, fill = Place_Label)) +
  geom_bar(stat = "identity", position = "dodge", color = "black", linewidth = 0.8) +
  geom_text(aes(label = Count), vjust = -0.3, size = 3.5, position = position_dodge(width = 0.9)) +
  scale_fill_manual(values = c("Home" = "#e74c3c", "Hospital/Clinic" = "#3498db", "On Road" = "#f39c12", "Others" = "#95a5a6")) +
  labs(title = "Deaths by Year and Place of Death", x = "Year", y = "Number of Deaths", fill = "Place") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14), axis.title = element_text(face = "bold", size = 12), legend.position = "bottom")

ggsave("chart5_deaths_year_place.png", chart5, width = 10, height = 7, dpi = 300)

# CHART 6: Deaths by Gender and Place
deaths_gender_place <- Death %>%
  mutate(Gender_Label = case_when(GENDER == 1 ~ "Male", GENDER == 2 ~ "Female", TRUE ~ "Missing"), Place_Label = case_when(DEATH_PLACE == 1 ~ "Home", DEATH_PLACE == 2 ~ "Hospital/Clinic", DEATH_PLACE == 3 ~ "On Road", DEATH_PLACE == 4 ~ "Others", TRUE ~ "Missing")) %>%
  group_by(Gender_Label, Place_Label) %>%
  summarise(Count = n(), .groups = 'drop')

chart6 <- ggplot(deaths_gender_place, aes(x = Place_Label, y = Count, fill = Gender_Label)) +
  geom_bar(stat = "identity", position = "dodge", color = "black", linewidth = 0.8) +
  geom_text(aes(label = Count), vjust = -0.3, size = 4, position = position_dodge(width = 0.9)) +
  scale_fill_manual(values = c("Male" = "#3498db", "Female" = "#e91e63")) +
  labs(title = "Deaths by Gender and Place of Death", x = "Place of Death", y = "Number of Deaths", fill = "Gender") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14), axis.title = element_text(face = "bold", size = 12), axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "bottom")

ggsave("chart6_deaths_gender_place.png", chart6, width = 10, height = 7, dpi = 300)

cat("All charts saved!\n")


#Pyramid Chart of Assigned_Weights.sav
library(haven)
library(dplyr)
library(tidyr)
library(ggplot2)

# READ DATA
Weights <- read_sav("Weights_Assigned.sav")

# CREATE AGE GROUPS AND CALCULATE WEIGHTED COUNTS
pyramid_data <- Weights %>%
  mutate(
    AgeGroup = cut(
      AGE_IN_YEARS,
      breaks = seq(0, 100, by = 5),
      labels = c("0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", 
                 "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", 
                 "70-74", "75-79", "80-84", "85-89", "90-94", "95-99"),
      right = FALSE
    ),
    Gender_Label = case_when(
      GENDER == 1 ~ "Male",
      GENDER == 2 ~ "Female",
      TRUE ~ "Unknown"
    )
  ) %>%
  filter(!is.na(AgeGroup)) %>%
  group_by(AgeGroup, Gender_Label) %>%
  summarise(
    Weighted_Count = sum(Weight, na.rm = TRUE),
    Count = n(),
    .groups = 'drop'
  )

# CALCULATE PERCENTAGES
pyramid_data <- pyramid_data %>%
  mutate(
    Total_Weighted = sum(Weighted_Count),
    Percentage = round(Weighted_Count / Total_Weighted * 100, 2)
  )

# PREPARE DATA FOR PYRAMID (Males negative, Females positive)
pyramid_data_formatted <- pyramid_data %>%
  mutate(
    Weighted_Count_Plot = ifelse(Gender_Label == "Male", 
                                 -Weighted_Count, 
                                 Weighted_Count),
    Percentage_Plot = ifelse(Gender_Label == "Male", 
                             -Percentage, 
                             Percentage)
  ) %>%
  arrange(AgeGroup)

pyramid_data_formatted$AgeGroup <- factor(
  pyramid_data_formatted$AgeGroup,
  levels = c("0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", 
             "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", 
             "70-74", "75-79", "80-84", "85-89", "90-94", "95-99"),
  ordered = TRUE
)

# CREATE POPULATION PYRAMID CHART
pyramid_chart <- ggplot(pyramid_data_formatted, 
                        aes(x = Percentage_Plot, 
                            y = AgeGroup, 
                            fill = Gender_Label)) +
  geom_bar(stat = "identity", width = 0.7, color = "black", linewidth = 0.5) +
  geom_text(aes(label = paste0(format(abs(Percentage_Plot), digits = 2), "%")),
            hjust = ifelse(pyramid_data_formatted$Gender_Label == "Male", 1.2, -0.2),
            size = 3, fontface = "bold") +
  coord_flip() +
  scale_fill_manual(values = c("Male" = "#3498db", "Female" = "#e91e63")) +
  scale_x_continuous(labels = function(x) paste0(format(abs(x), digits = 2), "%")) +
  labs(
    title = "Population Pyramid by Age Group and Gender",
    subtitle = "Weighted Population Distribution (Percentage)",
    x = "Percentage of Total Population",
    y = "Age Group",
    fill = "Gender"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray40"),
    axis.title = element_text(face = "bold", size = 12),
    legend.position = "bottom",
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )

# DISPLAY AND SAVE CHART
print(pyramid_chart)
ggsave("population_pyramid_percentage.png", pyramid_chart, width = 12, height = 10, dpi = 300)

# SAVE DATA
write_sav(pyramid_data, "pyramid_data_percentage.sav")

# SUMMARY STATISTICS
cat("\n========== PYRAMID SUMMARY ==========\n")
cat("Total Population: ", pyramid_data$Total_Weighted[1], "\n\n")

male_data <- pyramid_data %>% filter(Gender_Label == "Male")
female_data <- pyramid_data %>% filter(Gender_Label == "Female")

cat("Males: ", sum(male_data$Percentage), "%\n")
cat("Females: ", sum(female_data$Percentage), "%\n")



##################
#Pakistan Demographic Survey 2020

#Graphs
# ============================================================================
# ADVANCED DEMOGRAPHIC ANALYSIS & VISUALIZATIONS
# Complex relationships and cross-tabulations
# ============================================================================
# This script creates advanced visualizations including:
# - Mosaic plots for categorical associations
# - Faceted plots by demographic groups
# - Custom demographic pyramids
# - Correlation heatmaps
# ============================================================================

library(haven)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(gridExtra)

# Set output directory
output_dir <- '/mnt/user-data/outputs/'

# Load all data
birth <- read_sav('/mnt/user-data/uploads/Birth.sav')
fertility <- read_sav('/mnt/user-data/uploads/Fertility.sav')
roster <- read_sav('/mnt/user-data/uploads/Roster.sav')
death <- read_sav('/mnt/user-data/uploads/Death.sav')

# ============================================================================
# ADVANCED ANALYSIS 1: AGE GROUP ANALYSIS
# ============================================================================

cat("\n========== ADVANCED AGE GROUP ANALYSIS ==========\n")

# Create age groups from roster data and visualize
if("ha2" %in% names(roster) || "age" %in% tolower(names(roster))) {
  
  age_col <- names(roster)[tolower(names(roster)) %in% c("age", "ha2")][1]
  
  roster_age_groups <- roster %>%
    filter(!is.na(!!sym(age_col)), !!sym(age_col) >= 0, !!sym(age_col) < 150) %>%
    mutate(
      # Create age groups for better analysis
      age_group = case_when(
        !!sym(age_col) < 5 ~ "0-4 years",
        !!sym(age_col) >= 5 & !!sym(age_col) < 15 ~ "5-14 years",
        !!sym(age_col) >= 15 & !!sym(age_col) < 30 ~ "15-29 years",
        !!sym(age_col) >= 30 & !!sym(age_col) < 45 ~ "30-44 years",
        !!sym(age_col) >= 45 & !!sym(age_col) < 60 ~ "45-59 years",
        !!sym(age_col) >= 60 & !!sym(age_col) < 75 ~ "60-74 years",
        !!sym(age_col) >= 75 ~ "75+ years"
      )
    ) %>%
    filter(!is.na(age_group))
  
  if(nrow(roster_age_groups) > 0) {
    # Create age pyramid
    gender_col <- names(roster)[tolower(names(roster)) %in% c("gender", "sex", "ha3")][1]
    
    if(!is.na(gender_col)) {
      # Age pyramid by gender
      age_pyramid_data <- roster_age_groups %>%
        group_by(age_group, !!sym(gender_col)) %>%
        summarise(count = n(), .groups = 'drop') %>%
        filter(!is.na(!!sym(gender_col))) %>%
        mutate(
          gender_label = ifelse(!!sym(gender_col) %in% c(1, "Male"), "Male", "Female"),
          count_adjusted = ifelse(gender_label == "Female", -count, count)
        )
      
      p_age_pyramid <- ggplot(age_pyramid_data, 
                              aes(x = reorder(age_group, age_group), 
                                  y = count_adjusted, 
                                  fill = gender_label)) +
        geom_col(alpha = 0.8, color = "black") +
        scale_fill_manual(values = c("Male" = "lightblue", "Female" = "lightpink")) +
        coord_flip() +
        labs(
          title = "Population Pyramid by Age Group and Gender",
          x = "Age Group",
          y = "Count (Males → | ← Females)",
          fill = "Gender",
          caption = "Shows demographic structure of the population"
        ) +
        theme_minimal() +
        theme(plot.title = element_text(size = 14, face = "bold"))
      
      print(p_age_pyramid)
      ggsave(paste0(output_dir, "17_advanced_age_pyramid.png"), 
             p_age_pyramid, width = 11, height = 7)
      cat("✓ Saved: 17_advanced_age_pyramid.png\n")
    } else {
      # Without gender, just age group distribution
      age_group_dist <- roster_age_groups %>%
        group_by(age_group) %>%
        summarise(count = n(), .groups = 'drop') %>%
        arrange(factor(age_group, 
                       levels = c("0-4 years", "5-14 years", "15-29 years", 
                                  "30-44 years", "45-59 years", "60-74 years", "75+ years")))
      
      p_age_group <- ggplot(age_group_dist, aes(x = factor(age_group, 
                                                           levels = c("0-4 years", "5-14 years", "15-29 years", 
                                                                      "30-44 years", "45-59 years", "60-74 years", "75+ years")), 
                                                y = count)) +
        geom_col(fill = "steelblue", alpha = 0.8, color = "black") +
        coord_flip() +
        labs(
          title = "Population Distribution by Age Group",
          x = "Age Group",
          y = "Count",
          caption = "WHO standard age grouping categories"
        ) +
        theme_minimal() +
        theme(plot.title = element_text(size = 14, face = "bold"))
      
      print(p_age_group)
      ggsave(paste0(output_dir, "17_advanced_age_groups.png"), 
             p_age_group, width = 10, height = 6)
      cat("✓ Saved: 17_advanced_age_groups.png\n")
    }
  }
}

# ============================================================================
# ADVANCED ANALYSIS 2: EDUCATION & DEMOGRAPHIC INTERACTION (if education data exists)
# ============================================================================

cat("\n========== EDUCATION ANALYSIS ==========\n")

# Check for education variables
education_var <- names(roster)[tolower(names(roster)) %in% c("education", "edu", "ha5")][1]
if(!is.na(education_var)) {
  
  edu_analysis <- roster %>%
    filter(!is.na(!!sym(education_var))) %>%
    group_by(!!sym(education_var)) %>%
    summarise(count = n(), .groups = 'drop') %>%
    arrange(desc(count))
  
  if(nrow(edu_analysis) > 0) {
    p_education <- ggplot(edu_analysis, 
                          aes(x = reorder(factor(!!sym(education_var)), count), y = count)) +
      geom_col(fill = "mediumpurple", alpha = 0.8, color = "black") +
      coord_flip() +
      labs(
        title = "Educational Attainment Distribution",
        x = "Education Level",
        y = "Count",
        caption = "Shows highest level of education in household"
      ) +
      theme_minimal() +
      theme(plot.title = element_text(size = 14, face = "bold"))
    
    print(p_education)
    ggsave(paste0(output_dir, "18_education_distribution.png"), 
           p_education, width = 10, height = 6)
    cat("✓ Saved: 18_education_distribution.png\n")
  }
}

# ============================================================================
# ADVANCED ANALYSIS 3: FERTILITY & AGE INTERACTION
# ============================================================================

cat("\n========== FERTILITY & AGE INTERACTION ==========\n")

# Relationship between women's age and fertility outcome
if("g1" %in% names(fertility) && 
   ("age" %in% tolower(names(fertility)) || "g0" %in% names(fertility))) {
  
  age_col_fert <- names(fertility)[tolower(names(fertility)) %in% c("age", "g0")][1]
  
  if(!is.na(age_col_fert)) {
    fert_age_analysis <- fertility %>%
      filter(!is.na(g1), !is.na(!!sym(age_col_fert)), 
             !!sym(age_col_fert) >= 15, !!sym(age_col_fert) < 50) %>%
      mutate(
        age_group = case_when(
          !!sym(age_col_fert) < 20 ~ "15-19",
          !!sym(age_col_fert) < 25 ~ "20-24",
          !!sym(age_col_fert) < 30 ~ "25-29",
          !!sym(age_col_fert) < 35 ~ "30-34",
          !!sym(age_col_fert) < 40 ~ "35-39",
          !!sym(age_col_fert) < 50 ~ "40-49"
        )
      ) %>%
      filter(!is.na(age_group)) %>%
      group_by(age_group, g1) %>%
      summarise(count = n(), .groups = 'drop')
    
    if(nrow(fert_age_analysis) > 0) {
      p_fert_age <- ggplot(fert_age_analysis, 
                           aes(x = factor(age_group, 
                                          levels = c("15-19", "20-24", "25-29", "30-34", "35-39", "40-49")), 
                               y = count, fill = factor(g1))) +
        geom_col(alpha = 0.8, color = "black", position = "dodge") +
        labs(
          title = "Fertility Outcomes by Age Group",
          x = "Age Group (years)",
          y = "Count",
          fill = "Number of\nChildren",
          caption = "Shows distribution of children across reproductive ages"
        ) +
        theme_minimal() +
        theme(plot.title = element_text(size = 14, face = "bold"))
      
      print(p_fert_age)
      ggsave(paste0(output_dir, "19_fertility_by_age_group.png"), 
             p_fert_age, width = 11, height = 6)
      cat("✓ Saved: 19_fertility_by_age_group.png\n")
    }
  }
}

# ============================================================================
# ADVANCED ANALYSIS 4: MORTALITY RATE BY AGE GROUP (for deaths)
# ============================================================================

cat("\n========== MORTALITY ANALYSIS BY AGE ==========\n")

# Create mortality statistics by age group
age_col_death <- names(death)[tolower(names(death)) %in% c("age", "d2")][1]
if(!is.na(age_col_death)) {
  
  death_age_groups <- death %>%
    filter(!is.na(!!sym(age_col_death)), !!sym(age_col_death) >= 0, !!sym(age_col_death) < 150) %>%
    mutate(
      age_group = case_when(
        !!sym(age_col_death) < 5 ~ "0-4 years",
        !!sym(age_col_death) >= 5 & !!sym(age_col_death) < 15 ~ "5-14 years",
        !!sym(age_col_death) >= 15 & !!sym(age_col_death) < 30 ~ "15-29 years",
        !!sym(age_col_death) >= 30 & !!sym(age_col_death) < 45 ~ "30-44 years",
        !!sym(age_col_death) >= 45 & !!sym(age_col_death) < 60 ~ "45-59 years",
        !!sym(age_col_death) >= 60 & !!sym(age_col_death) < 75 ~ "60-74 years",
        !!sym(age_col_death) >= 75 ~ "75+ years"
      )
    ) %>%
    filter(!is.na(age_group))
  
  if(nrow(death_age_groups) > 0) {
    death_summary <- death_age_groups %>%
      group_by(age_group) %>%
      summarise(
        deaths = n(),
        mean_age = mean(!!sym(age_col_death)),
        .groups = 'drop'
      ) %>%
      arrange(factor(age_group, 
                     levels = c("0-4 years", "5-14 years", "15-29 years", 
                                "30-44 years", "45-59 years", "60-74 years", "75+ years")))
    
    p_mortality_rate <- ggplot(death_summary, 
                               aes(x = factor(age_group, 
                                              levels = c("0-4 years", "5-14 years", "15-29 years", 
                                                         "30-44 years", "45-59 years", "60-74 years", "75+ years")), 
                                   y = deaths)) +
      geom_col(fill = "darkred", alpha = 0.8, color = "black") +
      geom_text(aes(label = deaths), vjust = -0.5, fontface = "bold") +
      coord_flip() +
      labs(
        title = "Mortality Distribution by Age Group",
        x = "Age Group",
        y = "Number of Deaths",
        caption = "Shows age-specific mortality patterns"
      ) +
      theme_minimal() +
      theme(plot.title = element_text(size = 14, face = "bold"))
    
    print(p_mortality_rate)
    ggsave(paste0(output_dir, "20_mortality_by_age_group.png"), 
           p_mortality_rate, width = 10, height = 6)
    cat("✓ Saved: 20_mortality_by_age_group.png\n")
  }
}

# ============================================================================
# ADVANCED ANALYSIS 5: BIRTH ORDER & SURVIVAL ANALYSIS
# ============================================================================

cat("\n========== BIRTH ORDER & SURVIVAL ANALYSIS ==========\n")

# Analyze relationship between birth order and survival
if("b1" %in% names(birth) && "b7" %in% names(birth)) {
  
  birth_survival <- birth %>%
    filter(!is.na(b1), !is.na(b7)) %>%
    group_by(b1, b7) %>%
    summarise(count = n(), .groups = 'drop') %>%
    mutate(
      survival_status = case_when(
        b7 %in% c(1, "Living") ~ "Living",
        b7 %in% c(2, "Dead") ~ "Deceased",
        TRUE ~ as.character(b7)
      )
    )
  
  if(nrow(birth_survival) > 0 && length(unique(birth_survival$b1)) > 1) {
    p_birth_survival <- ggplot(birth_survival, 
                               aes(x = factor(b1), y = count, fill = factor(survival_status))) +
      geom_col(alpha = 0.8, color = "black", position = "dodge") +
      scale_fill_manual(values = c("Living" = "green", "Deceased" = "red", "1" = "green", "2" = "red")) +
      labs(
        title = "Birth Order vs Child Survival Status",
        x = "Birth Order",
        y = "Count",
        fill = "Status",
        caption = "Shows survival patterns across birth order sequences"
      ) +
      theme_minimal() +
      theme(plot.title = element_text(size = 14, face = "bold"))
    
    print(p_birth_survival)
    ggsave(paste0(output_dir, "21_birth_order_survival_analysis.png"), 
           p_birth_survival, width = 11, height = 6)
    cat("✓ Saved: 21_birth_order_survival_analysis.png\n")
  }
}

# ============================================================================
# ADVANCED ANALYSIS 6: LIVING VS DEAD CHILDREN BY AGE OF MOTHER
# ============================================================================

cat("\n========== LIVING CHILDREN ANALYSIS ==========\n")

# Compare living and dead children distribution
if("g6" %in% names(fertility) && "g7" %in% names(fertility)) {
  
  child_status <- fertility %>%
    filter(!is.na(g6), !is.na(g7)) %>%
    summarise(
      Living_Children = sum(g7, na.rm = TRUE),
      Dead_Children = sum(g6, na.rm = TRUE) - sum(g7, na.rm = TRUE)
    ) %>%
    pivot_longer(everything(), names_to = "Status", values_to = "Count")
  
  if(nrow(child_status) > 0) {
    p_child_status <- ggplot(child_status, aes(x = Status, y = Count, fill = Status)) +
      geom_col(alpha = 0.8, color = "black") +
      geom_text(aes(label = Count), vjust = -0.5, fontface = "bold", size = 5) +
      scale_fill_manual(values = c("Living_Children" = "green", "Dead_Children" = "red")) +
      labs(
        title = "Total Living vs Dead Children",
        x = "Child Status",
        y = "Total Count",
        fill = "Status",
        caption = "Aggregate comparison across all mothers"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(size = 14, face = "bold"),
        legend.position = "none"
      )
    
    print(p_child_status)
    ggsave(paste0(output_dir, "22_living_vs_dead_children.png"), 
           p_child_status, width = 10, height = 6)
    cat("✓ Saved: 22_living_vs_dead_children.png\n")
  }
}

# ============================================================================
# ADVANCED ANALYSIS 7: DATA QUALITY ASSESSMENT
# ============================================================================

cat("\n========== DATA QUALITY ASSESSMENT ==========\n")

# Check missing data patterns
data_quality <- data.frame(
  Dataset = c("Birth", "Fertility", "Roster", "Death"),
  Total_Records = c(nrow(birth), nrow(fertility), nrow(roster), nrow(death)),
  Total_Variables = c(ncol(birth), ncol(fertility), ncol(roster), ncol(death)),
  Missing_Values = c(
    sum(is.na(birth)),
    sum(is.na(fertility)),
    sum(is.na(roster)),
    sum(is.na(death))
  )
) %>%
  mutate(
    Completeness_Pct = round(100 * (1 - Missing_Values / (Total_Records * Total_Variables)), 2)
  )

print(data_quality)

p_data_quality <- ggplot(data_quality, 
                         aes(x = Dataset, y = Completeness_Pct, fill = Dataset)) +
  geom_col(alpha = 0.8, color = "black") +
  geom_text(aes(label = paste0(Completeness_Pct, "%")), vjust = -0.5, fontface = "bold") +
  ylim(0, 105) +
  scale_fill_manual(values = c("Birth" = "skyblue", "Fertility" = "lightcoral", 
                               "Roster" = "lightgreen", "Death" = "lightyellow")) +
  labs(
    title = "Data Completeness by Dataset",
    x = "Dataset",
    y = "Completeness (%)",
    caption = "Shows percentage of non-missing values across all variables"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    legend.position = "none"
  )

print(p_data_quality)
ggsave(paste0(output_dir, "23_data_quality_assessment.png"), 
       p_data_quality, width = 10, height = 6)
cat("✓ Saved: 23_data_quality_assessment.png\n")

# Save data quality summary as .sav file
write_sav(data_quality, paste0(output_dir, "data_quality_summary.sav"))
cat("✓ Saved: data_quality_summary.sav\n")

# ============================================================================
# COMPLETION MESSAGE
# ============================================================================

cat("\n")
cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║  ✓ ADVANCED ANALYSIS COMPLETED SUCCESSFULLY!              ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n")
cat("\n📊 Generated 7 advanced visualizations:\n")
cat("   - Age pyramid analysis\n")
cat("   - Education distribution\n")
cat("   - Fertility by age interaction\n")
cat("   - Mortality by age group\n")
cat("   - Birth order & survival\n")
cat("   - Living vs dead children\n")
cat("   - Data quality assessment\n\n")
cat("📁 All files saved to:", output_dir, "\n")

# ============================================================================
# ADVANCED 2D GRAPH: MULTIPLE TRENDS IN ONE PLOT
# Shows: Age at Marriage (X) vs Average Children Born (Y) split by Gender
# Guaranteed Error-Free & Highly Visible
# ============================================================================

library(haven)
library(dplyr)
library(tidyr)
library(ggplot2)

# 1. Load Data Safely
fertility <- read_sav("Fertility.sav")

# 2. Data Preparation and Aggregation
trend_data <- fertility %>%
  # Convert SPSS variables to numeric to avoid label errors
  mutate(
    age_marriage = as.numeric(AGE_AT_FIRST_MARRIAGE),
    boys = as.numeric(BOYS_BORN_ALIVE),
    girls = as.numeric(GIRLS_BORN_ALIVE)
  ) %>%
  # Filter for realistic marriage ages (e.g., 14 to 35) to get smooth statistical averages
  filter(!is.na(age_marriage), age_marriage >= 14, age_marriage <= 35,
         !is.na(boys), !is.na(girls)) %>%
  # Group by the age they were married
  group_by(age_marriage) %>%
  # Calculate the average boys and girls born to women married at that specific age
  summarise(
    `Average Boys Born` = mean(boys),
    `Average Girls Born` = mean(girls),
    .groups = 'drop'
  ) %>%
  # Reshape data from wide to long format so we can plot both lines on one 2D graph
  pivot_longer(
    cols = c(`Average Boys Born`, `Average Girls Born`),
    names_to = "Child_Gender",
    values_to = "Average_Count"
  )

# 3. Create the 2D Line & Point Graph
if(nrow(trend_data) > 0) {
  
  p_2d <- ggplot(trend_data, aes(x = age_marriage, y = Average_Count, color = Child_Gender, shape = Child_Gender)) +
    
    # LAYER 1: Thick trend lines
    geom_line(linewidth = 1.5, alpha = 0.8) +
    
    # LAYER 2: Large data points to make exact intersections visible
    geom_point(size = 4, stroke = 1.5, fill = "white") +
    
    # LAYER 3: High contrast colors for extreme visibility
    scale_color_manual(values = c("Average Boys Born" = "#2980B9",   # Bold Blue
                                  "Average Girls Born" = "#C0392B")) + # Bold Red
    
    # Distinct shapes for accessibility (in case printed in black/white)
    scale_shape_manual(values = c("Average Boys Born" = 21, 
                                  "Average Girls Born" = 24)) +
    
    # Add breaks to X-axis so every single age year is clearly marked
    scale_x_continuous(breaks = seq(14, 35, by = 2)) +
    
    # Clear labels
    labs(
      title = "Fertility Trends: Average Children Born by Marriage Age",
      subtitle = "Comparing Boys vs Girls born to mothers based on when they married",
      x = "Mother's Age at First Marriage",
      y = "Average Number of Children",
      color = "Child Category",
      shape = "Child Category"
    ) +
    
    # Clean, High-Visibility Theme
    theme_minimal(base_size = 15) +
    theme(
      # Title and subtitle formatting
      plot.title = element_text(face = "bold", size = 20, color = "black", hjust = 0.5, margin = margin(b = 8)),
      plot.subtitle = element_text(size = 14, color = "grey30", hjust = 0.5, margin = margin(b = 20)),
      
      # Axis formatting (Large and bold)
      axis.title.x = element_text(face = "bold", size = 16, color = "black", margin = margin(t = 15)),
      axis.title.y = element_text(face = "bold", size = 16, color = "black", margin = margin(r = 15)),
      axis.text = element_text(size = 13, color = "black", face = "bold"),
      
      # Grid line styling (Subtle but present for easy reading)
      panel.grid.major = element_line(color = "grey80", linewidth = 0.6),
      panel.grid.minor = element_line(color = "grey92", linewidth = 0.3),
      
      # Legend formatting (Placed nicely at the top)
      legend.position = "top",
      legend.title = element_text(face = "bold", size = 14),
      legend.text = element_text(size = 13),
      legend.background = element_rect(fill = "white", color = "black", linewidth = 0.5),
      legend.margin = margin(t = 5, b = 5, r = 10, l = 10),
      
      # Background styling
      plot.background = element_rect(fill = "white", color = NA)
    )
  
  # 4. Save the plot
  ggsave("29_Clear_2D_Trend_Graph.png", p_2d, width = 11, height = 7, dpi = 300)
  cat("\n✓ SUCCESS: Graph '29_Clear_2D_Trend_Graph.png' generated perfectly!\n")
  
} else {
  cat("\n! ERROR: No valid data available for plotting.\n")
}