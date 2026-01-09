# Load required libraries
library(readODS)
library(tidyverse)

# Load data from Tabelle_1 sheet in the ODS file
data_raw <- read_ods(
  path = "data/Durchschnittliche_Zeitverwendung_2021-22.ods",
  sheet = "Tabelle_1",
  skip = 3,  # Skip header rows
  col_types = NA  # Read all columns as character to prevent automatic type conversion
)

# Set proper column names
colnames(data_raw) <- c(
  "aktivitaet",
  "frauen_zeit", "frauen_anteil", "frauen_zeit_ausuebende",
  "maenner_zeit", "maenner_anteil", "maenner_zeit_ausuebende",
  "gesamt_zeit", "gesamt_anteil", "gesamt_zeit_ausuebende"
)

# Convert to long format
data_long <- data_raw %>%
  # First ensure all columns are character type
  mutate(across(everything(), as.character)) %>%
  # Pivot to long format for gender groups
  pivot_longer(
    cols = -aktivitaet,
    names_to = "column",
    values_to = "wert"
  ) %>%
  # Extract geschlecht and metrik from column name
  mutate(
    geschlecht = case_when(
      str_starts(column, "frauen") ~ "Frauen",
      str_starts(column, "maenner") ~ "Männer",
      str_starts(column, "gesamt") ~ "Insgesamt",
      TRUE ~ column
    ),
    metrik = case_when(
      str_ends(column, "zeit_ausuebende") ~ "zeit_ausuebende_h",
      str_ends(column, "anteil") ~ "anteil_ausuebende_prozent",
      str_ends(column, "zeit") ~ "durchschnittliche_zeit_h",
      TRUE ~ column
    )
  ) %>%
  # Convert values to numeric
  mutate(
    wert_numeric = case_when(
      str_detect(wert, ":") ~ {
        time_parts <- str_split(wert, ":", simplify = TRUE)
        as.numeric(time_parts[, 1]) + as.numeric(time_parts[, 2]) / 60
      },
      str_detect(wert, ",") ~ as.numeric(str_replace(wert, ",", ".")),
      TRUE ~ as.numeric(wert)
    )
  ) %>%
  # Remove rows with NA aktivitaet and filter to men and women only
  filter(!is.na(aktivitaet)) %>%
  filter(!str_starts(aktivitaet, "Q:")) %>%
  filter(geschlecht %in% c("Frauen", "Männer")) %>%
  filter(!aktivitaet %in% c("Schlafen", "Essen und andere persönliche Tätigkeiten")) %>%
  select(aktivitaet, geschlecht, metrik, wert_numeric)

# Keep in long format but pivot metrics wider for each activity-geschlecht combination
data_clean <- data_long %>%
  pivot_wider(
    names_from = metrik,
    values_from = wert_numeric
  )

# Display the cleaned data
print(data_clean)
print(paste("Total rows:", nrow(data_clean)))

# Save to CSV
write_csv(data_clean, "data/zeitverwendung_long.csv")
