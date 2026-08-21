# function to generate data 
generate_cc <- function(n_obs, b_x, n_covs, r_ycov, p_good_covs, r_cov) {
  
  # generates y and covs with mean=0, variance=1 
  # generates dichotomous x coded -.5, .5
  # n_obs = sample size
  # b_x = x effect
  # n_covs = number of covariates
  # r_ycov = correlation between y and covariates
  # p_good_covs = proportion of "good" covariates (nonzero effect)
  # r_cov = correlation among "good" covariates
  
  # make x 
  x <- c(rep(0, n_obs/2), rep(1, n_obs/2))
  
  # make sigma for covs and y
  sigma <- diag(n_covs + 1)
  
  # make n good covs
  n_good_covs <- n_covs * p_good_covs
  
  # make correlation matrix of good predictors
  corr_matrix <- matrix(r_cov, 
                        nrow = n_good_covs, 
                        ncol = n_good_covs)
  diag(corr_matrix) <- 1
  
  # superimpose corr_matrix onto sigma 
  sigma[2:(nrow(corr_matrix) + 1), 2:(ncol(corr_matrix) + 1)] <- corr_matrix
  
  # add correlations between y and good covs
  sigma[1, 2:(n_good_covs + 1)] <- rep(r_ycov, n_good_covs)
  sigma[2:(n_good_covs + 1), 1] <- rep(r_ycov, n_good_covs)
  
  # make covs + y pre-manipulation of x
  # all with mean = 0 and variance = 1
  ycovs <- MASS::mvrnorm(n_obs, mu = rep(0, n_covs + 1), Sigma = sigma)
  y <- ycovs[, 1]
  covs <- ycovs[, -1]
  
  # Add x effect into y
  y <- y + b_x * x 
  covs[, 1:3] <- covs[, 1:3] + b_x * covs[, 1:3]
  
  
  
  # combine all into tibble
  covs <- covs |>  
    tibble::as_tibble(.name_repair = "minimal")
  
  names(covs) <- stringr::str_c("c", 1:n_covs)
  
  tibble::tibble(y = y, x = x) |> 
    dplyr::bind_cols(covs)
}