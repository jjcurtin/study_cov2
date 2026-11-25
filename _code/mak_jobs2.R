# R script to write jobs csv for CHTC

# EDIT THIS FOR QUESTION
# options: selection, likelihood, omitted, reliability
question <- "reliability"

library(tidyverse)
source("https://github.com/jjcurtin/lab_support/blob/main/format_path.R?raw=true")

path_chtc <- format_path(str_c("cov2/chtc/", question, "_", Sys.Date()))

# make new directory
dir.create(here::here(path_chtc))
dir.create(here::here(path_chtc, "input"))

# copy other files
file.copy("_code/cov2.sh", here::here(path_chtc, "input"))
file.copy("_code/cov2.sub", here::here(path_chtc, "input"))
file.copy("_code/fit_cov2.R", here::here(path_chtc, "input"))
file.copy("_code/fun_cov2.R", here::here(path_chtc, "input"))

# specify number of observations from cal_pwr code
pwr_n <- 85

# specify parameters for 1st research question (data-driven cov selection approaches)

if (question == "selection") {

  question_lvls <- c("selection")
  condition_lvls <- c(0)
  n_sims_job_lvls = c(1992)
  dgp_lvls <- c("con", "col", "med")
  n_obs_lvls <- c(pwr_n)
  b_xy_lvls <- c(0, .3)
  b_cx_lvls <- c(.3)
  e_c_lvls <- c(1)
  n_covs_lvls <- c(1)
  
}

# specify parameters for 2nd research question (likelihood our theory is correct)

if (question == "likelihood") { 
  
  question_lvls <- c("likelihood")
  condition_lvls <- c(.33, .5, .75, .9, 1)
  n_sims_job_lvls = c(332)
  dgp_lvls <- c("con", "col", "med")
  n_obs_lvls <- c(pwr_n)
  b_xy_lvls <- c(0, .3)
  b_cx_lvls <- c(.3)
  e_c_lvls <- c(1)
  n_covs_lvls <- c(1)
  
}

# specify parameters for for 3rd research question (omitted variable bias)

if (question == "omitted") { 
  
  question_lvls <- c("omitted")
  condition_lvls <- c(0)
  n_sims_job_lvls = c(1992)
  dgp_lvls <- c("con")
  n_obs_lvls <- c(pwr_n)
  b_xy_lvls <- c(0, .3)
  b_cx_lvls <- c(.1, .2, .3)
  e_c_lvls <- c(1)
  n_covs_lvls <- c(1, 2, 3)

}

# specify parameters for 4th research question (measurement error / reliability)

if (question == "reliability") { 
  
  question_lvls <- c("reliability")
  condition_lvls <- c(0)
  n_sims_job_lvls = c(1992)
  dgp_lvls <- c("con")
  n_obs_lvls <- c(pwr_n)
  b_xy_lvls <- c(0, .3)
  b_cx_lvls <- c(.3)
  e_c_lvls <- c(.6, .7, .8)
  n_covs_lvls <- c(1)

}

# create jobs file

jobs <- expand_grid(
                    question = question_lvls,
                    condition = condition_lvls,
                    n_sims_job = n_sims_job_lvls,
                    dgp = dgp_lvls,
                    n_obs = n_obs_lvls,
                    b_xy = b_xy_lvls,
                    b_cx = b_cx_lvls,
                    e_c = e_c_lvls,
                    n_covs = n_covs_lvls) |>
  mutate(
    b_cy = b_cx,
    b_xy = case_when(
      (b_xy == .3 & dgp == "med") ~ .3 - (b_cx * b_cy),
      TRUE ~ b_xy),
    x_effect = case_when(
      b_xy == 0 ~ "zero",
      TRUE ~ "non_zero"
      ))

if (question == "likelihood") {
    jobs <- jobs |> 
      slice(rep(seq_len(n()),
                times = case_when(
                  condition == .33 ~ 40,
                  condition == .5 & dgp == "con" ~ 60,
                  condition == .5 & dgp == "col" ~ 30,
                  condition == .5 & dgp == "med" ~ 30,
                  condition == .75 & dgp == "con" ~ 90,
                  condition == .75 & dgp == "col" ~ 15,
                  condition == .75 & dgp == "med" ~ 15,
                  condition == .9 & dgp == "con" ~ 108,
                  condition == .9 & dgp == "col" ~ 6,
                  condition == .9 & dgp == "med" ~ 6,
                  condition == 1 & dgp == "con" ~ 120,
                  .default = 0L)))
    } else {
      jobs <- jobs |> 
      slice(rep(seq_len(n()),
                times = 20))
      }
jobs <- jobs |>
  mutate(job_num = row_number()) |> 
  relocate(job_num) |>
  relocate(b_cy, .before = e_c)
  
# write jobs to input
jobs |> write_csv(here::here(path_chtc, "input", "jobs.csv"), 
                  col_names = FALSE)