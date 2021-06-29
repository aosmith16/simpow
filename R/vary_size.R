#' Vary sample size for simulations
#'
#' This is a convenience function that allows the user to vary one parameter or design element and perform a simulated power analysis for each provided value. All other parameters/design elements will be held fixed for all simulations.
#'
#' @param simfun Character. The name of the function you want to use for the simulations. Currently can only be `"lmm_f"`.
#' @param tovary Character. The name of the argument for the study design element you'd like to allow to vary in the function you defined in `simfun`. At the moment only a single element can vary at any one time. Currently defaults to `"nrep"`.
#' @param values Numeric vector. The values you want to use for the `tovary` argument. These will be looped over and a separate power analysis done for each provided value.
#' @param ... Other arguments to the function you defined in `simfun`.
#'
#' @return A data.frame with a row for each simulation done containing the study design information.
#'
#' @details This function is a simple wrapper around a loop to run through the values from your chosen parameter/design element and repeat the power analysis for each one. This is not a particularly efficient function, and you may want to use a different approach if exploring the power for a large number of values.
#'
#' @seealso [lmm_f()] for the function arguments you'll need to define in `...`.
#'
#' @export
#'
#' @examples
#' # Here's an example to explore the change in power
#'     # for 5 vs 15 blocks in lmm_f()
#' vary_size(tovary = "nblock",
#'           values = c(5, 15),
#'           nsim = 10,
#'           trtmeans = c(1, 2),
#'           sd_block = 2,
#'           sd_resid = 2)
#'
#' # Here is an example varying
#'     # the residual standard deviations
#' vary_size(tovary = "sd_resid",
#'           values = c(2, 10),
#'           nsim = 20,
#'           trtmeans = c(1, 2),
#'           nblock = 15,
#'           sd_block = 2)
vary_size = function(simfun = "lmm_f",
                     tovary = "nrep",
                     values,
                     ...) {
    loop_n = lapply(values, function(n) {
        val = list(n)
        names(val) = tovary
        res = do.call(simfun, c(val, list(...)))
        summary(res)
    })
    do.call("rbind", loop_n)
}
