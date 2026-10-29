# Load necessary libraries
library(ggplot2)
library(dplyr)
library(sf)
install.packages("tmap")
library(tmap)
library(grid)

# Load the data
library(haven)
data_merge <- read_dta("data_merge.dta")
View(data_merge)

data <- data_merge
# Check the data structure
str(data)



# Load a shapefile of Nigeria for the map
# You may need to download a shapefile of Nigeria if you don't already have one
root <- Sys.getenv("NGA_ROOT", unset = getwd())  # project folder
shapefile_path <- file.path(root, "analysis", "dta", "gadm41_NGA_shp")
nigeria_sf <- st_read(file.path(shapefile_path, "gadm41_NGA_1.shp"))
state_sf <- st_read(file.path(shapefile_path, "gadm41_NGA_2.shp"))
# Convert the data to an sf object

all_data <- data_merge
names(all_data)[names(all_data) == "_gpscoordinates_latitude"] <- "lat"
names(all_data)[names(all_data) == "_gpscoordinates_longitude"] <- "long"
#Delete missing values in coordinates
MISSING <- is.na(all_data$lat) | is.na(all_data$long)
sum(MISSING)
data <- subset(all_data, subset = !MISSING)
# Convert the geotype column to a factor for better plotting
data$geotype <- factor(data$geotype, levels = c("1. Urban", "2. Rural"), labels = c("Urban", "Rural"))
names(data)[names(data) == "Location"] <- "geotype"

#Main Nigeria Map 

pharmacies_sf <- st_as_sf(data, coords = c("long", "lat"), crs = 4326)

nigeria <- ggplot() +
  geom_sf(data = nigeria_sf, fill = "lightgray", color = "darkblue") +
  geom_sf(data = pharmacies_sf, aes(color = geotype), size = 1, alpha = 0.7) +
  scale_color_manual(values = c("Urban" = "blue", "Rural" = "darkred")) +
  labs(title = "Pharmacies in six geo-political zones of Nigeria", subtitle = "N=1296", color = "Location") +
  theme_minimal() +
  coord_sf(expand = FALSE) +
  theme_void() +
  theme(
    legend.justification = c(1, 0),
    legend.position = c(1, 0)
  ) +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5))
nigeria
ggsave("figureNigeria.png", plot = last_plot(), width = 10, height = 6)


# Plot maps for each city

#Lagos 
data_lagos <- state_sf %>% filter(NAME_1=="Lagos")
pharmacies_lagos <- st_join(pharmacies_sf, data_lagos)
pharmacies_lagos <- pharmacies_lagos %>% filter(city=="Lagos")
  
lagos <- ggplot() +
    geom_sf(data = data_lagos, fill = "white", color = "darkblue") +
    geom_sf(data = pharmacies_lagos, aes(color = geotype), lwd = 0, size = 0.5, alpha = 0.7) +
    scale_color_manual(values = c("Urban" = "blue", "Rural" = "darkred")) +
    labs(title = "Pharmacies in Lagos", subtitle = "Lagos state, N=264", color = "Location") +
    theme_minimal() +
    theme_void() +
    theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5))
lagos
ggsave("figureLagos.png", plot = last_plot(), width = 10, height = 6)

#Abuja 
data_abuja <- state_sf %>% filter(NAME_2=="Abuja" | NAME_2=="Bwari")
pharmacies_abuja <- st_join(pharmacies_sf, data_abuja)
pharmacies_abuja <- pharmacies_abuja %>% filter(city=="Abuja")

abuja <- ggplot() +
  geom_sf(data = data_abuja, fill = "white", color = "darkblue") +
  geom_sf(data = pharmacies_abuja, aes(color = geotype), lwd = 0, size = 1, alpha = 0.7) +
  scale_color_manual(values = c("Urban" = "blue", "Rural" = "darkred")) +
  labs(title = "Pharmacies in Abuja", subtitle = "Federal Capital Territory state, N=203", color = "Location") +
  theme_minimal() +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5))
abuja
ggsave("figureAbuja.png", plot = last_plot(), width = 10, height = 6)

#Yola 
data_yola <- state_sf %>% filter(NAME_1=="Adamawa")
data_yola <- state_sf %>% filter(NAME_2=="Yola North" | NAME_2=="Yola South" | NAME_2=="Demsa")
pharmacies_yola <- st_join(pharmacies_sf, data_yola)
pharmacies_yola <- pharmacies_yola %>% filter(city=="Yola")

