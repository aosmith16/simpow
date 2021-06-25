#' Simulation-based power analysis for a linear mixed model
#'
#'Simulate data and perform a power analysis based on provided study design details and values for parameters. Data must be balanced. Models are fit with `nlme::lme()`can contain a single categorical fixed effect and a single random effect. Variances can be allowed to vary among the fixed effect. categories. The categorical fixed effect is referred to as "treatment" and the random effect is called "block".
#'
#' @param nsim Numeric. The number of simulations to run. Defaults to 1, which is useful if you are testing what the datasets look like or how long each analysis takes to run. Otherwise for the full power analysis you'll want to use a large number, such as 1000. Note that the more simulations you do the longer it will take to finish.
#' @param test Character. Can currently take "none" or "overall"; defaults to "overall". Use "none" if you only want simulated datasets. Use "overall" to do power analysis on overall F test of fixed effect.
#' @param alpha Numeric. The alpha value you want to test against. Defaults to 0.05.
#' @param ntrt Numeric. The number of categories or "treatments" that your categorical fixed effect will have. Defaults to 2. Value must be greater than 1.
#' @param trtmeans Numeric vector. The true means for each of your treatment groups.
#' @param trtnames Optional character vector. The names for each of your treatment groups. If not provided treatments will be named with letters.
#' @param nrep Numeric. Number of replicates within each treatment within each block. Defaults to 1.
#' @param nblock Numeric. Total number of blocks, where each treatment is replicated at least one time (based on `nrep`) in each block. Defaults to 5. Must be greater than 2.
#' @param sd_block Numeric. The true standard deviation based on the among-block variation. The standard deviation is the square root of the variance.
#' @param sd_resid Numeric. The true standard deviation of the errors, which you may refer to as the residual standard deviation. The standard deviation is the square root of the variance. If you want to assume equal standard deviations among treatments (the default), provide a single value. If you allow standard deviations to differ among treatments provide a vector that contains a standard deviation for each treatment.
#' @param sd_eq Logical. Whether or not to allow the variance of the errors should be constant among treatments. Defaults to `TRUE`.
#' @param keep_data Logical. Whether you want to keep the simulated datasets that are used in the power analysis. Defaults to `FALSE`. It may be useful to keep the datasets if you'd like to do additional exploration of the simulated results but this may make output very large.
#' @param keep_models Logical. Whether you want to keep the models fit to each simulated datasets for the power analysis. Defaults to `FALSE`. It may be useful to keep the models if you'd like to do additional exploration of the models but this may make output very large.
#'
#' @return The printed output contains information on the simulation and power analysis. The object contains a list containing information on the simulation details, design details and true parameters and, when `test = "overall"`, estimated power based on the sample size. These can be extracted from the object by name but vary depending on chosen options.
#'
#' \itemize{
#'   \item nsim - Number of simulations done.
#'   \item ntrt - Number of treatment groups.
#'   \item nblock - Number of blocks in study.
#'   \item nrep - Number of replications of each treatment group in each block.
#'   \item truemeans - Named vector of true treatment means used in simulation.
#'   \item truesd - List containing true block and observatin-level (residual) standard deviations used in simulation.
#'   \item data - If `keep_data = TRUE`, the simulated datasets used in the analysis. May be very large.
#'   \item power - Estimated number of p-values less than alpha, expressed as a percentage.
#'   \item alpha - Alpha used for power analysis.
#'   \item p.values - P-values from test for every model.
#'   \item models - If `keep_models = TRUE`, the fitted models for every simulated dataset. Maybe be very large.
#' }
#' @export
#'
#' @examples
#' # Power analysis based on 100 simulations for the overall test of two treatments.
#' # There is one replicate of each treatment in each of 10 blocks.
#' # Note the single residual SD.
#' simpow_lmm_f(nsim = 100,
#'              trtmeans = c(1, 25),
#'              nblock = 10,
#'              sd_block = 2,
#'              sd_resid = 4)
#'
#' # Allow variances to differ among treatments
#' simpow_lmm_f(nsim = 100,
#'              trtmeans = c(1, 25),
#'              nblock = 10,
#'              sd_block = 2,
#'              sd_resid = c(1, 20),
#'              sd_eq = FALSE
#'
#'  # Return simulated dataset for a single simulation
#'  # Here don't run power analysis via test = "none"
#' results = simpow_lmm_f(nsim = 1,
#'              test = "none",
#'              trtmeans = c(1, 25),
#'              nblock = 10,
#'              sd_block = 2,
#'              sd_resid = 4,
#'              keep_data = TRUE)
#' results$data
#'
#'\dontrun{
#' # Setting treatment names to match those in your study
#' # Seen in results only
#' results = simpow_lmm_f(nsim = 10,
#'              trtmeans = c(1, 25),
#'              trtnames = c("Control", "Treat1")
#'              sd_block = 2,
#'              sd_resid = 4)
#' results
#' }
simpow_lmm_f = function(nsim = 1, test = "overall", alpha = 0.05,
                        ntrt = 2, trtmeans,
                        trtnames = NULL, nrep = 1,
                        nblock = 5, sd_block,
                        sd_resid, sd_eq = TRUE,
                        keep_data = FALSE, keep_models = FALSE) {

    if(length(trtmeans) != ntrt) {
        stop(call. = FALSE,
             "You must provide a mean for every treatment group.\n",
             "Check that the number of means in trtmeans matches the value you put in ntrt.")
    }


    if(!is.null(trtnames) & length(trtnames) != ntrt) {
        stop(call. = FALSE,
             "You must provide a name for every treatment group.\n",
             "Check that the number of names in trtnames matches the value you put in ntrt.")
    }

    if(!sd_eq & length(sd_resid != ntrt)) {
        stop(call. = FALSE,
             "You are allowing nonconstant variance among treatments.\n",
             "Please provide a residual SD for every treatment group in sd_resid.")
    }


    if(is.null(trtnames)) {
        trtnames = LETTERS[1:ntrt]
    }

    if(nblock < 3) {
        stop(call. = FALSE,
             "The number of levels for your blocking random effect should be at least 3.")
    }

    makedata = function(.ntrt = ntrt,
                        .trtmeans = trtmeans,
                        .trtnames = trtnames,
                        .nrep = nrep,
                        .nblock = nblock,
                        .sd_block = sd_block,
                        .sd_resid = sd_resid) {

        # Create factors based on design (reps per treatment nested in blocks)
        blocks = rep(as.character(1:.nblock), each = .ntrt*.nrep)
        trt = rep(.trtnames, times = .nblock*.nrep)

        # Creat values for linear predictor
        blockeff = rep(stats::rnorm(n = .nblock, mean = 0, sd = .sd_block), each = .ntrt*.nrep)
        trteff = rep(.trtmeans, times = .nblock*.nrep)
        resid = stats::rnorm(n = .ntrt*.nblock*.nrep, mean = 0, sd = .sd_resid)
        y = trteff + blockeff + resid
        dat = data.frame(trt = trt,
                         blocks = blocks,
                         response = y)
        dat
    }

    # Create many datasets
    alldat = replicate(n = nsim, expr = makedata(), simplify = FALSE)

    # Create object to return
    res = list()

    res$nsim = nsim
    res$ntrt = ntrt
    res$nblock = nblock
    res$nrep = nrep
    res$truemeans = stats::setNames(trtmeans, trtnames)

    res$truesd = list(sd_block = sd_block,
                      sd_resid = sd_resid)
    if(keep_data) {
        res$data = alldat
    }

    class(res) = "simpow"

    # Return only data if no test done, otherwise fit models
    if(!test %in% c("none", "overall")) {
        stop(call. = FALSE,
             'Test must be either "none" or "overall".')
    }

    if(test == "none") {
        res
    }

    if(test == "overall") {
        if(sd_eq) {
            mods = lapply(alldat, fitmodel_eq)
        } else {
            mods = lapply(alldat, fitmodel_uneq)
        }
        p = unlist(lapply(mods, getp_lme))
        pow = mean(p < alpha)

        res$power = pow
        res$alpha = alpha
        res$p.values = p

        if(keep_models) {
            res$models = mods
        }
    }
    res
}
