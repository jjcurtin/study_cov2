# R script to analyze results of simulations

# EDIT THIS FOR QUESTION AND DATE
# options: selection, likelihood, omitted, reliability
question <- "likelihood"
date_run <- "2026-11-25"

# load packages
library(tidyverse)

# set path to results
path_chtc <- format_path(str_c("cov2/chtc/", question, "_", date_run))

# set path to processed data
path_processed <- format_path("cov2")
                         
# import combined results
data <- data.table::fread(here::here(path_chtc, "batch_results.csv"))

# calculate average type I error
data <- data |>
  mutate(
    type_i =
      case_when(
        x_effect == "zero" & p_value < .05 ~ 1,
        x_effect == "zero" & p_value >= .05 ~ 0,
        TRUE ~ NA
    ),
    type_ii =
      case_when(
        x_effect == "non_zero" & p_value >= .05 ~ 1,
        x_effect == "non_zero" & p_value < .05 ~ 0,
        TRUE ~ NA
      ),
    count = 1
  )

# specify grouping variables for each RQ

if (question == "selection"){
  grouping_vars <- c("dgp", "method")
}

if (question == "likelihood"){
  grouping_vars <- c("condition")
}

if (question == "omitted"){
  grouping_vars <- c("b_cx", "b_cy", "n_covs")
}

if (question == "reliability"){
  grouping_vars <- c("e_c")
}

# compute average parameter estimates and type I & type II error rates by research context

file_name <- paste0("results_", question, ".csv")

results <- data |>
  group_by(across(c(all_of(grouping_vars), "x_effect"))) |>
  summarise(across(c("type_i", "type_ii", "estimate"), ~mean(.x, na.rm = TRUE)),
            count = sum(count, na.rm = TRUE)) |>
  mutate(
    across(where(is.numeric) & !count, ~sprintf("%.2f", .x)),
    across(c("type_i", "type_ii"), ~ifelse(.x == "NaN", "--", .x))) |>
  arrange(x_effect, across(all_of(grouping_vars))) |>
  select(x_effect, everything())

# export data

results|> write.csv(here::here(path_processed, file_name), row.names = FALSE)
  