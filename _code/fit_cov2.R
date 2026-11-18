# This script fits linear models to investigate 
#   each of our four research questions in
#   simulated data sets

# It will:
  # generate the data
  # fit the models
  # extract parameter estimate, SE, p-value for x
  # save the results in a tibble
  # merge research context information into that tibble

args <- commandArgs(trailingOnly = TRUE) 

job_num <- as.numeric(args[1])
question <- args[2]
condition <- as.numeric(args[3])
n_sims_job <- as.numeric(args[4])
dgp <- args[5]
n_obs <- as.numeric(args[6])
b_xy <- as.numeric(args[7])
b_cx <- as.numeric(args[8])
b_cy <- as.numeric(args[9])
e_c <- as.numeric(args[10])
n_covs <- as.numeric(args[11])
x_effect <- args[12]
empirical <- FALSE

#source("C:/Users/elise/github/study_cov2/_code/fun_cov2.R")
source("fun_cov2.R")

# create tibble for results

assign(full_results, tibble::tibble())

# loop over sims

set.seed(job_num)

for (i in 1:n_sims_job) {

  # generate data for each DGP 
  
  if (dgp == "con") { 
    di <- generate_con(n_obs = n_obs, b_xy = b_xy, b_cx = b_cx,
                      b_cy = b_cy, e_c = e_c, n_covs = n_covs, empirical = empirical)$x_y_c
  } 
  
  if (dgp == "col") { 
    di <- generate_col(n_obs = n_obs, b_xy = b_xy, b_cx = b_cx,
                       b_cy = b_cy, e_c = e_c, n_covs = n_covs, empirical = empirical)$x_y_c
  } 
  
  if (dgp == "med") { 
    di <- generate_med(n_obs = n_obs, b_xy = b_xy, b_cx = b_cx,
                       b_cy = b_cy, e_c = e_c, n_covs = n_covs, empirical = empirical)$x_y_c
  }
  
  # generate results using different covariate selection procedures for each RQ
  
  if (question == "selection") {
    
    results <- dplyr::bind_rows(
      get_results(model = fit_x(di),
                  method = "x",
                  sim_num = i),
      get_results(model = fit_y(di),
                  method = "y",
                  sim_num = i),
      get_results(model = fit_x_y(di),
                  method = "x_y",
                  sim_num = i))
    
    full_results <- dplyr::bind_rows(full_results, results)
  }
  
  if (question == "likelihood") {
    
    results <- get_results(
      model = fit_all_covs(di), 
      method = "all_covs", 
      sim_num = i)
    
    full_results <- dplyr::bind_rows(full_results, results)
  }
  
  if (question == "omitted") {
    
    results <-
      get_results(
        model = fit_no_covs(di),
        method = "no_covs", 
        sim_num = i)

    full_results_omitted <- dplyr::bind_rows(full_results, results)
  }
  
  if (question == "reliability") {
    
    results <- get_results(
      model = fit_all_covs(di), 
      method = "all_covs", 
      sim_num = i)
    
    full_results <- dplyr::bind_rows(full_results, results)
  }
    
}

# merge research context information into results files
  
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
                                     n_sims_job = n_sims_job,
                                     dgp = dgp,
                                     n_obs = n_obs,
                                     b_xy = b_xy,
                                     b_cx = b_cx,
                                     b_cy = b_cy,
                                     e_c = e_c,
                                     n_covs = n_covs,
                                     x_effect = x_effect)
  
  # join full results and write to csv file
  
  full_results <- full_results |>
    dplyr::left_join(research_setting, by = "job_num")
  
  readr::write_csv(
    full_results,
    stringr::str_c("results_", job_num, ".csv"))