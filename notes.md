# Meeting notes

# 2026-09-04

To deal with the issue of means and SDs shifting from 0 and 1 (respectively) after we incorporate a causal structure, we determined that we will simply incorporate the causal relationships into our variance/covariance matrix (i.e., our sigma). We will specify the path diagrams and their coefficients, and calculate our sigma from there. In general, we will start with simple code, and build up from there to more complex scenarios.

We also talked about which parameters we care most about varying, since we can't vary them all. We decided that we care most about examining:

- The three causal structures (causal, distractor, and consequences of X)
- Zero and a non-zero effects of X on Y
- Reliability of covariates
- Sample size (N)

After that, we can consider:

- Number of covariates
- Size of the non-zero effect of X on Y
- Covariate effects on X and Y (where relevant) [EG note: this might matter if we use LASSO]
- Reliability of X
- Correlations among our covariates

We will return to this conversation at a later date, and consider factors like:

- What is going to have big effects
- When it will work vs. not work to use covariates
- Which scenarios people might not appreciate

As next steps, Elise will write code to create sigma from a path diagram, and confirm that this approach works (that is, that we get back out our path diagram coefficients after running regressions). We will start by using a very simple structure: the causal covariates context, with one covariate, and r_cov set to NULL. Elise will also begin thinking about what a two-covariate version (and eventually, an n-covariate version) would look like. (If that is proving too challenging, we can always just create separate statements for each number of covariates.) We will then run a simulation with the causal covariates context, and eventually loop back to the other contexts.

Finally, for future virtual meetings, we will record our meetings and use an agent to generate notes for us.


# 2026-08-21

We reviewed the function file from the first covariates study, and discussed creating functions for our three types of covariates (causal, distractor, and consequences of X). We decided that we would create X, Y, and covariates as normally-distributed continuous variables (mean = 0, SD = 1) that are uncorrelated with each other (in terms of the variance-covariance matrix), and then introduce causal relationships between them (based on the type of covariate).

# 2026-07-24

We decided that for now we will explore contexts where X has no effect on Y, *and* contexts where X has an effect on Y; this will allow us to explore methods for controlling for confounding variables while maintaining statistical power; if the story becomes too complicated, we can split our findings into two papers

We also discussed including three types of covariates, which we would keep in separate conditions (rather than mixing and matching them):

- Causal covariates
	- These cause both X and Y
	- These we would want to include in our models, because they are confounds
	- Example: when examining the relationship between parent-child relationship quality and child internalizing problems, we'd want to include child age, which influences both relationship quality and child internalizing problems
- Distractor covariates
	- These are not part of the model, and are uncorrelated with X, Y, and other covariates
	- These we wouldn't want to include in our models, because they'd reduce our power / make things inefficient
	- Example: when examining the relationship between intensive parenting beliefs and parental burnout, we would want to include parent gender (which can influence both intensive parenting beliefs and parental burnout), but not child gender (which likely doesn't influence intensive parenting beliefs or parental burnout and which is uncorrelated with parent gender)
- Consequences of X
	- These are caused by (not causes of) X, which are only correlated with Y because of their correlation with X
	- These we wouldn't want to include in our models, because we'd be underestimating the effect of X on Y
	- Example: when examining the relationship of child age on self-regulation, we wouldn't want to include child height, which is caused by child age but which doesn't itself impact self-regulation [EG Comment: I know this is a silly example, but I was having a lot of trouble coming up with something here that wasn't just a mediator!]

We may also consider a fourth type of covariate:

- Consequences of causal covariates
	- These are consequences of causal covariates, which are only correlated with Y because of their correlation with causal covariates
	- These we wouldn't want to include in our models, because they can decrease power / lead to inefficiencies, unless we use them in place of causal covariates
	- Example: when examining the relationship between parents' cultural values and child mental health, we'd want to include generational status but not primary language as a covariate, because generational status influences cultural values and child mental health; generational status also influences primary language, which does not independently influence child mental health

Finally, we decided that we will also likely include LASSO as a covariate selection approach

A revised summary of our study that reflects these updates is as follows: we will perform a simulation study investigating four common approaches to covariate selection across various research contexts, to determine which approaches best balance type I and type II errors (that is, that control for confounds while maintaining statistical power)


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
