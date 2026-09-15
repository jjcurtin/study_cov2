# This script fits linear models using our covariate 
#   selection methods in a simulated data set that varies characteristics of the research 
#   setting (e.g., sample size, number of covariates, effect size for x; see below)

# It will 
# - generate the data
# - fit the models
# - extract parameter estimate, SE, p-value for X 
# - also extract true positive rate and false positive rate for selecting good covariates 
# - save the results in a tibble that has separate rows for each approach and columns 
#   for the above info

# This script will be run across jobs where each job will have a different dataset that varies 
# the research setting/characteristics of the dataset.  These include:
# - n_obs.  number of observations in the dataset
# - b_x.  The effect size for the x effect
# - n_covs.  The number of covariates in the dataset
# - r_ycov.  The correlation between good covariates and y 
# - p_good_covs.  The proportion of covariates that are "good" (nonzero effect)
# - r_cov.  The corrleations among the good covariates ("bad" covariates are 
#      uncorrelated with y, x, good covariates and other bad covariates.)

args <- commandArgs(trailingOnly = TRUE) 

job_num <- as.numeric(args[1])
dgp <- args[2]
n_sims <- as.numeric(args[3])
n_obs <- as.numeric(args[4])
n_covs <- as.numeric(args[5])
r_xy <- as.numeric(args[6])
r_cy <- as.numeric(args[7])
r_cx <- as.numeric(args[8])
r_cc <- as.numeric(args[9])

#---------------------------
# for testing
job_num <- 1 
dgp <- "cc"
n_sims <- 100 
n_obs <- 100 
n_covs <- 2 
r_xy <- 0 
r_cy <- "[.3 .3]" 
r_cx <- "[.3, .3]" 
r_cc <- 0 
source("_code/fun_cov.R")
#---------------------------

source("fun_cov.R")

# Loop over sims
set.seed(job_num)
full_results <- tibble::tibble()

# process r_cy to vector
r_cy <- c(.3, .3)

# process r_cx to vector
r_cx <- c(.3, .3)


for(i in 1:n_sims) {

  # generate data for research setting 
  if (dgp == "cc") { 
    di <- generate_cc(n_obs, n_covs, b_x_y = r_xy, b_cov_x = r_cx, b_cov_y = r_cy, 
                r_cov = r_cc, e_x = NULL, e_cov = NULL)$x_y_covs
  } 
  
  if (dgp == "other") { 
    #  INSERT OTHER DGP FUNCTION
  } 
  
  results <- dplyr::bind_rows(
                       get_results(model = fit_no_covs(di), 
                                   method = "no_covs", 
                                   sim_num = i),
                       get_results(model = fit_all_covs(di), 
                                   method = "all_covs", 
                                   sim_num = i))
  
  full_results <- dplyr::bind_rows(full_results, results)
}

# add job_num as first column
full_results <- full_results |> 
  dplyr::mutate(job_num = job_num) |> 
  dplyr::relocate(job_num)

# tibble of research setting info
research_setting <- tibble::tibble(job_num = job_num,
                           n_obs = n_obs,
                           b_x = b_x,
                           n_covs = n_covs,
                           r_ycov = r_ycov, 
                           p_good_covs = p_good_covs,
                           r_cov = r_cov)

# join full results and write to csv file
full_results |>
  dplyr::left_join(research_setting, by = "job_num") |> 
  readr::write_csv(stringr::str_c("results_", job_num, ".csv"))