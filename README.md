# Is Price Associated with the Quality of Medicines? Evidence from Active Pharmaceutical Ingredient Testing in Nigeria

Replication code for the paper by Marie C. Montás, Chimezie Anyakora, and Elisa M. Maffioli, published in *PLOS ONE* (2025). Contact: Marie C. Montás, Department of Global Health and Population, Harvard T.H. Chan School of Public Health (mariemontas@fas.harvard.edu).

## Abstract

Determining the quality of medicines remains a challenge in low- and middle-income countries, where regulatory oversight varies and testing capacity is limited, so price is often used as a proxy for quality. We conducted a mystery-shopper survey in more than 1,200 retail pharmacies across urban and rural areas in Nigeria's six geopolitical zones, purchasing one sample from a list of twenty branded medicines. A subsample of 246 medicines was tested with High-Performance Liquid Chromatography to measure active pharmaceutical ingredient content. Using probit regressions that control for pharmacy and sample characteristics, we find that a 1 percent increase in price is associated with a 16.7 percentage point increase in the probability of passing the laboratory test, and a price-only model reaches an out-of-sample AUC of 0.82. Brand organization and visible expiration dates may also signal quality, while other observable characteristics show weaker and less consistent associations.

## Contents

```
code/stata/   cleaning and analysis do-files
code/R/       figures and maps
```

Data, tables, and figures are not included.

## Pipeline

Set `global NGA_ROOT` to the project folder (the folder that holds `analysis/`, `tables/`, `figures/`, and `lab/`); if it is not set, Stata uses the current working directory. The R scripts read the `NGA_ROOT` environment variable in the same way.

| Stage | What it does |
|---|---|
| 01 | `01_cleaning.do`: imports the mystery-shopper survey and sample-selection file, merges the laboratory results for the 246 tested samples, and builds the price, pharmacy, and sample variables |
| 02 | `02_analysis.do`: descriptive tables, probit models of passing the HPLC test on log price and observable characteristics, ROC and AUC analysis, and stratified results by therapeutic class |
| 03 | `03_figures.R`: paper figures |
| 04 | `04_map.R`: maps of sampled pharmacies for Nigeria and the main cities |

## Software

StataNow 19.5 (MP). R 4.3.3 with `haven` 2.5.5, `dplyr` 1.1.4, `ggplot2` 3.5.2, `sf` 1.0.21, `tmap` 4.0, and `rnaturalearth` 1.0.1.

## Data access

The pharmacy survey data are not redistributed because they identify individual retail pharmacies. Laboratory results for the 246 tested medicines are available in the supplementary material of Maffioli and Anyakora (2025), *PLOS ONE*, doi:10.1371/journal.pone.0319523. The study was funded by USAID Development Innovation Ventures (7200AA21FA00006) and the University of Michigan.

## Citation

Montás, M. C., Anyakora, C., and Maffioli, E. M. (2025). Is price associated with the quality of medicines? Evidence from active pharmaceutical ingredient testing in Nigeria. *PLOS ONE*, 20(12): e0338739. doi:10.1371/journal.pone.0338739
