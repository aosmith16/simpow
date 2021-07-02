#' methods for simpow objects
#'
#' @param x The output from a power analysis function
#' @param object The output from a power analysis function
#' @param ... additional arguments to functions, not currently used
#'
#' @return Power is reported as a percentage in `summary()` and `print()`, so had been pre-multiplied by 100.
#'
#' @details
#' The `print()` function returns a written summary of the power analysis to the Console.
#' The `summary()` function returns a data.frame of design details and the power, primarily useful if varying design details and running more than one power analyses.
#' @export
print.simpow = function(x, ...) {

    if(is.null(x[["power"]])) {
        cat("Simulated datasets:", x[["nsim"]])
    } else {
        cat("Power analysis based on", x[["nsim"]], "simulations\n")
        cat("\n")
        cat("Estimated power with alpha = ", x[["alpha"]], ": ", round(x[["power"]]*100, 2), "%\n", sep = "")
        cat("Total number replicates per treatment per block:", x[["nrep"]], "\n")
        cat("Number treatments:", x[["ntrt"]], "\n")
        cat("Number blocks:", x[["nblock"]], "\n")
        cat("Total observations in each dataset:", x[["ntrt"]]*x[["nblock"]]*x[["nrep"]])
        cat("\n")
    }
}

#' @rdname print.simpow
#' @export
summary.simpow = function(object, ...) {
    # Note difficulty when sd_block or other is NULL; research better approach
    d1 = data.frame(ntrt = object[["ntrt"]],
               nblock = object[["nblock"]],
               nrep = object[["nrep"]],
               total_samp = object[["ntrt"]]*object[["nblock"]]*object[["nrep"]],
               sd_block = I(list(object[["truesd"]]$sd_block)),
               sd_resid = object[["truesd"]]$sd_resid,
               alpha = object[["alpha"]],
               power = object[["power"]]*100)
    d1$sd_block = unlist(d1$sd_block)
    d1
}
