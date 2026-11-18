# conduct power analysis to identify appropriate sample size
pwr_n <- ceiling(pwr::pwr.r.test(
  r = 0.3,           
  sig.level = 0.05,
  power = 0.80,
  n = NULL,          
  alternative = "two.sided"
)$n)