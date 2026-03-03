# Load required libraries
library(readODS)
library(tidyverse)

# Load data from Tabelle_16 sheet in the ODS file
data_raw <- read_ods(
  path = "data/Durchschnittliche_Zeitverwendung_2021-22.ods",
  sheet = "Tabelle_16",
  skip = 3,
  col_types = NA
)

# Set proper column names
colnames(data_raw) <- c(
  "activity",
  "women_avg_hours",
  "women_pct",
  "women_participant_hours",
  "men_avg_hours",
  "men_pct",
  "men_participant_hours",
  "total_avg_hours",
  "total_pct",
  "total_participant_hours"
)

# Convert to long format
data_long <- data_raw %>%
  mutate(across(everything(), as.character)) %>%
  pivot_longer(
    cols = -activity,
    names_to = "column",
    values_to = "value"
  ) %>%
  mutate(
    gender = case_when(
      str_starts(column, "women") ~ "women",
      str_starts(column, "men")   ~ "men",
      str_starts(column, "total") ~ "total",
      TRUE ~ column
    ),
    metric = case_when(
      str_ends(column, "participant_hours") ~ "participant_hours",
      str_ends(column, "avg_hours")         ~ "avg_hours",
      str_ends(column, "pct")               ~ "participation_pct",
      TRUE ~ column
    )
  ) %>%
  mutate(
    value = case_when(
      str_detect(value, ":") ~ {
        time_parts <- str_split(value, ":", simplify = TRUE)
        as.numeric(time_parts[, 1]) + as.numeric(time_parts[, 2]) / 60
      },
      str_detect(value, ",") ~ as.numeric(str_replace(value, ",", ".")),
      TRUE ~ as.numeric(value)
    )
  ) %>%
  filter(!is.na(activity)) %>%
  filter(!str_starts(activity, "Q:")) %>%
  filter(gender %in% c("women", "men")) %>%
  select(activity, gender, metric, value)

# Define aggregated (top-level) categories in order of appearance
aggregated_categories <- c(
  "Schlafen",
  "Essen und andere persönliche Tätigkeiten",
  "Erwerbstätigkeit",
  "Aus- und Weiterbildung",
  "Sorgearbeit in Haushalt und Familie",
  "Freiwilligentätigkeiten",
  "Soziale Kontakte und Freizeit",
  "Nicht näher bestimmte Zeitverwendung"
)

# Get unique activity values in order of appearance
activity_order <- data_long %>%
  distinct(activity) %>%
  pull(activity)

# Map each activity to its parent category
# based on the preceding aggregated category in the data
category_map <- tibble(activity = activity_order) %>%
  mutate(
    is_aggregated = activity %in% aggregated_categories,
    category = NA_character_
  )

current_category <- NA_character_
for (i in seq_len(nrow(category_map))) {
  if (category_map$is_aggregated[i]) {
    current_category <- category_map$activity[i]
  }
  category_map$category[i] <- current_category
}

# Pivot metrics wide and compute gender differences
data_clean <- data_long %>%
  left_join(category_map %>% select(activity, category), by = "activity") %>%
  filter(!activity %in% aggregated_categories) %>%
  pivot_wider(names_from = metric, values_from = value) %>%
  select(category, activity, gender, everything()) %>%
  filter(!category %in% c("Nicht näher bestimmte Zeitverwendung")) %>%
  group_by(category, activity) %>%
  mutate(
    diff_participation = (
      participation_pct[gender == "women"] -
      participation_pct[gender == "men"]
    ),
    diff_hours = (
      avg_hours[gender == "women"] -
      avg_hours[gender == "men"]
    ),
    diff_relative = {
      women_val <- participation_pct[gender == "women"]
      men_val   <- participation_pct[gender == "men"]
      avg_val   <- (women_val + men_val) / 2
      if_else(avg_val > 0, (women_val - men_val) / avg_val * 100, 0)
    }
  ) %>%
  filter(!is.na(participation_pct)) %>%
  ungroup()

print(data_clean)
print(paste("Total rows:", nrow(data_clean)))

write_csv(data_clean, "data/zeitverwendung_long.csv")
