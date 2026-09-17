# function to generate data for causal covariates
generate_cc <- function(n_obs, n_covs, r_xy, r_cx, r_cy, r_cc, e_x, e_cov,
                        empirical) {
  
  # generates continuous x, y, and covariates with mean = 0, variance = 1
  # reflects causal relationship where x causes y (as long as r_xy is non-zero)
  # reflects causal relationship where covariates cause x and y
  # allows covariates to correlate with one another
  # n_obs = sample size
  # n_covs = number of covariates
  # r_xy = path coefficients between x and y
  # r_cx = path coefficients between covariates and x; will be a vector
  # r_cy = path coefficients between covariates and y; will be a vector
  # r_cc = path coefficients between covariates; currently coded as a scalar
  # e_x = measurement error in x
  # e_cov = measurement error in covariates
  # empirical = specifies whether generated data have exactly the mu and Sigma
  #   we've indicated (TRUE), or close to it (FALSE)
  
  # make sigma for covs, x, and y
  sigma <- diag(n_covs + 2)
  
  # make correlation matrix for covariates
  cov_matrix <- matrix(r_cc, 
                       nrow = n_covs, 
                       ncol = n_covs)
  diag(cov_matrix) <- 1
  cov_matrix_zero <- cov_matrix
  diag(cov_matrix_zero) <- 0
  
  # superimpose covariate matrix onto sigma 
  sigma[3:(nrow(cov_matrix) + 2), 3:(ncol(cov_matrix) + 2)] <- cov_matrix
  
  # calculate correlation between x and y
  r_x_y <-
    r_xy +
    t(r_cx) %*%
    cov_matrix %*%
    r_cy
  
  # superimpose correlation between x and y onto sigma
  sigma[1, 2] <- r_x_y
  sigma[2, 1] <- r_x_y
 
  # calculate correlations between covariates and x
  r_cc_x <-
    r_cx +
    (cov_matrix_zero %*% r_cx)
  
  # superimpose correlation between covariates and x onto sigma
  sigma[1, 3:(n_covs + 2)] <- matrix(r_cc_x, nrow = 1)
  sigma[3:(n_covs + 2), 1] <- matrix(r_cc_x)
  
  # calculate correlation between covariates and y
  r_cc_y <- r_cy +
    (r_cx * r_xy) +
    (cov_matrix_zero %*% r_cy) +
    ((cov_matrix_zero %*% r_cx) * r_xy)
  
  # superimpose correlation between covariates and y onto sigma
  sigma[2, 3:(n_covs + 2)] <- matrix(r_cc_y, nrow = 1)
  sigma[3:(n_covs + 2), 2] <- matrix(r_cc_y)
  
  # make x, y, and covs
  # all with mean = 0 and variance = 1
  x_y_covs <- MASS::mvrnorm(n_obs, mu = rep(0, n_covs + 2), Sigma = sigma, 
                            empirical = empirical)
  
  # convert to dataframe and rename variables
  x_y_covs <- as.data.frame(x_y_covs) |>
    dplyr::rename(x = V1,
                  y = V2)
  names(x_y_covs)[-(1:2)] <- paste0("c", seq_len(ncol(x_y_covs) - 2))
  
  # return prouced objects
  return(list(
    sigma = sigma,
    x_y_covs = x_y_covs))
}


########################################
# NEED TO UPDATE THESE AT A LATER DATE #
########################################

# function to generate data for distractor covariates
generate_distr <- function(n_obs, n_covs, r_xy, r_cc, e_x, e_cov, empirical) {
  
  # generates continuous x, y, and covs with mean = 0, variance = 1
  # introduces causal relationship where x causes y (as long as r_xy is non-zero)
  # does not introduce a causal relationship between covs and either x or y
  # n_obs = sample size
  # n_covs = number of covariates
  # r_xy = path coefficients between x and y
  # r_cc = path coefficients between covariates (we might want to set to zero for this condition?)
  # e_x = measurement error in X
  # e_cov = measurement error in covariates
  # empirical = specifies whether generated data have exactly the mu and Sigma
  #   we've indicated (TRUE), or close to it (FALSE)
  
  # make sigma for covs, x, and y
  sigma <- diag(n_covs + 2)
  
  # make correlation matrix of predictors
  corr_matrix <- matrix(r_cc, 
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
  y <- y + r_xy * x
  
  # combine all into tibble
  covs <- covs |>  
    tibble::as_tibble(.name_repair = "minimal")
  
  names(covs) <- stringr::str_c("c", 1:n_covs)
  
  tibble::tibble(x = x, y = y) |> 
    dplyr::bind_cols(covs)
}


# function to generate data for covariates that are consequences of x
generate_conseq <- function(n_obs, n_covs, r_xy, r_cx, r_cc, e_x, e_cov, empirical) {
  
  # generates continuous x, y, and covs with mean = 0, variance = 1
  # introduces causal relationship where x causes y (as long as r_xy is non-zero)
  # introduces causal relationship where x causes covs
  # n_obs = sample size
  # n_covs = number of covariates
  # r_xy = path coefficients between x and y
  # r_cx = path coefficients between x and covariates (should this be a vector?)
  # r_cc = path coefficients between covariates (not clear if these would be zero to start)
  # e_x = measurement error in X
  # e_cov = measurement error in covariates
  # empirical = specifies whether generated data have exactly the mu and Sigma
  #   we've indicated (TRUE), or close to it (FALSE)
  
  # make sigma for covs, x, and y
  sigma <- diag(n_covs + 2)
  
  # make correlation matrix of predictors
  corr_matrix <- matrix(r_cc, 
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
  y <- y + r_xy * x
  
  # combine all into tibble
  covs <- covs |>  
    tibble::as_tibble(.name_repair = "minimal")
  
  names(covs) <- stringr::str_c("c", 1:n_covs)
  
  tibble::tibble(x = x, y = y) |> 
    dplyr::bind_cols(covs)
}


# fit no covariate model
# fits linear model with no covariates
fit_no_covs <- function(d) {
  lm(y ~ x, data = d)
}


# fit all covariate model
# fits linear model with all available covariates
fit_all_covs <- function(d) {
  lm(y ~ ., data = d)
}


# make results tibble
get_results <- function(model, method, sim_num) {
  # model = an lm object
  # method = the name of the method used to select covariates (e.g., no_covs) 
  # sim = simulation number
 
  ndf <- model |> broom::glance() |> dplyr::pull(df)
  ddf <- model |> broom::glance() |> dplyr::pull(df.residual)
  output <- model |> broom::tidy() |> dplyr::filter(term == "x")
 
  # put it all in a results tibble 
  tibble::tibble(method = method, 
                 simulation_id = sim_num,
                 estimate = output$estimate,
                 SE = output$std.error,
                 p_value = output$p.value,
                 ndf = ndf,
                 ddf = ddf)
}