yola <- ggplot() +
  geom_sf(data = data_yola, fill = "white", color = "darkblue") +
  geom_sf(data = pharmacies_yola, aes(color = geotype), lwd = 0, size = 1, alpha = 0.7) +
  scale_color_manual(values = c("Urban" = "blue", "Rural" = "darkred")) +
  labs(title = "Pharmacies in Yola", subtitle = "Adamawa state, N=210", color = "Location") +
  theme_minimal() +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5))
yola
ggsave("figureYola.png", plot = last_plot(), width = 10, height = 6)

#Kano 
data_kano <- state_sf %>% filter(NAME_2=="Gezawa" | NAME_2=="Gwale" | NAME_2=="Fagge"| NAME_2=="Kano" | NAME_2=="Bichi" | NAME_2=="Ungogo" | NAME_2=="Dawakin Tofa" | NAME_2=="Warawa" | NAME_2=="Wudil" | NAME_2=="Dala" | NAME_2=="Tarauni")
pharmacies_kano <- st_join(pharmacies_sf, data_kano)
pharmacies_kano <- pharmacies_kano %>% filter(city=="Kano")

kano <- ggplot() +
  geom_sf(data = data_kano, fill = "white", color = "darkblue") +
  geom_sf(data = pharmacies_kano, aes(color = geotype), lwd = 0, size = 0.5, alpha = 0.7) +
  scale_color_manual(values = c("Urban" = "blue", "Rural" = "darkred")) +
  labs(title = "Pharmacies in Kano", subtitle = "Kano state, N=201", color = "Location") +
  theme_minimal() +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5))
kano
ggsave("figureKano.png", plot = last_plot(), width = 10, height = 6)

#Onitsha
data_onitsha <- state_sf %>% filter(NAME_2=="Onitsha South" | NAME_2=="Onitsha North" | NAME_2=="Idemili North" | NAME_2=="Anambra East" | NAME_2=="Oyi")
pharmacies_onitsha <- st_join(pharmacies_sf, data_onitsha)
pharmacies_onitsha <- pharmacies_onitsha %>% filter(city=="Onitsha")

onitsha <- ggplot() +
  geom_sf(data = data_onitsha, fill = "white", color = "darkblue") +
  geom_sf(data = pharmacies_onitsha, aes(color = geotype), lwd = 0, size = 0.5, alpha = 0.7) +
  scale_color_manual(values = c("Urban" = "blue", "Rural" = "darkred")) +
  labs(title = "Pharmacies in Onitsha", subtitle = "Anambra state, N=200", color = "Location") +
  theme_minimal() +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5))
onitsha
ggsave("figureOnitsha.png", plot = last_plot(), width = 10, height = 6)

#Port Harcourt
data_ph <- state_sf %>% filter(NAME_2=="Port Harcourt"| NAME_2=="Eleme" | NAME_2=="Obio/Akpor" 	| NAME_2=="Etche" |  NAME_2=="Ikwerre")
pharmacies_ph <- st_join(pharmacies_sf, data_ph)
pharmacies_ph <- pharmacies_ph %>% filter(city=="Port Harcourt")

ph <- ggplot() +
  geom_sf(data = data_ph, fill = "white", color = "darkblue") +
  geom_sf(data = pharmacies_ph, aes(color = geotype), lwd = 0, size = 0.5, alpha = 0.7) +
  scale_color_manual(values = c("Urban" = "blue", "Rural" = "darkred")) +
  labs(title = "Pharmacies in Port Harcourt", subtitle = "Rivers state, N=218", color = "Location") +
  theme_minimal() +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5))
ph
ggsave("figurePH.png", plot = last_plot(), width = 10, height = 6)



#Function 
make_map <- function(name2){
data_lagos <- nigeria_shapefile %>% filter(name==name2)
pharmacies_lagos <- st_join(pharmacies_sf, data_lagos)
pharmacies_lagos <- pharmacies_lagos %>% filter(name==name2)

map <- ggplot() +
  geom_sf(data = data_lagos, fill = "white", color = "black") +
  geom_sf(data = pharmacies_lagos, aes(color = geotype), size = 1, alpha = 0.5) +
  scale_color_manual(values = c("1. Urban" = "blue", "2. Rural" = "red")) +
  theme_bw() +
  labs(title = "Pharmacies in Lagos",
       subtitle = "Urban vs. Rural",
       color = "Geotype")
}
map_lagos <- make_map("Lagos")
map_abuja <- make_map("Federal Capital Territory")
