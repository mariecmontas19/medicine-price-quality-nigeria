#Code for graphs for WQEII paper

rm(list = ls())

##Figure 1##
install.packages("haven")
install.packages("ggplot2")
install.packages("dplyr")
if (!requireNamespace("scales", quietly = TRUE)) install.packages("scales")
install.packages(c("ggplot2", "sf", "rnaturalearth", "rnaturalearthdata", "dplyr", "maps"))
library(ggplot2)
library(sf)
library(rnaturalearth)
library(dplyr)
library(maps)
library(scales)
library(haven)
library(psych)


root <- Sys.getenv("NGA_ROOT", unset = getwd())  # project folder
setwd(file.path(root, "analysis", "dta"))
data <- read_dta("data_merge.dta")

str(data)
summary(data$no_issues_1)
data$no_issues_1 <- factor(data$no_issues_1, levels = 1:6)
ggplot(data, aes(x = no_issues_1)) +
  geom_bar(aes(y = ..count..), fill = "darkblue") +
  geom_text(stat = 'count', aes(label = ..count.., y = ..count..), 
            position = position_stack(vjust = 0.5), 
            color = "white") +
  scale_y_continuous(breaks = seq(0, 900, by = 100)) +
  labs(title = "Distribution of Quality in Pharmacies", x = "Quality components", y = "N") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("figure1.png", plot = last_plot(), width = 10, height = 6)

##Figure 2a Full sample
summary(data$price)
data$ln_price <- log(data$price)
# Calculate the mean of ln_price
mean_ln_price <- mean(data$ln_price, na.rm = TRUE)
mean_ln_price_lab <- mean(data_lab$ln_price, na.rm = TRUE)

# Normalize ln_price
data$norm_ln_price <- data$ln_price - mean_ln_price
data_lab$norm_ln_price_lab <- data_lab$ln_price - mean_ln_price

summary(data$ln_price)
figure1 <-ggplot(data = data, aes(x = ln_price)) +
  geom_density(color = "darkblue", alpha = 0.5) +  # Fills the density plot with blue color and sets transparency
  scale_y_continuous(labels = label_number(scale = 1, accuracy = 0.01)) +
  expand_limits(x = 0) +
  labs(title = "Log(drug price) raw distribution for full sample", x = "Price(ln)", y = "Density") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
print(figure1)
ggsave("figure1.png", plot = last_plot(), width = 10, height = 6)

#Figure 2b#Lab sample
data_lab <- read_dta("data_merge_only_246.dta")
data_lab$ln_price_lab <- log(data_lab$price)
summary(data_lab$ln_price)
data_lab$lab_matched <- factor(data_lab$lab_matched, levels = c("0", "1"), labels = c("Failed", "Passed"))
summary(data_lab$lab_matched)

# Calculate density with confidence intervals
density_data <- data_lab %>%
  group_by(lab_matched) %>%
  do({
    d <- density(.$ln_price_lab)
    data.frame(
      x = d$x,
      y = d$y,
      ymin = d$y - 1.96 * (d$y / sqrt(length(.$ln_price_lab))),  # Approximate 95% CI
      ymax = d$y + 1.96 * (d$y / sqrt(length(.$ln_price_lab))),
      lab_matched = unique(.$lab_matched)
    )
  })

# Plot the density with confidence interval lines
figure2 <- ggplot(data = density_data, aes(x = x, y = y, color = lab_matched)) +
  geom_line() +  # Main density line
  geom_line(aes(y = ymin), linetype = "dashed") +  # Lower bound of CI
  geom_line(aes(y = ymax), linetype = "dashed") +  # Upper bound of CI
  scale_y_continuous(labels = scales::label_number(scale = 1, accuracy = 0.01)) +
  expand_limits(x = 0) +
  labs(
    title = "Log(drug price) raw distributions for failing and non-failing drugs",
    x = "Price(Ln)",
    y = "Density",
    color = "Laboratory test"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

print(figure2)
ggsave("figure2.png", plot = last_plot(), width = 10, height = 6)

#With non CI 
figure2 <-ggplot(data = data_lab, aes(x = ln_price_lab, color = lab_matched)) + 
  geom_density() +
  scale_y_continuous(labels = label_number(scale = 1, accuracy = 0.01)) +
  expand_limits(x = 0) + 
  labs(title = "Log(drug price) raw distributions for failing and non-failing drugs", x = "Price(Ln)", y = "Density", color = "Laboratory test") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
print(figure2)
ggsave("figure2.png", plot = last_plot(), width = 10, height = 6)
failed_ln_price <- data_lab$ln_price[data_lab$lab_matched == "Failed"]
passed_ln_price <- data_lab$ln_price[data_lab$lab_matched == "Passed"]
KS_test <- ks.test(failed_ln_price, passed_ln_price)
print(KS_test)

#Figure 3#Lab sample by type of drug 
# Calculate density with confidence intervals for each drug type and lab result
density_data <- data_lab %>%
  group_by(drug_type, lab_matched) %>%
  do({
    d <- density(.$ln_price_lab)
    data.frame(
      x = d$x,
      y = d$y,
      ymin = d$y - 1.96 * (d$y / sqrt(length(.$ln_price_lab))),  # Approximate 95% CI
      ymax = d$y + 1.96 * (d$y / sqrt(length(.$ln_price_lab))),
      lab_matched = unique(.$lab_matched),
      drug_type = unique(.$drug_type)
    )
  })
# Plot the density with confidence interval lines in facets
figure3 <- ggplot(data = density_data, aes(x = x, y = y, color = lab_matched)) +
  geom_line() +  # Main density line
  geom_line(aes(y = ymin), linetype = "dashed") +  # Lower bound of CI
  geom_line(aes(y = ymax), linetype = "dashed") +  # Upper bound of CI
  scale_y_continuous(labels = scales::label_number(scale = 1, accuracy = 0.01)) +
  scale_x_continuous(labels = scales::label_number(scale = 1, accuracy = 1)) +
  expand_limits(x = 0) +
  labs(
    title = "Log(drug price) raw distributions for failing and non-failing drugs",
    x = "Price(Ln)",
    y = "Density",
    color = "Laboratory test"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5)) +
  facet_wrap(~ drug_type, scales = "free")  # Facet by drug type
print(figure3)
ggsave("figure3.png", plot = last_plot(), width = 10, height = 6)

#With no CI 
figure3 <- ggplot(data = data_lab, aes(x = ln_price_lab, color = lab_matched)) + 
  geom_density() +
  scale_y_continuous(labels = label_number(scale = 1, accuracy = 0.01)) +
  scale_x_continuous(labels = label_number(scale = 1, accuracy = 1))  +
  expand_limits(x = 0) +
  labs(title = "Log(drug price) raw distributions for failing and non-failing drugs", x = "Price(Ln)", y = "Density", color = "Laboratory test") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5)) +
  facet_wrap(~ drug_type, scales = "free")
print(figure3)
ggsave("figure3.png", plot = last_plot(), width = 10, height = 6)

