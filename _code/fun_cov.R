# function to generate data for causal covariates
generate_cc <- function(n_obs, n_covs, b_x_y, b_cov_x, b_cov_y, r_cov, e_x, e_cov) {
  
  # generates continuous x, y, and covs with mean = 0, variance = 1
  # introduces causal relationship where x causes y (as long as b_x_y is non-zero)
  # introduces causal relationship where covs cause x and y
  # n_obs = sample size
  # n_covs = number of covariates
  # b_x_y = x effect on y
  # b_cov_x = covariate effects on x; will be a vector
  # b_cov_y = covariate effects on y; will be a vector
  # r_cov = correlation among covariates
  # e_x = measurement error in x
  # e_cov = measurement error in covariates
  
  # make sigma for covs, x, and y
  sigma <- diag(n_covs + 2)
  
  # make correlation matrix of predictors
  corr_matrix <- matrix(r_cov, 
                        nrow = n_covs, 
                        ncol = n_covs)
  diag(corr_matrix) <- 1
  
  # superimpose corr_matrix onto sigma 
  sigma[3:(nrow(corr_matrix) + 2), 3:(ncol(corr_matrix) + 2)] <- corr_matrix
  
  # make x, y, and covs before introducing causality
  # all with mean = 0 and variance = 1
  x_y_covs <- MASS::mvrnorm(n_obs, mu = rep(0, n_covs + 2), Sigma = sigma)
  x <- x_y_covs[, 1]
  y <- x_y_covs[, 2]
  covs <- x_y_covs[, -c(1, 2)]
  
  # Add cov effect into x
  x <- as.vector(x + as.matrix(covs) %*% b_cov_x)

  # Add x and cov effects into y
  y <- as.vector(y + b_x_y * x + as.matrix(covs) %*% b_cov_y)
  
  # combine all into tibble
  covs <- covs |>  
    tibble::as_tibble(.name_repair = "minimal")
  
  names(covs) <- stringr::str_c("c", 1:n_covs)
  
  tibble::tibble(x = x, y = y) |> 
    dplyr::bind_cols(covs)
}

# function to generate data for distractor covariates
generate_distr <- function(n_obs, n_covs, b_x_y, r_cov, e_x, e_cov) {
  
  # generates continuous x, y, and covs with mean = 0, variance = 1
  # introduces causal relationship where x causes y (as long as b_x_y is non-zero)
  # does not introduce a causal relationship between covs and either x or y
  # n_obs = sample size
  # n_covs = number of covariates
  # b_x_y = x effect on y
  # r_cov = correlation among covariates (we might want to set to zero for this condition?)
  # e_x = measurement error in X
  # e_cov = measurement error in covariates
  
  # make sigma for covs, x, and y
  sigma <- diag(n_covs + 2)
  
  # make correlation matrix of predictors
  corr_matrix <- matrix(r_cov, 
                        nrow = n_covs, 
                        ncol = n_covs)
  diag(corr_matrix) <- 1
  
  # superimpose corr_matrix onto sigma 
  sigma[3:(nrow(corr_matrix) + 2), 3:(ncol(corr_matrix) + 2)] <- corr_matrix
  
  # make x, y, and covs before introducing causality
  # all with mean = 0 and variance = 1
  x_y_covs <- MASS::mvrnorm(n_obs, mu = rep(0, n_covs + 2), Sigma = sigma)
  x <- x_y_covs[, 1]
  y <- x_y_covs[, 2]
  covs <- x_y_covs[, -c(1, 2)]
  
  # Add x effect into y
  y <- y + b_x_y * x
  
  # combine all into tibble
  covs <- covs |>  
    tibble::as_tibble(.name_repair = "minimal")
  
  names(covs) <- stringr::str_c("c", 1:n_covs)
  
  tibble::tibble(x = x, y = y) |> 
    dplyr::bind_cols(covs)
}

# function to generate data for covariates that are consequences of x
generate_conseq <- function(n_obs, n_covs, b_x_y, b_x_cov, r_cov, e_x, e_cov) {
  
  # generates continuous x, y, and covs with mean = 0, variance = 1
  # introduces causal relationship where x causes y (as long as b_x_y is non-zero)
  # introduces causal relationship where x causes covs
  # n_obs = sample size
  # n_covs = number of covariates
  # b_x_y = x effect on y
  # b_x_cov = x effect on covariates (should this be a vector?)
  # r_cov = correlation among covariates (not clear if these would be zero to start)
  # e_x = measurement error in X
  # e_cov = measurement error in covariates
  
  # make sigma for covs, x, and y
  sigma <- diag(n_covs + 2)
  
  # make correlation matrix of predictors
  corr_matrix <- matrix(r_cov, 
                        nrow = n_covs, 
                        ncol = n_covs)
  diag(corr_matrix) <- 1
  
  # superimpose corr_matrix onto sigma 
  sigma[3:(nrow(corr_matrix) + 2), 3:(ncol(corr_matrix) + 2)] <- corr_matrix
  
  # make x, y, and covs before introducing causality
  # all with mean = 0 and variance = 1
  x_y_covs <- MASS::mvrnorm(n_obs, mu = rep(0, n_covs + 2), Sigma = sigma)
  x <- x_y_covs[, 1]
  y <- x_y_covs[, 2]
  covs <- x_y_covs[, -c(1, 2)]
  
  # Add x effect into covs
  covs[, 1:n_covs] <- covs[, 1:n_covs] + b_x_cov * x
  
  # Add x effect into y
  y <- y + b_x_y * x
  
  # combine all into tibble
  covs <- covs |>  
    tibble::as_tibble(.name_repair = "minimal")
  
  names(covs) <- stringr::str_c("c", 1:n_covs)
  
  tibble::tibble(x = x, y = y) |> 
    dplyr::bind_cols(covs)
}

# test functions

  # specify example parameters
  n_obs <- 100
  n_covs <- 5
  b_x_y <- .3
  b_cov_x <- c(.1, .3, .5, -.2, -.8)
  b_cov_y <- c(.2, -.4, 1, -.1, .3)
  r_cov <- .5
  b_x_cov <- c(-.3, .7, -.2, .9, -.4)
  
  # run functions
  generate_cc(n_obs = n_obs, n_covs = n_covs, b_x_y = b_x_y, b_cov_x = b_cov_x,
              b_cov_y = b_cov_y, r_cov = r_cov)
  generate_distr(n_obs = n_obs, n_covs = n_covs, b_x_y = b_x_y, r_cov = r_cov)
  generate_conseq(n_obs = n_obs, n_covs = n_covs, b_x_y = b_x_y, b_x_cov = b_x_cov,
                  r_cov = r_cov)