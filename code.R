#### Packages Installation and Importing ----
install.packages(c("ggplot2", "ggmap", "sf", "osmdata", "rosm",
                   "readxl", "dplyr", "plotly", "patchwork", "tidyr"))

library(ggplot2)
library(ggmap) 
library(sf)        
library(osmdata)   
library(rosm)
library(readxl)
library(dplyr)
library(plotly)
library(patchwork)
library(tidyr)

#### Data preprocessing ----
# read the data from the excel file
data <- read_excel("nmftmarkets.xlsx")

# function to clean and impute blank names
clean_blank_names <- function(data, col, condition_col) {
  # Replace values containing 'BLANK' with NA
  data[[col]] <- ifelse(grepl("BLANK", data[[col]], fixed = TRUE), NA, data[[col]])
  mean_value <- mean(as.numeric(data[[col]]), na.rm = TRUE) # Ensure numeric calculations
  # Replace NA with mean value only if condition_col equals 1
  data[[col]] <- ifelse(is.na(data[[col]]) & data[[condition_col]] == 1,
                        mean_value,
                        data[[col]])
  return(data)
}

# define condition columns and weekly numeric columns
condition_cols <- c('openmonday_mkv', 'opentuesday_mkv',
                    'openwednesday_mkv', 'openthursday_mkv',
                    'openfriday_mkv', 'opensaturday_mkv', 'opensunday_mkv')

weekly_numeric_cols <- list(
  c('monnostallsavail_mkv', 'monnostallsocc_mkv', 'monnostalltrad_mkv'),
  c('tuenostallsavail_mkv', 'tuenostallsocc_mkv', 'tuenostalltrad_mkv'),
  c('wednostallsavail_mkv', 'wednostallsocc_mkv', 'wednostalltrad_mkv'),
  c('thunostallsavail_mkv', 'thunostallsocc_mkv', 'thunostalltrad_mkv'),
  c('frinostallsavail_mkv', 'frinostallsocc_mkv', 'frinostalltrad_mkv'),
  c('satnostalltrad_mkv'),
  c('sunnostallsavail_mkv', 'sunnostallsocc_mkv', 'sunnostalltrad_mkv')
)

# apply the cleaning function to relevant columns
for (i in seq_along(condition_cols)) {
  condition_col <- condition_cols[i]
  day_numeric_cols <- weekly_numeric_cols[[i]]
  
  for (col in day_numeric_cols) {
    data <- clean_blank_names(data, col, condition_col)
  }
}

# calculate average stalls available and occupied
data <- data %>%
  mutate(across(c(monnostallsavail_mkv, tuenostallsavail_mkv, wednostallsavail_mkv,
                  thunostallsavail_mkv, frinostallsavail_mkv, sunnostallsavail_mkv,
                  satnostalltrad_mkv,
                  monnostallsocc_mkv, tuenostallsocc_mkv, wednostallsocc_mkv,
                  thunostallsocc_mkv, frinostallsocc_mkv, sunnostallsocc_mkv,
                  satnostalltrad_mkv), ~ as.numeric(.))) %>%
  mutate(
    avg_stalls_available = rowMeans(select(., monnostallsavail_mkv, tuenostallsavail_mkv, wednostallsavail_mkv,
                                           thunostallsavail_mkv, frinostallsavail_mkv, sunnostallsavail_mkv,
                                           satnostalltrad_mkv), na.rm = TRUE),
    avg_stalls_occupied = rowMeans(select(., monnostallsocc_mkv, tuenostallsocc_mkv, wednostallsocc_mkv,
                                          thunostallsocc_mkv, frinostallsocc_mkv, sunnostallsocc_mkv,
                                          satnostalltrad_mkv), na.rm = TRUE),
    weekly_operational_days = rowSums(select(., all_of(condition_cols)), na.rm = TRUE)
  )
# clean market type
data$overall_market_type <- ifelse(data$type_specific_mkv %in% c('Food', 'Speciality Food and Drink'),
                                   'Food and Drink',
                                   ifelse(is.na(data$type_specific_mkv) | data$type_specific_mkv == '/',
                                          'BLANK',
                                          data$type_specific_mkv))
# filter data to exclude markets with "BLANK" in the market type
data <- data[data$overall_market_type != 'BLANK', ]
# remove trailing space in column name
names(data)[names(data) == "market_In_Out_Mkv "] <- "market_In_Out_Mkv"

#### Spatial Plot ----
# register Stadia Maps API key
register_stadiamaps("c9a4fb71-ddc6-4fe5-be6b-f9a04a85dd25")

