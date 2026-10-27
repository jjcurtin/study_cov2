# Meeting notes

# 2026-10-20

We debriefed from the lab meeting, and decided that we will move forward, with the following goals:

- Make more explicit the conclusions from the Psych Science paper
- Empirically demonstrate each point through a series of simulations
- Make conclusions obvious and recommendations actionable

Our end goal is to encourage people to choose covariates very carefully, and to really grapple with the strength of their evidence based on their methods

Throughout our simulations, we will generally limit our research contexts as follows, to reduce complexity: [EG note: In general, I think we can stick to these, and then only vary a research context to show how different contexts makes a problem even worse]

- Use only one covariate
- Not vary sample size (80% power to detect moderate X effect)
- Have two levels of X (zero and non-zero)

We will also examine the following throughout:

- Average bias [EG note: Did we decide to do the absolute value of bias here?]
- Type I error rates
- Type II error rates

Our questions / simulations are as follows:

(1) We will investigate the magnitude and effects of bias when using data-driven covariate selection approaches
	
	- The Psych Science paper implied that data-driven covariate selection approaches would be inadequate, but that implication was never formally evaluated
	- DGPs:
		- Confounders
		- Colliders
		- Mediators
		- Reverse causality? [EG note: This could be relevant for instances of bi-directional effects]
		- Irrelevant variables? [EG note: One reason it seems people use data-driven approaches is to eliminate irrelevant variables; I think we wouldn't necessarily have to vary sample size, though]
	- Covariate selection approaches:
		- Significant correlation with X
		- Significant correlation with Y
		- Significant correlation with X and Y
		- Other? (e.g., LASSO)
	- Anticipated findings: Data-driven approaches result in bias / are inadequate, and we can't know if we are over- or under-estimating effect size unless we know the true DGP; therefore, theory-driven covariate selection approaches should be used

(2) We will investigate how the magnitude and effects of bias vary based on the likelihood that our theory is correct

	- DGPs:
		- Confounders
		- Colliders
		- Mediators
		- Reverse causality?
		- Irrelevant variables?
	- Likelihood of theory being correct:
		- Vary probability of each DGP (e.g., 33%, 33%, 33% for weak theory)
	- Anticipated findings: Even if we use theory-driven approaches, we will have bias unless there is a 100% likelihood that our theory is correct (that is, a 100% likelihood that our covariate is a confound), and the degree of that bias will depend on the likelihood that our theory is correct

(3) We will investigate the magnitude and effects of bias if we don't measure every confounder (i.e., omitted variable bias)

	- DGPs:
		- Confounder only (plus at least one omitted confounder; could use >1 to show that the problem gets even worse when we have more than one omitted confounder)
	- Effect of confounders on Y:
		- Multiple non-zero levels? [EG note: I think this would allow us to indicate the effect size at which omitted variables start to pose a big problem, given that lots of variables are probably a little bit correlated with X and Y] 
	- Anticipated finding: Even if we do everything else right (i.e., we use theory-driven approaches and our theory is 100% correct), we will still have bias unless we measure every confound

(4) We will investigate the magnitude and effects of bias if we have measurement error [EG note: Are we including measurement error in just the confounders, or also in X?]

	- DGPs:
		- Confounder only (could include more than one to show that problem gets even worse when we have multiple confounders)
	- Reliability:
		- Will vary between .6 and .8
	- Anticipated finding: Even if we do everything else right (i.e., we use theory-driven approaches, our theory is 100% correct, and we haven't omitted any confounders), we will still have bias if we have measurement error 

For our recommendations, we could say:

- Make sure you are using theoretical approaches to select covariates (especially in A and B cases)
- Make sure you are very confident in your theory (above C threshold); longitudinal methods help here
- Make sure you don’t have any omitted variables (above effect size of D)
- Make sure you don’t have measurement error (above E)

As next steps, Elise will think about the following:

- Can we have six DGPs based on X effect (i.e., when X effect is zero)?
	[EG note: It seems like the mediator might just become the independent causes of Y DGP? See dgps_zero_non-zero_x_effects.pdf]
- Can we avoid manipulation of N?
	[EG note: I think so; we could always move forward with our current plan of selecting N, and then re-run things with a small N, to show how these issues will likely be even worse there]
- Can we avoid manipulation of effect size of X (other than zero/non-zero)?
	[EG note: I think yes, but it might be useful to vary the size of the effect of omitted variables on Y for question/simulation #3]

In addition, we determined that it would likely be easiest to start with question/simulation #2

Finally, we will start to think about ways we can organize our code


# 2026-10-14 (Lab Meeting)

Peoples’ main issues with the Wysocki paper were that it advocated for theoretically selecting covariates, and highlighted the problems surrounding measurement error, but it didn’t provide concrete steps for how to actually select covariates. They also felt that including specific examples (both from simulations and from our fields) could help make the points from the Wysocki article more concrete.

We discussed providing three main guidelines to help people determine whether they can use statistical control for making causal inferences, which can be supported by simulations and/or hypothetical population models:

(1) How confident do you feel in the reliability of your putative confounders?
	- Important to demonstrate reliability
	- May or may not require simulations (depending on how Wysocki et al. accounted for measurement error, and whether that captures the random nature of it)
(2) How confident do you feel that the variables you’ve included are actually confounders (and not colliders, mediators, proxies, potentially irrelevant variables, or independent causes of Y)?
	- Theoretical justifications are a good starting point
	- Drawing from other experimental and longitudinal studies can help
	- Temporal ordering can help
	- Correlations can possibly help rule out proxies and irrelevant variables, but they may also introduce bias
	- Here, simulations are helpful because people are making decisions based on the sample
(3) How confident do you feel that there are no omitted variables / additional confounds you haven’t measured or included?
	- People are probably not going to be very confident in this, but we might be able to provide suggestions for how they can increase their confidence

Other considerations:

- We need to figure out which of the above points require simulations and which can be supported by hypothetical population models
- We may also want to think of ordering these considerations in terms of which have the largest effects on bias
- We can mention that bias can be in either direction (and reference Wysocki article), but that we are simulating bias in just one direction
- We likely wouldn’t mix sources of bias (but instead say, here’s an additional problem even if you’ve solved the earlier ones)
- We can also make a plug for prediction methods at the end


# 2026-10-13

We discussed next directions to take after reading the Wysocki et al. (2022) article. We determined that the paper had done much of what we were planning to do (but, in some cases, in a cleaner way). We talked about how we'd have to position our study as an extension of that paper, and make sure that it was in fact contributing to the literature (and not simply replicating what they had done). We talked about the following potential ways that we could differentiate our paper / extend the Wysocki et al. paper:

- Explicitly testing the implication they make about data-driven approaches generally resulting in bias
- Examining Type I and Type II error rates (not just bias), which accounts for variance across research contexts and statistical significance
- Including two additional DGPs (irrelevant variables and independent causes of Y)
- Varying additional research contexts (e.g., amount of measurement error, relationship between C and Y)
- Examining cases where X has no effect on Y (given that false positives are often more problematic)


# 2026-10-6

We reviewed the PPT Elise had prepared for lab meeting, and discussed the following changes:

- Clarifying why covariates are used when analyzing experimental vs. observation data
- Moving the DGPs to the front (and referring to those terms, rather than "good" and "bad" covariates)
- Emphasizing the additional goal of our study (related to highlighting the problems with measurement error)
- Clarifying the steps to a simulation study
- Mentioning bias, not just Type I and Type II error rates


# 2026-09-29 & 2026-10-02

We executed our code though CHTC on a truncated version of jobs.csv, and successfully identified and fixed errors and warnings relating to string vs. numeric variables, where we sourced fun_cov2.R from, and namespace issues.

As next steps, Elise will:

- Prepare a 10-minute presentation for the Oct. 7 lab meeting, to frame a guided discussion for which research contexts to manipulate
- Remove calls to library
- Determine why we are getting 1000 jobs, instead of 500 [EG note: it's because we are running the code for two covariate selection approaches: all covariates, and no covariates]

Eventually, we can:

- Determine how many simulations we want to batch together
- Continue updating our combine.sh file to remove interim files, etc. (once we know everything is working)
- Decide which research contexts to manipulate (including DGPs), based on our discussion in lab meeting


# 2026-09-22

We reviewed and began updating the mak_jobs2.R, cov2.sub, and cov2.sh files. We also created error and results folders in our home directory.

As next steps, Elise will:

- Finish updating the three files to reflect the research contexts we are varying [EG note: I also need to update mak_jobs2.R to ensure that b_cy and b_cx appear as vectors in the format specified in fit_cov2.R]
- In mak_jobs2.R, define a more limited set of parameter values that we will vary to test out our code (including values that will require as much computational power as we expect we'll need, to be sure we have sufficient memory set up) 
- Make sure she has access to the lab research drive

Next time, we will:

- Test out our code on a limited number of jobs
- Determine whether train.sif needs to be included in the list of transfer files in cov2.sub (by running a subfile that doesn't include it and seeing if we get an error)

Eventually, we may also need to:

- Update requested memory and disk parameters in cov2.sub
- Change file naming in the mak_jobs2.R file (if we want to run different batches and combine them)


# 2026-09-15

We began updating the fit_cov file to run simulations. We will start with the causal covariates framework, and vary parameters as follows:

- The effect of X on Y: 0 (no effects) and 0.3 (moderate effects)
- Sample size: 100, 200, 300, and 500
- Correlation between covariates and X: 0.1 (small effects) and 0.3 (moderate effects) [EG note: are these the path coefficients?]
- Correlation between covariates and Y: 0.1 (small effects) and 0.3 (moderate effects) [will be the same as above]
- Number of covariates: 1, 2, and 4
- Number of simulations per research setting: 1,000

As next steps, Elise will:

- Install WinSCP to transfer files
- Set empirical as a parameter (equal to TRUE or FALSE)
- Prepare to present at the Oct. 7 lab meeting to talk through which research contexts to vary
- Update parameter names in the fun_cov file so they match what we have in fit_cov
- Extract vectors from the bracketed format we'll use in our .csv file 
- Generally tidy up the fit_cov file

Next time we meet, we will write CHTC code.


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
