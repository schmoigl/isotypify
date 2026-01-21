# Load required libraries
library(readODS)
library(tidyverse)

# Load data from Tabelle_1 sheet in the ODS file
data_raw <- read_ods(
  path = "data/Durchschnittliche_Zeitverwendung_2021-22.ods",
  sheet = "Tabelle_16",
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
    ),
    # Replace NA values with 0
    wert_numeric = replace_na(wert_numeric, 0)
  ) %>%
  # Remove rows with NA aktivitaet and filter to men and women only
  filter(!is.na(aktivitaet)) %>%
  filter(!str_starts(aktivitaet, "Q:")) %>%
  filter(geschlecht %in% c("Frauen", "Männer")) %>%
  # filter(!aktivitaet %in% c(
  #   "Nicht näher bestimmte Zeitverwendung", 
  #   "Soziale Kontakte und Freizeit", 
  #   "Schlafen", 
  #   "Essen und andere persönliche Tätigkeiten"
  # )) %>%
  select(aktivitaet, geschlecht, metrik, wert_numeric)
  # group_by(aktivitaet)  %>%
  # filter(!is.na(sum(wert_numeric)))

# Define aggregated categories in order
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

# Get unique aktivitaet values in order of appearance
aktivitaet_order <- data_long %>%
  distinct(aktivitaet) %>%
  pull(aktivitaet)

# Create mapping: assign each aktivitaet to its parent kategorie
# by finding which aggregated category came before it
kategorie_map <- tibble(aktivitaet = aktivitaet_order) %>%
  mutate(
    is_aggregated = aktivitaet %in% aggregated_categories,
    kategorie = NA_character_
  )

# Fill in the kategorie based on preceding aggregated category
current_kategorie <- NA_character_
for (i in seq_len(nrow(kategorie_map))) {
  if (kategorie_map$is_aggregated[i]) {
    current_kategorie <- kategorie_map$aktivitaet[i]
  }
  kategorie_map$kategorie[i] <- current_kategorie
}

# Keep in long format but pivot metrics wider for each activity-geschlecht combination
data_clean <- data_long %>%
  # Join to get kategorie

  left_join(kategorie_map %>% select(aktivitaet, kategorie), by = "aktivitaet") %>%
  # Remove rows where aktivitaet is an aggregated category (keep only sub-categories)
  filter(!aktivitaet %in% aggregated_categories) %>%
  pivot_wider(
    names_from = metrik,
    values_from = wert_numeric
  ) %>%
  # Reorder columns
  select(kategorie, aktivitaet, geschlecht, everything()) |>
  filter(!kategorie %in% c(
    "Nicht näher bestimmte Zeitverwendung"
    )
  ) %>%
  # Calculate difference between women and men (Frauen - Männer)
  group_by(kategorie, aktivitaet) %>%
  mutate(
    differenz_anteil = anteil_ausuebende_prozent[geschlecht == "Frauen"] -
                       anteil_ausuebende_prozent[geschlecht == "Männer"],
    differenz_zeit = durchschnittliche_zeit_h[geschlecht == "Frauen"] -
                     durchschnittliche_zeit_h[geschlecht == "Männer"],
    # Relative difference: (Frauen - Männer) / average * 100
    # Using the average of both values as base to avoid division issues
    differenz_rel = {
      frauen_val <- anteil_ausuebende_prozent[geschlecht == "Frauen"]
      maenner_val <- anteil_ausuebende_prozent[geschlecht == "Männer"]
      avg_val <- (frauen_val + maenner_val) / 2
      if_else(avg_val > 0, (frauen_val - maenner_val) / avg_val * 100, 0)
    },
    # Sum of participation rates for filtering
    summe_anteil = sum(anteil_ausuebende_prozent),
    # Check if both genders are close to 100% (200 - sum < 4 means avg > 98%)
    close_to_100 = (200 - summe_anteil) < 2
  ) %>%
  # Remove activities where combined participation is below 4 percentage points
  # OR where both genders are very close to 100% (less than 4pp away combined)
  filter(summe_anteil >= 2, !close_to_100) %>%
  select(-summe_anteil, -close_to_100) %>%
  ungroup()

# Display the cleaned data
print(data_clean)
print(paste("Total rows:", nrow(data_clean)))

# Save to CSV
write_csv(data_clean, "data/zeitverwendung_long.csv")
