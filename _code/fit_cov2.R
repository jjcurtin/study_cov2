# This script fits linear models using our covariate 
#   selection methods in a simulated data set that varies characteristics of the research 
#   setting (e.g., sample size, number of covariates, effect size for x; see below)

# It will:
  # generate the data
  # fit the models
  # extract parameter estimate, SE, p-value for x
  # save the results in a tibble that has separate rows for each approach and columns 
  #   for the above info
  # merge research context information into that tibble

# This script will be run across jobs where each job will have a different dataset that varies 
# the research setting/characteristics of the dataset. These include:
  # n_obs = number of observations in the dataset
  # n_covs = The number of covariates in the dataset
  # b_xy = The path coefficient between x and y
  # b_cx = path coefficients between covariates and x; will be a vector
  # b_cy = path coefficients between covariates and y; will be a vector
  # r_cc = path coefficients between covariates; currently coded as a scalar
  # e_x = measurement error in x
  # e_cov = measurement error in covariates

args <- commandArgs(trailingOnly = TRUE) 

job_num <- as.numeric(args[1])
dgp <- args[2]
n_sims <- as.numeric(args[3])
n_obs <- as.numeric(args[4])
n_covs <- as.numeric(args[5])
b_xy <- as.numeric(args[6])
b_cy <- as.numeric(args[7])
b_cx <- as.numeric(args[8])
r_cc <- as.numeric(args[9])
e_x <- as.numeric(args[10])
e_cov <- as.numeric(args[11])
empirical <- FALSE

#source("fun_cov2.R")

#---------------------------
# for testing
job_num <- 1 
dgp <- "cc"
n_sims <- 100 
n_obs <- 100 
n_covs <- 2
b_xy <- 0
b_cy <- "[.3, .3]" 
b_cx <- "[.3, .3]" 
r_cc <- 0
e_x <- NULL
e_cov <- NULL
empirical <- FALSE
source("_code/fun_cov2.R")
#---------------------------

# Loop over sims
set.seed(job_num)
full_results <- tibble::tibble()

# process b_cy to vector
b_cy <- as.numeric(strsplit(gsub("\\[|\\]| ", "", b_cy), ",")[[1]])

# process b_cx to vector
b_cx <- as.numeric(strsplit(gsub("\\[|\\]| ", "", b_cx), ",")[[1]])

for(i in 1:n_sims) {

  # generate data for research setting 
  if (dgp == "cc") { 
    di <- generate_cc(n_obs = n_obs, n_covs = n_covs, b_xy = b_xy, b_cx = b_cx,
                      b_cy = b_cy, r_cc = r_cc, e_x = e_x, e_cov = e_cov,
                      empirical = empirical)$x_y_covs
  } 
  
  if (dgp == "distr") { 
    di <- generate_distr(n_obs = n_obs, n_covs = n_covs, b_xy = b_xy, r_cc = r_cc,
                         e_x = e_x, e_cov = e_cov, empirical = empirical)$x_y_covs
  } 
  
  if (dgp == "conseq") { 
    di <- generate_conseq(n_obs = n_obs, n_covs = n_covs, b_xy = b_xy, b_xc = b_xc,
                          r_cc = r_cc, e_x = e_x, e_cov = e_cov, empirical)$x_y_covs
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

# sort by method
full_results <- full_results |>
  dplyr::arrange(job_num, method, simulation_id)

# tibble of research setting info
research_setting <- tibble::tibble(job_num = job_num,
                                   n_obs = n_obs,
                                   dgp = dgp,
                                   b_xy = b_xy,
                                   b_cy = paste0("[", toString(b_cy), "]"),
                                   b_cx = paste0("[", toString(b_cx), "]"),
                                   r_cc = r_cc,
                                   e_x = e_x,
                                   e_cov = e_cov)

# join full results and write to csv file
full_results |>
  dplyr::left_join(research_setting, by = "job_num") |> 
  readr::write_csv(stringr::str_c("results_", job_num, ".csv"))