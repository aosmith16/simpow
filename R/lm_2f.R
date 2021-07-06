#' Simulation-based power analysis for a 2 factor linear model
#'
#' Simulate data and perform a power analysis based on a simple blocked design with few blocks. Simulations are done on provided study design elements and values for model parameters. Data must be balanced. Models are fit with `stats::lm()` or `nlme::gls()` and can contain two categorical fixed effects with no interaction between them. The fixed effect of interest is referred to as "treatment" and the design-based fixed effect is called "block".  Variances can be allowed to vary among the treatment categories.
#'
#' @importFrom rlang inform
#'
#' @param nsim Numeric. The number of simulations to run. Defaults to 1, which is useful if you are testing what the simulated datasets look like or how long each analysis takes to run. Otherwise for the full power analysis you'll want to use a large number, such as 1000. Note that the more simulations you do the longer the power analysis will take.
#' @param test Character. Can currently take `"none"` or `"overall"`; defaults to `"overall"`. Use `"none"` if you only want the simulated datasets. Use `"overall"` to do a power analysis on the overall F test of fixed effect.
#' @param alpha Numeric. The alpha value you want to test against. Defaults to `0.05`.
#' @param allmeans Optional numeric vector of length `ntrt`*`nblock`. The true means for each treatment-block combination. The vector order matters. Provide the mean for each treatment for block 1, then the mean of each treatment for block 2, etc.  If you provide the combined means here then the values you give in `trtmeans` and `blockmeans` will be ignored.
#' @param ntrt Numeric. The number of categories or "treatments" that your categorical fixed effect will have. Defaults to `2`. Value must be greater than 1.
#' @param trtmeans Optional numeric vector of length `ntrt`. The true means for each of your treatment groups. You must provide `trtmeans` and `blockmeans` OR `allmeans`. Argument is ignored if you provide `allmeans`.
#' @param trtnames Optional character vector of length `ntrt`. The names for each of your treatment groups. If not provided the treatments will be named with letters.
#' @param nrep Numeric. Number of replicates within each treatment within each block. Defaults to 1.
#' @param nblock Numeric. Total number of blocks, where each treatment is replicated at least once per block. Defaults to `3`.
#' @param blockmeans Optional numeric vector of length `nblock`. The true means for each of your blocks. You must provide `trtmeans` and `blockmeans` OR `allmeans`.  Argument is ignored if you provide `allmeans`.
#' @param sd_resid Numeric. The true standard deviation of the errors, which you may hear referred to as the residual standard deviation. The standard deviation is the square root of the variance. If you want to assume equal standard deviations among treatments (the default), provide a single value. If you allow standard deviations to differ among treatments provide a vector that contains a standard deviation for each treatment.
#' @param sd_eq Logical. Whether or not to allow the variance of the errors to be constant among treatments. Defaults to `TRUE`.
#' @param keep_data Logical. Whether you want to keep the simulated datasets that are used in the power analysis. Defaults to `FALSE`. In some cases it will be useful to keep the datasets, such as if you'd like to do additional exploration of the simulated results. However, this may make the final output quite large.
#' @param keep_models Logical. Whether you want to keep the models fit to each simulated dataset in the power analysis. Defaults to `FALSE`. It may be useful to keep the models if you'd like to do additional exploration of them but this may make output quite large.
#'
#' @return The printed output contains information on the simulation design elements and paramters as well as the estimated power.
#'
#' The returned object contains a list containing information on the simulation details, design details and true parameters and, when `test = "overall"`, estimated power based on the sample size. These can be extracted from the object by name. Note that which values are returned varies depending on chosen options.\tabular{ll}{
#'   \code{nsim} \tab Number of simulations done. \cr
#'   \code{ntrt} \tab Number of treatment groups. \cr
#'   \code{nblock} \tab Number of blocks in study. \cr
#'   \code{nrep} \tab Number of replications of each treatment group in each block. \cr
#'   \code{truemeans} \tab Named vector of true treatment by block means used in simulation. Names are given as trtname.blockname. \cr
#'   \code{truesd} \tab Observation-level (residual) standard deviation(s) used in simulation. \cr
#'   \code{data} \tab If \code{keep_data = TRUE}, a list containing the simulated datasets used in the analysis. May be very large. \cr
#'   \code{power} \tab Estimated number of p-values less than alpha, expressed as a percentage. \cr
#'   \code{alpha} \tab Alpha used for power analysis. \cr
#'   \code{p.values} \tab P-values from test for every model. \cr
#'   \code{models} \tab If \code{keep_models = TRUE}, a list containing the fitted models for every simulated dataset. May be very large.\cr
#' }
#' @details This function is an alternative to `lmm_f.R` for a power analysis based on simulating from a basic blocked design when the number of blocks is low and you want to treat the blocking variable as fixed instead of random. The default power analysis has a single replicate per treatment per block like you might have in many completely randomized block designs. You can increase the number of replicates per treatment per block but the model does not allow for a treatment-by-block interaction. The model form is essentially `response ~ block + treatment`.
#' @seealso See [lmm_f()] for an alternative with blocks as a random effect. Use [vary_element()] to run through multiple power analyses using different parameters or design elements.
#'
#' @export
#'
#' @examples
#' # Power analysis based on 100 simulations for the overall test of two treatments.
#' # There is one replicate of each treatment in each of 3 blocks.
#' # Note the single residual SD and separate trt and block means.
#' lm_2f(nsim = 100,
#'       trtmeans = c(40, 50),
#'       nblock = 3,
#'       blockmeans = c(35, 50, 50),
#'       sd_resid = 4)
#'
#' # Allow more trt reps per block
#' # Switching to use combined trt-block means
#' lm_2f(nsim = 100,
#'       allmeans = c(30, 40, 45, 55, 45, 55),
#'       nblock = 3,
#'       nrep = 2,
#'       sd_resid = 4)
#'
#' # Allow variances to differ among treatments
#' lm_2f(nsim = 100,
#'       allmeans = c(30, 40, 45, 55, 45, 55),
#'       nblock = 3,
#'       sd_resid = c(1, 20),
#'       sd_eq = FALSE)
#'
#' # Change the number of treatment groups and blocks
#' lm_2f(nsim = 100,
#'       ntrt = 3,
#'       allmeans = c(30, 40, 45, 55, 45, 55),
#'       nblock = 2,
#'       sd_resid = 4)
#'
#' # Return simulated dataset for a single simulation
#' # Here don't run power analysis via test = "none"
#' results = lm_2f(nsim = 1,
#'                 test = "none",
#'                 allmeans = c(30, 40, 45, 55, 45, 55),
#'                 nblock = 3,
#'                 sd_resid = 4,
#'                 keep_data = TRUE)
#' results$data
#'
#' # Setting treatment names to match those in your study
#' # Seen in results only
#' results = lm_2f(nsim = 1,
#'                 allmeans = c(30, 40, 45, 55, 45, 55),
#'                 trtnames = c("Control", "Treat1"),
#'                 sd_resid = 4,
#'                 keep_data = TRUE)
#' results$data
lm_2f = function(nsim = 1, test = "overall", alpha = 0.05,
                 allmeans = NULL,
                 ntrt = 2, trtmeans = NULL,
                 trtnames = NULL, nrep = 1,
                 nblock = 3, blockmeans = NULL,
                 sd_resid, sd_eq = TRUE,
                 keep_data = FALSE, keep_models = FALSE) {

    if(is.null(allmeans) & length(trtmeans) != ntrt) {
        stop(call. = FALSE,
             "You must provide allmeans or a mean for every treatment group.\n",
             "Check that the number of means in trtmeans matches the ntrt value.")
    }

    if(!is.null(trtnames) & length(trtnames) != ntrt) {
        stop(call. = FALSE,
             "You must provide a name for every treatment group.\n",
             "Check that the number of names in trtnames matches the ntrt value.")
    }

    if(is.null(allmeans) & length(blockmeans) != nblock) {
        stop(call. = FALSE,
             "You must provide allmeans or a mean for every block.\n",
             "Check that the number of means in blockmeans matches the nblock value.")
    }

    if(!is.null(allmeans) & length(allmeans) != ntrt*nblock) {
        stop(call. = FALSE,
             "You must provide a mean for every treatment-block combination.\n",
             "Check that the number of means in allmeans matches ntrt*nblock.")
    }

    if(!is.null(allmeans) & (!is.null(trtmeans) | !is.null(blockmeans))) {
        warning(call. = FALSE,
                "Using allmeans in simulation. Will ignore any values in trtmeans and blockmeans.")
    }

    suppressWarnings(if(is.null(allmeans) &
       mean(trtmeans) !=mean(blockmeans)) {
        stop(call. = FALSE,
             "The mean of trtmeans must equal the mean of blockmeans.")
    })

    if(!sd_eq & length(sd_resid) != ntrt) {
        stop(call. = FALSE,
             "You are allowing nonconstant variance among treatments.\n",
             "Please provide a residual SD for each treatment group in sd_resid but no more.")
    }

    if(sd_eq & length(sd_resid) > 1) {
        stop(call. = FALSE,
             "You are allowing constant variance among treatments but have provided >1 sd_resid.\n",
             "Do you want sd_eq = FALSE?")
    }


    if(nblock > 4) {
        rlang::inform("You have at least 5 blocks. Are you certain you want to treat them as fixed?",
                      .frequency = "once",
                      .frequency_id = "nblock")
    }

    if(is.null(trtnames)) {
        trtnames = LETTERS[1:ntrt]
    }


    blocknames = as.character(1:nblock)
    name = expand.grid(trtnames, blocknames)
    allnames = paste(name[, 1], name[, 2], sep = ".")

    if(is.null(allmeans)) {
        allmeans = mean(trtmeans) +
            rowSums(expand.grid((trtmeans - mean(trtmeans)), (blockmeans - mean(trtmeans))))
    }

    .makedata = function(.ntrt = ntrt,
                        .trtnames = trtnames,
                        .nrep = nrep,
                        .nblock = nblock,
                        .blocknames = blocknames,
                        .allmeans = allmeans,
                        .sd_resid = sd_resid,
                        .sd_eq = sd_eq) {

        # Create factors based on design (reps per treatment nested in blocks)
        blocks = rep(.blocknames, each = .ntrt*.nrep)
        trt = rep(.trtnames, times = .nblock, each = .nrep)

        # Create values for linear predictor
        combeff = rep(.allmeans, each = .nrep)
        resid = stats::rnorm(n = .ntrt*.nblock*.nrep, mean = 0, sd = .sd_resid)

        # Reorder resid to match order above if non-constant variance
        if(!.sd_eq) {
            trt2 = rep(.trtnames, times = .nblock*.nrep)
            residorder = data.frame(blocks, trt2, resid)
            residorder = residorder[order(residorder$blocks, residorder$trt2), ]
            resid = residorder$resid
        }
        y = combeff + resid
        dat = data.frame(trt = trt,
                         blocks = blocks,
                         response = y)
        dat
    }

    # Create many datasets
    alldat = replicate(n = nsim, expr = .makedata(), simplify = FALSE)

    # Create object to return
    res = list()

    res$nsim = nsim
    res$ntrt = ntrt
    res$nblock = nblock
    res$nrep = nrep
    res$truemeans = stats::setNames(allmeans, allnames)

    res$truesd = list(sd_resid = sd_resid)
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
            mods = lapply(alldat, fitlm_2f_eq)
        } else {
            mods = lapply(alldat, fitlm_2f_uneq)
        }
        p = unlist(lapply(mods, getp_lm_2f))
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
