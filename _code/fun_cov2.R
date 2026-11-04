# function to generate data for confounders
generate_con <- function(n_obs, b_xy, b_cx, b_cy, e_c, n_covs, empirical) {
  
  # generates continuous x, y, and covariates with mean = 0, variance = 1
  # reflects causal relationship where x causes y (as long as b_xy is non-zero)
  # reflects causal relationship where covariates cause x and y
  # n_obs = sample size
  # b_xy = path coefficients between x and y
  # b_cx = path coefficients between covariates and x
  # b_cy = path coefficients between covariates and y
  # e_c = measurement error in covariates
  # n_covs = number of covariates
  # empirical = specifies whether generated data have exactly the mu and Sigma
  #   we've indicated (TRUE), or close to it (FALSE)
  
  # make sigma for cov, x, and y
  sigma <- diag(n_covs + 2)
  
  # calculate correlation between covariates
  r_c_c <- 0
  
  # creating matrix of correlations between covariates
  cov_matrix <- matrix(r_c_c,
                       nrow = n_covs,
                       ncol = n_covs)
  diag(cov_matrix) <- 1
  
  # superimpose correlation between covariates onto sigma
  sigma[3:(nrow(cov_matrix) + 2), 3:(ncol(cov_matrix) + 2)] <- cov_matrix
  
  # calculate correlation between x and y
  r_x_y <- b_xy + (n_covs * (b_cx * b_cy))
  
  # superimpose correlation between x and y onto sigma
  sigma[1, 2] <- r_x_y
  sigma[2, 1] <- r_x_y
 
  # calculate correlation between covariates and x
  r_c_x <- b_cx
  
  # superimpose correlation between covariates and x onto sigma
  sigma[1, 3:(n_covs + 2)] <- r_c_x
  sigma[3:(n_covs + 2), 1] <- r_c_x
  
  # calculate correlation between covariates and y
  r_c_y <- b_cy + (b_cx * b_xy)
  
  # superimpose correlation between covariates and y onto sigma
  sigma[2, 3:(n_covs + 2)] <- r_c_y
  sigma[3:(n_covs + 2), 2] <- r_c_y
  
  # make x, y, and covs
  # all with mean = 0 and variance = 1
  x_y_c <- MASS::mvrnorm(n_obs, mu = rep(0, n_covs + 2), Sigma = sigma, 
                         empirical = empirical)
  
  # convert to dataframe and rename variables
  x_y_c <- as.data.frame(x_y_c) |>
    dplyr::rename(x = V1,
                  y = V2)
  names(x_y_c)[-(1:2)] <- paste0("c", seq_len(ncol(x_y_c) - 2))
  
  # return produced objects
  return(list(
    sigma = sigma,
    x_y_c = x_y_c))
}


