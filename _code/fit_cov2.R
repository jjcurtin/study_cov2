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
e_c <- as.numeric(args[9])
n_covs <- as.numeric(args[10])
b_cy <- as.numeric(args[11])
x_effect <- args[12]
empirical <- FALSE

#source("C:/Users/elise/github/study_cov2/_code/fun_cov2.R")
source("fun_cov2.R")

# Loop over sims

set.seed(job_num)

rqs <- c("selection", "likelihood", "omitted", "reliability")
for (i in rqs) {
  file_name <- paste0("full_results_", i)
  assign(file_name, tibble::tibble())
}

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
    
    results_selection <- dplyr::bind_rows(
      get_results(model = fit_x(di),
                  method = "x",
                  sim_num = i),
      get_results(model = fit_y(di),
                  method = "y",
                  sim_num = i),
      get_results(model = fit_x_y(di),
                  method = "x_y",
                  sim_num = i))
    
    full_results_selection <- dplyr::bind_rows(full_results_selection, results_selection)
  }
  
  if (question == "likelihood") {
    
    results_likelihood <- get_results(
      model = fit_all_covs(di), 
      method = "all_covs", 
      sim_num = i)
    
    full_results_likelihood <- dplyr::bind_rows(full_results_likelihood, results_likelihood)
  }
  
  if (question == "omitted") {
    
    results_omitted <-
      get_results(
        model = fit_no_covs(di),
        method = "no_covs", 
        sim_num = i)

    full_results_omitted <- dplyr::bind_rows(full_results_omitted, results_omitted)
  }
  
  if (question == "reliability") {
    
    results_reliability <- get_results(
      model = fit_all_covs(di), 
      method = "all_covs", 
      sim_num = i)
    
    full_results_reliability <- dplyr::bind_rows(full_results_reliability, results_reliability)
  }
    
}

# merge research context information into results files

  # create file name
  
  file_name <- paste0("full_results_", question)
  full_results <- get(file_name)
  
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
                                     e_c = e_c,
                                     n_covs = n_covs,
                                     b_cy = b_cy,
                                     x_effect = x_effect)
  
  # join full results and write to csv file
  
  full_results <- full_results |>
    dplyr::left_join(research_setting, by = "job_num")
  
  readr::write_csv(
    full_results,
    stringr::str_c("results_", question, "_", job_num, ".csv"))