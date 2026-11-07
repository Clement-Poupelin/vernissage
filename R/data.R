#' Simulated clinical cohort with two visits
#'
#' A simulated cohort (no real patient) in wide format, used in the examples,
#' tests and vignettes: 120 subjects randomised to two arms, measured at
#' baseline (`_V0`) and at follow-up (`_V3`). It reproduces the usual
#' difficulties of cohort data: skewed biomarkers, values piled at a limit of
#' detection, gross outliers, bounded integer scores, a bilateral measure and
#' missing values, more frequent at follow-up.
#'
#' @format A data frame with 120 rows and 21 columns:
#' \describe{
#'   \item{ID}{Subject identifier (`P001` to `P120`).}
#'   \item{GROUP}{Treatment arm, factor (`Placebo`, `Active`).}
#'   \item{SEX}{Factor (`Female`, `Male`).}
#'   \item{AGE}{Age at baseline, years.}
#'   \item{BMI}{Body mass index, kg/m2 (a few missing values).}
#'   \item{NFL_V0, NFL_V3}{Neurofilament light chain, pg/mL (log-normal,
#'     increasing with age).}
#'   \item{IL6_V0, IL6_V3}{Interleukin-6, pg/mL; values below the limit of
#'     detection are reported at 0.5.}
#'   \item{CRP_V0, CRP_V3}{C-reactive protein, mg/L (skewed; two gross
#'     outliers at baseline).}
#'   \item{MOCA_V0, MOCA_V3}{Montreal Cognitive Assessment, integer 10-30.}
#'   \item{UPDRS_V0, UPDRS_V3}{Motor score (UPDRS part III), integer.}
#'   \item{FALL_V0, FALL_V3}{Falls in the last year, factor (`No`, `Yes`).}
#'   \item{PUT_L_V0, PUT_R_V0, PUT_L_V3, PUT_R_V3}{Left and right putamen
#'     volume, mL.}
#' }
#' @source Simulated, see `data-raw/cohort_sim.R` in the source package.
#' @examples
#' str(cohort_sim)
"cohort_sim"