# function to generate data for colliders
generate_col <- function(n_obs, b_xy, b_cx, b_cy, e_c, n_covs, empirical) {
  
  # generates continuous x, y, and covariates with mean = 0, variance = 1
  # reflects causal relationship where x causes y (as long as b_xy is non-zero)
  # reflects causal relationship where both x and y cause the covariate
  # n_obs = sample size
  # b_xy = path coefficients between x and y
  # b_cx = path coefficients between covariate and x
  # b_cy = path coefficients between covariate and y
  # e_c = measurement error in covariate
  # n_covs = number of covariates
  # empirical = specifies whether generated data have exactly the mu and Sigma
  #   we've indicated (TRUE), or close to it (FALSE)
  
  # make sigma for cov, x, and y
  sigma <- diag(n_covs + 2)
  
  # calculate correlation between covariates
  r_c_c <- (b_cx * b_cx) + (b_cy * b_cy) + (b_xy * b_cx * b_cy) + (b_xy * b_cy * b_cx)
  
  # creating matrix of correlations between covariates
  cov_matrix <- matrix(r_c_c,
                       nrow = n_covs,
                       ncol = n_covs)
  diag(cov_matrix) <- 1
  
  # superimpose correlation between covariates onto sigma
  sigma[3:(nrow(cov_matrix) + 2), 3:(ncol(cov_matrix) + 2)] <- cov_matrix
  
  # calculate correlation between x and y
  r_x_y <- b_xy
  
  # superimpose correlation between x and y onto sigma
  sigma[1, 2] <- r_x_y
  sigma[2, 1] <- r_x_y
  
  # calculate correlation between covariates and x
  r_c_x <- b_cx + (b_xy * b_cy)
  
  # superimpose correlation between covariates and x onto sigma
  sigma[1, 3:(n_covs + 2)] <- r_c_x
  sigma[3:(n_covs + 2), 1] <- r_c_x
  
  # calculate correlation between covariates and y
  r_c_y <- b_cy + (b_cx * b_xy)
  
  # superimpose correlation between covariates and y onto sigma
  sigma[2, 3:(n_covs + 2)] <- r_c_y
  sigma[3:(n_covs + 2), 2] <- r_c_y
  
  # make x, y, and covs
  # all with mean = 0 and variance = 1
  x_y_c <- MASS::mvrnorm(n_obs, mu = rep(0, n_covs + 2), Sigma = sigma, 
                         empirical = empirical)
  
  # convert to dataframe and rename variables
  x_y_c <- as.data.frame(x_y_c) |>
    dplyr::rename(x = V1,
                  y = V2)
  names(x_y_c)[-(1:2)] <- paste0("c", seq_len(ncol(x_y_c) - 2))
  
  # return produced objects
  return(list(
    sigma = sigma,
    x_y_c = x_y_c))
}


# function to generate data for mediators
generate_med <- function(n_obs, b_xy, b_cx, b_cy, e_c, n_covs, empirical) {
  
  # generates continuous x, y, and covariates with mean = 0, variance = 1
  # reflects causal relationship where x causes y (as long as b_xy is non-zero)
  # reflects causal relationship where x also causes covariate, and covariate causes y
  # n_obs = sample size
  # b_xy = path coefficients between x and y
  # b_cx = path coefficients between covariate and x
  # b_cy = path coefficients between covariate and y
  # e_c = measurement error in covariate
  # n_covs = number of covariates
  # empirical = specifies whether generated data have exactly the mu and Sigma
  #   we've indicated (TRUE), or close to it (FALSE)

  # make sigma for cov, x, and y
  sigma <- diag(n_covs + 2)
  
  # calculate correlation between covariates
  r_c_c <- b_cx * b_cx
  
  # creating matrix of correlations between covariates
  cov_matrix <- matrix(r_c_c,
                       nrow = n_covs,
                       ncol = n_covs)
  diag(cov_matrix) <- 1
  
  # superimpose correlation between covariates onto sigma
  sigma[3:(nrow(cov_matrix) + 2), 3:(ncol(cov_matrix) + 2)] <- cov_matrix
  
  # calculate correlation between x and y
  r_x_y <- b_xy + (n_covs * (b_cx * b_cy))
  
  # superimpose correlation between x and y onto sigma
  sigma[1, 2] <- r_x_y
  sigma[2, 1] <- r_x_y
  
  # calculate correlation between covariates and x
  r_c_x <- b_cx
  
  # superimpose correlation between covariates and x onto sigma
  sigma[1, 3:(n_covs + 2)] <- r_c_x
  sigma[3:(n_covs + 2), 1] <- r_c_x
  
  # calculate correlation between covariates and y
  r_c_y <- b_cy + (b_cx * b_xy)
  
  # superimpose correlation between covariates and y onto sigma
  sigma[2, 3:(n_covs + 2)] <- r_c_y
  sigma[3:(n_covs + 2), 2] <- r_c_y
  
  # make x, y, and covs
  # all with mean = 0 and variance = 1
  x_y_c <- MASS::mvrnorm(n_obs, mu = rep(0, n_covs + 2), Sigma = sigma, 
                         empirical = empirical)
  
  # convert to dataframe and rename variables
  x_y_c <- as.data.frame(x_y_c) |>
    dplyr::rename(x = V1,
                  y = V2)
  names(x_y_c)[-(1:2)] <- paste0("c", seq_len(ncol(x_y_c) - 2))
  
  # return produced objects
  return(list(
    sigma = sigma,
    x_y_c = x_y_c))
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