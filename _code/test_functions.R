
# test causal covariate function

  # specify example parameters
  n_obs <- 100
  n_covs <- 3
  b_x_y <- .4
  b_cov_x <- c(.2, .1, .15) 
  b_cov_y <- c(.25, .35, .05)
  r_cov <- .3

  # run function
  results <- generate_cc(n_obs = n_obs, n_covs = n_covs, b_x_y = b_x_y, b_cov_x = b_cov_x,
              b_cov_y = b_cov_y, r_cov = r_cov)

  # create objects to store regression coefficients
  reg_cov_y <- numeric(n_covs)
  reg_cov_x <- numeric(n_covs)
  
  # run regressions and compare coefficients to path coefficients
  cov_names <- grep("^c", names(results$x_y_covs), value = TRUE)
  lm_cov_y <- lm(reformulate(c("x", cov_names), response = "y"), data = results$x_y_covs)
  lm_cov_x <- lm(reformulate(cov_names, response = "x"), data = results$x_y_covs)
  stopifnot(abs(coef(lm_cov_y)[2]) - b_x_y < 1e-10)
  
  for (i in 1:n_covs){
    col_num_y <- i + 2
    col_num_x <- i + 1
    reg_cov_y[i] <- coef(lm_cov_y)[col_num_y]
    reg_cov_x[i] <- coef(lm_cov_x)[col_num_x]
    stopifnot(abs(reg_cov_y[i] - b_cov_y[i]) < 1e-10)
    stopifnot(abs(reg_cov_x[i] - b_cov_x[i]) < 1e-10)
  }