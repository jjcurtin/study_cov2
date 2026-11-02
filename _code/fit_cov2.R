# This script fits linear models using our covariate 
#   selection methods in a simulated data set

# It will:
  # generate the data
  # fit the models
  # extract parameter estimate, SE, p-value for x
  # save the results in a tibble that has separate rows for each approach
  # merge research context information into that tibble

args <- commandArgs(trailingOnly = TRUE) 

job_num <- as.numeric(args[1])
question <- args[2]
condition <- as.numeric(args[3])
n_sims <- as.numeric(args[4])
dgp <- args[5]
n_obs <- as.numeric(args[6])
b_xy <- as.numeric(args[7])
b_cx <- (args[8])
b_cy <- (args[9])
e_c <- as.numeric(args[10])
x_effect <- args[11]
empirical <- FALSE

#source("C:/Users/elise/github/study_cov2/_code/fun_cov2.R")
source("fun_cov2.R")

# Loop over sims
set.seed(job_num)
full_results <- tibble::tibble()

for(i in 1:n_sims) {

  # generate data for research setting 
  if (dgp == "con") { 
    di <- generate_con(n_obs = n_obs, b_xy = b_xy, b_cx = b_cx,
                      b_cy = b_cy, e_c = e_c, empirical = empirical)$x_y_c
  } 
  
  if (dgp == "col") { 
    di <- generate_col(n_obs = n_obs, b_xy = b_xy, b_cx = b_cx,
                       b_cy = b_cy, e_c = e_c, empirical = empirical)$x_y_c
  } 
  
  if (dgp == "med") { 
    di <- generate_med(n_obs = n_obs, b_xy = b_xy, b_cx = b_cx,
                       b_cy = b_cy, e_c = e_c, empirical = empirical)$x_y_c
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
                                   question = question,
                                   condition = condition,
                                   n_sims = n_sims,
                                   dgp = dgp,
                                   n_obs = n_obs,
                                   b_xy = b_xy,
                                   b_cx = b_cx,
                                   b_cy = b_cy,
                                   e_c = e_c,
                                   x_effect = x_effect)

# join full results and write to csv file
full_results |>
  dplyr::left_join(research_setting, by = "job_num") |> 
  readr::write_csv(stringr::str_c("results_", job_num, ".csv"))
