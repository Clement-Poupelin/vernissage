# Simulated cohort used in the examples, tests and vignettes of vernissage.
# Sourced when the package is installed (lazy data); only `cohort_sim` is kept.
# The same code is in data-raw/cohort_sim.R, with the steps to store it as .rda.
cohort_sim <- local({
  set.seed(2026)
  n <- 120
  clamp <- function(x, lo, hi) pmin(pmax(x, lo), hi)
  id <- sprintf("P%03d", seq_len(n))
  group <- factor(sample(c("Placebo", "Active"), n, replace = TRUE), levels = c("Placebo", "Active"))
  sex <- factor(sample(c("Female", "Male"), n, replace = TRUE, prob = c(0.45, 0.55)), levels = c("Female", "Male"))
  age <- round(stats::rnorm(n, 65, 8))
  bmi <- round(stats::rnorm(n, 26, 4), 1)

  # neurofilament light chain: log-normal, increases with age and between visits
  lnfl0 <- log(12) + 0.02 * (age - 65) + stats::rnorm(n, 0, 0.45)
  nfl0 <- round(exp(lnfl0), 1)
  nfl3 <- round(nfl0 * exp(stats::rnorm(n, 0.08, 0.15)), 1)

  # interleukin-6: log-normal, values below the limit of detection reported at 0.5
  lil0 <- log(1.2) + stats::rnorm(n, 0, 0.8)
  il0 <- round(pmax(exp(lil0), 0.5), 2)
  il3 <- round(pmax(exp(lil0 + stats::rnorm(n, -0.05, 0.5)), 0.5), 2)

  # C-reactive protein: strongly skewed, two gross outliers
  crp0 <- round(exp(log(2) + stats::rnorm(n, 0, 1)), 2)
  crp3 <- round(exp(log(crp0) + stats::rnorm(n, 0, 0.6)), 2)
  crp0[c(7, 58)] <- crp0[c(7, 58)] * 15

  # MoCA (0-30) and UPDRS part III (integer scores)
  z <- (lnfl0 - mean(lnfl0)) / stats::sd(lnfl0)
  moca0 <- clamp(round(27 - 0.08 * (age - 65) - 1.2 * z + stats::rnorm(n, 0, 1.8)), 10, 30)
  moca3 <- clamp(round(moca0 - 0.5 + stats::rnorm(n, 0, 1.4)), 10, 30)
  updrs0 <- pmax(0, round(25 + 3 * z + stats::rnorm(n, 0, 8)))
  updrs3 <- pmax(0, round(updrs0 + 3 - 2 * (group == "Active") + stats::rnorm(n, 0, 4)))

  # falls in the last year
  fall0 <- factor(ifelse(stats::runif(n) < stats::plogis(-1.2 + 0.06 * (updrs0 - 25)), "Yes", "No"),
                  levels = c("No", "Yes"))
  fall3 <- factor(ifelse(stats::runif(n) < stats::plogis(-1.0 + 0.06 * (updrs3 - 25)), "Yes", "No"),
                  levels = c("No", "Yes"))

  # putamen volume (mL), left and right
  putl0 <- round(stats::rnorm(n, 4.5, 0.5), 2)
  putr0 <- round(putl0 + stats::rnorm(n, 0, 0.2), 2)
  putl3 <- round(putl0 - stats::rnorm(n, 0.05, 0.05), 2)
  putr3 <- round(putr0 - stats::rnorm(n, 0.05, 0.05), 2)

  d <- data.frame(
    ID = id, GROUP = group, SEX = sex, AGE = age, BMI = bmi,
    NFL_V0 = nfl0, NFL_V3 = nfl3, IL6_V0 = il0, IL6_V3 = il3, CRP_V0 = crp0, CRP_V3 = crp3,
    MOCA_V0 = moca0, MOCA_V3 = moca3, UPDRS_V0 = updrs0, UPDRS_V3 = updrs3,
    FALL_V0 = fall0, FALL_V3 = fall3,
    PUT_L_V0 = putl0, PUT_R_V0 = putr0, PUT_L_V3 = putl3, PUT_R_V3 = putr3,
    stringsAsFactors = FALSE)

  # missing values: more at the second visit (drop-outs)
  na_at <- function(x, p) {
    x[sample.int(n, round(p * n))] <- NA
    x
  }
  d$BMI <- na_at(d$BMI, 0.03)
  d$CRP_V0 <- na_at(d$CRP_V0, 0.04)
  d$PUT_R_V0 <- na_at(d$PUT_R_V0, 0.05)
  drop <- sample.int(n, 10)
  for (v in c("NFL_V3", "IL6_V3", "CRP_V3", "MOCA_V3", "UPDRS_V3", "FALL_V3", "PUT_L_V3", "PUT_R_V3")) {
    d[[v]][drop] <- NA
  }
  d$NFL_V3 <- na_at(d$NFL_V3, 0.04)
  d$MOCA_V3 <- na_at(d$MOCA_V3, 0.03)
  d
})
