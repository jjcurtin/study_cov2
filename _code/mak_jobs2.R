# R script to write jobs csv for CHTC
library(tidyverse)
source("https://github.com/jjcurtin/lab_support/blob/main/format_path.R?raw=true")

path_chtc <- format_path(str_c("cov2/chtc/batch_", Sys.Date()))

# conduct power analysis to identify appropriate sample size
pwr_n <- ceiling(pwr::pwr.r.test(
  r = 0.3,           
  sig.level = 0.05,
  power = 0.80,
  n = NULL,          
  alternative = "two.sided"
)$n)

# make new directory
dir.create(here::here(path_chtc))
dir.create(here::here(path_chtc, "input"))
dir.create(here::here(path_chtc, "output"))

# copy other files
file.copy("_code/cov2.sh", here::here(path_chtc, "input"))
file.copy("_code/cov2.sub", here::here(path_chtc, "input"))
file.copy("_code/fit_cov2.R", here::here(path_chtc, "input"))
file.copy("_code/fun_cov2.R", here::here(path_chtc, "input"))

# create jobs file for 1st research question (data-driven cov selection approaches)

  question_lvls <- c("selection")
  condition_lvls <- c(0)
  dgp_lvls <- c("con", "col", "med")
  n_obs_lvls <- c(pwr_n)
  b_xy_lvls <- c(0, .3)
  b_cx_lvls <- c(.3)
  e_c_lvls <- c(1)
  n_covs_lvls <- c(1)
  
  # we want around 10k simulations
  # batching jobs at 498 sims per job
  # 498 * 20 repeats = 9,960 total sims
  jobs <- expand_grid(
                      question = question_lvls,
                      condition = condition_lvls,
                      n_sims_job = 498,
                      dgp = dgp_lvls,
                      n_obs = n_obs_lvls,
                      b_xy = b_xy_lvls,
                      b_cx = b_cx_lvls,
                      e_c = e_c_lvls,
                      n_covs = n_covs_lvls) |> 
    mutate(
      b_cy = b_cx,
      b_xy = case_when(
        (b_xy == .3 & dgp == "med") ~ .21,
        TRUE ~ b_xy),
      x_effect = case_when(
        b_xy == 0 ~ "zero",
        TRUE ~ "non_zero"
      )) |>
    slice(rep(seq_len(n()),
              times = 20)) |> 
    mutate(job_num = row_number()) |> 
    relocate(job_num)
  
  nrow(jobs) * 498 / 6 # 9,960
  
  # write jobs to input
  jobs |> write_csv(here::here(path_chtc, "input", "jobs_selection.csv"), 
                    col_names = FALSE)


# create jobs file for 2nd research question (likelihood our theory is correct)

  question_lvls <- c("likelihood")
  condition_lvls <- c(.33, .5, .75, .9, 1)
  dgp_lvls <- c("con", "col", "med")
  n_obs_lvls <- c(pwr_n)
  b_xy_lvls <- c(0, .3)
  b_cx_lvls <- c(.3)
  e_c_lvls <- c(1)
  n_covs_lvls <- c(1)

  # we want around 10k simulations
  # batching jobs at 83 sims per job
  # 83 * 120 repeats = 9,960 total sims
  jobs <- expand_grid(
                      question = question_lvls,
                      condition = condition_lvls,
                      n_sims_job = 83,
                      dgp = dgp_lvls,
                      n_obs = n_obs_lvls,
                      b_xy = b_xy_lvls,
                      b_cx = b_cx_lvls,
                      e_c = e_c_lvls,
                      n_covs = n_covs_lvls) |> 
    mutate(
      b_cy = b_cx,
      b_xy = case_when(
        (b_xy == .3 & dgp == "med") ~ .21,
        TRUE ~ b_xy),
      x_effect = case_when(
        b_xy == 0 ~ "zero",
        TRUE ~ "non_zero"
      )) |>
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
                .default = 0L))) |> 
    mutate(job_num = row_number()) |> 
    relocate(job_num)
  
  nrow(jobs) * 83 / 10 # 9,960
  
  # write jobs to input
  jobs |> write_csv(here::here(path_chtc, "input", "jobs_likelihood.csv"), 
                    col_names = FALSE)


# create jobs file for 3rd research question (omitted variable bias)

  question_lvls <- c("omitted")
  condition_lvls <- c(0)
  dgp_lvls <- c("con")
  n_obs_lvls <- c(pwr_n)
  b_xy_lvls <- c(0, .3)
  b_cx_lvls <- c(.1, .2, .3)
  e_c_lvls <- c(1)
  n_covs_lvls <- c(1, 2, 3)

  # we want around 10k simulations
  # batching jobs at 498 sims per job
  # 498 * 20 repeats = 9,960 total sims
  jobs <- expand_grid(
                      question = question_lvls,
                      condition = condition_lvls,
                      n_sims_job = 498,
                      dgp = dgp_lvls,
                      n_obs = n_obs_lvls,
                      b_xy = b_xy_lvls,
                      b_cx = b_cx_lvls,
                      e_c = e_c_lvls,
                      n_covs = n_covs_lvls) |> 
    mutate(
      b_cy = b_cx,
      x_effect = case_when(
        b_xy == 0 ~ "zero",
        TRUE ~ "non_zero"
      )) |>
    slice(rep(seq_len(n()),
              times = 20)) |> 
    mutate(job_num = row_number()) |> 
    relocate(job_num)
  
    nrow(jobs) * 498 / 18 # 9,960
  
  # write jobs to input
  jobs |> write_csv(here::here(path_chtc, "input", "jobs_omitted.csv"), 
                    col_names = FALSE)

    
# create jobs file for 4th research question (measurement error / reliability)
  
  question_lvls <- c("reliability")
  condition_lvls <- c(0)
  dgp_lvls <- c("con")
  n_obs_lvls <- c(pwr_n)
  b_xy_lvls <- c(0, .3)
  b_cx_lvls <- c(.3)
  e_c_lvls <- c(.6, .7, .8)
  n_covs_lvls <- c(1)
  
  # we want around 10k simulations
  # batching jobs at 498 sims per job
  # 498 * 20 repeats = 9,960 total sims
  jobs <- expand_grid(
                      question = question_lvls,
                      condition = condition_lvls,
                      n_sims_job = 498,
                      dgp = dgp_lvls,
                      n_obs = n_obs_lvls,
                      b_xy = b_xy_lvls,
                      b_cx = b_cx_lvls,
                      e_c = e_c_lvls,
                      n_covs = n_covs_lvls) |> 
    mutate(
      b_cy = b_cx,
      x_effect = case_when(
        b_xy == 0 ~ "zero",
        TRUE ~ "non_zero"
      )) |>
    slice(rep(seq_len(n()),
              times = 20)) |> 
            mutate(job_num = row_number()) |> 
            relocate(job_num)
          
    nrow(jobs) * 498 / 6 # 9,960
          
    # write jobs to input
    jobs |> write_csv(here::here(path_chtc, "input", "jobs_reliability.csv"), 
                            col_names = FALSE)