# define the UK boundary
uk <- c(left = -10, bottom = 49, right = 2, top = 59)

# fetch the Stadia map tiles
uk_basemap <- get_stadiamap(
  bbox = uk,
  zoom = 6,
  maptype = "stamen_toner_lite"
)

custom_colors <- c(
  "Retail" = "#B0BEC5",  # light grey
  "Food and Drink" = "#FF9800",  # orange
  "Food and Drink/Arts and Crafts" = "#2196F3",  # blue
  "General" = "#4CAF50",  # green
  "Arts and Crafts" = "#9C27B0",  # purple
  "Agricultural" = "#795548",  # brown
  "Antiques" = "#FFD700",  # gold
  "Car Boot" = "#F44336"  # red
)

# plot the map with ggmap
map_plot <- ggmap(uk_basemap) +
  geom_point(
    data = data,
    aes(x = longitude, 
        y = latitude, 
        color = overall_market_type,
        size = ifelse(overall_market_type == "Retail", 1, 3),  # smaller for "Retail"
        shape = ifelse(overall_market_type == "Retail", 17, 16),  # distinct shape for "Retail"
        text = paste("Market Name:", name_mkv, "<br>",
                     "Market Type:", overall_market_type)  # hover text
    ),
    alpha = 0.7
  ) + 
  scale_color_manual(values = custom_colors, 
                     breaks = names(sort(table(data$overall_market_type), 
                                         decreasing = TRUE))) +  # apply custom colors
  scale_size_identity() +
  scale_shape_identity() +
  labs(
    title = "Market Distribution Across the UK",
    x = "Longitude",
    y = "Latitude",
    color = "Market Type"
  ) +
  theme_minimal()
# convert ggplot to plotly for interactivity
ggplotly(map_plot, tooltip = "text")

#### Bar Plot ----
bar_chart <- data %>%
  group_by(overall_market_type, market_In_Out_Mkv) %>%
  summarize(avg_occupancy = mean(avg_stalls_occupied, na.rm = TRUE)) %>%
  ggplot(aes(
    x = reorder(overall_market_type, avg_occupancy), 
    y = avg_occupancy, 
    fill = overall_market_type,
    alpha = market_In_Out_Mkv   
  )) +
  geom_bar(stat = "identity", position = "stack", width = 0.8) + # Stacked Bar
  coord_flip() +
  scale_fill_manual(values = custom_colors) +
  scale_alpha_manual(values = c(
    "Indoor" = 1,
    "Outdoor" = 0.7,
    drop = FALSE
  )) + 
  labs(
    title = "Average Stalls Occupied by Market Type",
    x = "Market Type",
    y = "Average Stalls Occupied",
    fill = "Market Type",
    alpha = "Type of Market Location"
  ) +
  theme_minimal()
print(bar_chart)

#### Heat Map ----
heatmap_data <- data %>%
  pivot_longer(cols = starts_with("open"), names_to = "day", values_to = "open_status") %>%
  group_by(day) %>%
  summarize(avg_occupancy = mean(open_status * avg_stalls_occupied, na.rm = TRUE))

# clean the day name
heatmap_data$day <- gsub("^open", "", heatmap_data$day)
heatmap_data$day <- gsub("_mkv$", "", heatmap_data$day)

# arrange heatmap_data in standard weekday order
heatmap_data$day <- factor(
  heatmap_data$day,
  levels = c("monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"))

heatmap <- ggplot(heatmap_data, aes(x = day, y = avg_occupancy, fill = avg_occupancy)) +
  geom_tile() +
  scale_fill_gradientn(
    colors = c("#FFA07A", "#FF6347", "#FF4500", "#8B0000", "#800000"),
    values = scales::rescale(c(0, 0.2, 0.4, 0.6, 1))
  ) +
  labs(title = "Average Occupancy by Day of the Week", x = "Day", y = "Average Occupancy") +
  theme_minimal()
print(heatmap)

#### Scatter Plot ----
scatter_plot <- ggplot(data, aes(
  x = name_loc, 
  y = avg_stalls_occupied,
  size = avg_stalls_available,
  color = overall_market_type  
)) +
  geom_point(shape = 16, alpha = 0.7) +
  scale_size_continuous(name = "Average Stalls Available") +
  scale_color_manual(values = custom_colors) +
  labs(
    title = "Relationship Between Market Type and Average Stalls Occupied",
    x = "Market Type",
    y = "Average Stalls Occupied",
    color = "Market Type"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
print(scatter_plot)

#### Bringing all plots together into a composite visualisation ----
composite_plot <- (map_plot | scatter_plot) /
  (bar_chart | heatmap)
print(composite_plot)
