# function to generate data for confounders
generate_con <- function(n_obs, b_xy, b_cx, b_cy, e_c, empirical) {
  
  # generates continuous x, y, and covariates with mean = 0, variance = 1
  # reflects causal relationship where x causes y (as long as b_xy is non-zero)
  # reflects causal relationship where covariate causes x and y
  # n_obs = sample size
  # b_xy = path coefficients between x and y
  # b_cx = path coefficients between covariate and x
  # b_cy = path coefficients between covariate and y
  # e_c = measurement error in covariate
  # empirical = specifies whether generated data have exactly the mu and Sigma
  #   we've indicated (TRUE), or close to it (FALSE)
  
  # make sigma for cov, x, and y
  sigma <- diag(3)
  
  # calculate correlation between x and y
  r_x_y <- b_xy + (b_cx * b_cy)
  
  # superimpose correlation between x and y onto sigma
  sigma[1, 2] <- r_x_y
  sigma[2, 1] <- r_x_y
 
  # calculate correlation between covariate and x
  r_c_x <- b_cx
  
  # superimpose correlation between covariate and x onto sigma
  sigma[1, 3] <- matrix(r_c_x)
  sigma[3, 1] <- matrix(r_c_x)
  
  # calculate correlation between covariate and y
  r_c_y <- b_cy + (b_cx * b_xy)
  
  # superimpose correlation between covariate and y onto sigma
  sigma[2, 3] <- matrix(r_c_y)
  sigma[3, 2] <- matrix(r_c_y)
  
  # make x, y, and covs
  # all with mean = 0 and variance = 1
  x_y_c <- MASS::mvrnorm(n_obs, mu = rep(0, 3), Sigma = sigma, 
                            empirical = empirical)
  
  # convert to dataframe and rename variables
  x_y_c <- as.data.frame(x_y_c) |>
    dplyr::rename(x = V1,
                  y = V2,
                  c = V3)
  
  # return produced objects
  return(list(
    sigma = sigma,
    x_y_c = x_y_c))
}


# function to generate data for colliders
generate_col <- function(n_obs, b_xy, b_cx, b_cy, e_c, empirical) {
  
  # generates continuous x, y, and covariates with mean = 0, variance = 1
  # reflects causal relationship where x causes y (as long as b_xy is non-zero)
  # reflects causal relationship where both x and y cause the covariate
  # n_obs = sample size
  # b_xy = path coefficients between x and y
  # b_cx = path coefficients between covariate and x
  # b_cy = path coefficients between covariate and y
  # e_c = measurement error in covariate
  # empirical = specifies whether generated data have exactly the mu and Sigma
  #   we've indicated (TRUE), or close to it (FALSE)
  
  # make sigma for cov, x, and y
  sigma <- diag(3)
  
  # calculate correlation between x and y
  r_x_y <- b_xy
  
  # superimpose correlation between x and y onto sigma
  sigma[1, 2] <- r_x_y
  sigma[2, 1] <- r_x_y
  
  # calculate correlation between covariate and x
  r_c_x <- b_cx + (b_xy * b_cy)
  
  # superimpose correlation between covariate and x onto sigma
  sigma[1, 3] <- matrix(r_c_x)
  sigma[3, 1] <- matrix(r_c_x)
  
  # calculate correlation between covariate and y
  r_c_y <- b_cy + (b_cx * b_xy)
  
  # superimpose correlation between covariate and y onto sigma
  sigma[2, 3] <- matrix(r_c_y)
  sigma[3, 2] <- matrix(r_c_y)
  
  # make x, y, and covs
  # all with mean = 0 and variance = 1
  x_y_c <- MASS::mvrnorm(n_obs, mu = rep(0, 3), Sigma = sigma, 
                            empirical = empirical)
  
  # convert to dataframe and rename variables
  x_y_c <- as.data.frame(x_y_c) |>
    dplyr::rename(x = V1,
                  y = V2,
                  c = V3)
  
  # return produced objects
  return(list(
    sigma = sigma,
    x_y_c = x_y_c))
}


# function to generate data for mediators
generate_med <- function(n_obs, b_xy, b_cx, b_cy, e_c, empirical) {
  
  # generates continuous x, y, and covariates with mean = 0, variance = 1
  # reflects causal relationship where x causes y (as long as b_xy is non-zero)
  # reflects causal relationship where x also causes covariate, and covariate causes y
  # n_obs = sample size
  # b_xy = path coefficients between x and y
  # b_cx = path coefficients between covariate and x
  # b_cy = path coefficients between covariate and y
  # e_c = measurement error in covariate
  # empirical = specifies whether generated data have exactly the mu and Sigma
  #   we've indicated (TRUE), or close to it (FALSE)

  # make sigma for cov, x, and y
  sigma <- diag(3)
  
  # calculate correlation between x and y
  r_x_y <- b_xy + (b_cx * b_cy)
  
  # superimpose correlation between x and y onto sigma
  sigma[1, 2] <- r_x_y
  sigma[2, 1] <- r_x_y
  
  # calculate correlation between covariate and x
  r_c_x <- b_cx
  
  # superimpose correlation between covariate and x onto sigma
  sigma[1, 3] <- matrix(r_c_x)
  sigma[3, 1] <- matrix(r_c_x)
  
  # calculate correlation between covariate and y
  r_c_y <- b_cy + (b_cx * b_xy)
  
  # superimpose correlation between covariate and y onto sigma
  sigma[2, 3] <- matrix(r_c_y)
  sigma[3, 2] <- matrix(r_c_y)
  
  # make x, y, and covs
  # all with mean = 0 and variance = 1
  x_y_c <- MASS::mvrnorm(n_obs, mu = rep(0, 3), Sigma = sigma, 
                         empirical = empirical)
  
  # convert to dataframe and rename variables
  x_y_c <- as.data.frame(x_y_c) |>
    dplyr::rename(x = V1,
                  y = V2,
                  c = V3)
  
  # return produced objects
  return(list(
    sigma = sigma,
    x_y_c = x_y_c))
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