# Meeting notes

# 2026-07-16

We will perform a simulation study investigating three common approaches to covariate selection across various research contexts, to determine which approach results in the lowest average type I error

The covariate selection approaches are:

- Using all (theoretically-justified) covariates
- [JJC adds] Regressing Y on X and all covariates simultaneously
- Regressing Y on all covariates together (but not our focal variable) to determine which covariates to include
- Regressing Y on each covariate separately to determine which covariates to include
<!--Do we  need to consider other methods from experimental cov paper-->


The research contexts we manipulate will be:

- Number of covariates
- Measurement error in our covariates
- Sample size
- Size of the effect of covariates on X
- Size of the effect of covariates on Y
- Correlations among covariates

We will test this using:

- A single focal variable X, with no true effect on Y, such that any effect we detect is a type I error; our focal variable will be continuous (and maybe eventually categorical)
- Continuous covariates only
