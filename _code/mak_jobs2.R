# R script to write jobs csv for CHTC
library(tidyverse)
source("https://github.com/jjcurtin/lab_support/blob/main/format_path.R?raw=true")

path_chtc <- format_path(str_c("cov2/chtc/batch_", Sys.Date()))

dgp_lvls <- c("cc", "distr", "conseq")
n_obs_lvls <- c(100, 200, 300, 500)
n_covs_lvls <- c(1, 2, 4)
b_xy_lvls <- c(0, 0.3)     # path coefficient between x and y
b_cy_lvls <- c(0.1, 0.3)   # path coefficient between y and covs
b_cx_lvls <- c(0.1, 0.3)   # path coefficient between x and covs
r_cc_lvls <- c(0, .3)      # correlation between covs
e_x_lvls <- c(0, 0.1)      # measurement error in x
e_cov_lvls <- c(0, 0.1)    # measurement error in covs
 
#---------------------------
# for testing
dgp_lvls <- c("cc")
n_obs_lvls <- c(500)
n_covs_lvls <- c(1, 4)
b_xy_lvls <- c(0, 0.3)     # path coefficient between x and y
b_cy_lvls <- c(0.1)   # path coefficient between y and covs
b_cx_lvls <- c(0.1)   # path coefficient between x and covs
r_cc_lvls <- c(.3)      # correlation between covs
e_x_lvls <- c(0.1)      # measurement error in x
e_cov_lvls <- c(0.1)    # measurement error in covs
#---------------------------

# we want 40,000 simulations
# batching jobs at 500 sims per job
# 500 * 80 repeats = 40,0000 sims

jobs <- expand_grid(dgp = dgp_lvls,
                    n_sims = 500,
                    n_obs = n_obs_lvls,
                    n_covs = n_covs_lvls,
                    b_xy = b_xy_lvls,
                    b_cy = b_cy_lvls,
                    b_cx = b_cx_lvls,
                    r_cc = r_cc_lvls,
                    e_x = e_x_lvls,
                    e_cov = e_cov_lvls) |> 
  mutate(
    b_cy = mapply(
      \(x, n) paste0("[", paste(rep(x, n), collapse = ", "), "]"),
      b_cy, n_covs
    ),
    b_cx = mapply(
      \(x, n) paste0("[", paste(rep(x, n), collapse = ", "), "]"),
      b_cx, n_covs
    )) |>
  slice(rep(1:n(), each = 80)) |> 
  mutate(job_num = row_number()) |> 
  relocate(job_num)

nrow(jobs) * 500 / 540 # 40,000

# make new directory
dir.create(here::here(path_chtc))
dir.create(here::here(path_chtc, "input"))
dir.create(here::here(path_chtc, "output"))

# write jobs to input
jobs |> write_csv(here::here(path_chtc, "input", "jobs.csv"), 
                  col_names = FALSE)

# copy other files
file.copy("_code/cov2.sh", here::here(path_chtc, "input"))
file.copy("_code/cov2.sub", here::here(path_chtc, "input"))
file.copy("_code/fit_cov2.R", here::here(path_chtc, "input"))
file.copy("_code/fun_cov2.R", here::here(path_chtc, "input"))