#' print method for simpow objects
#'
#' @param x The output from a power analysis function
#' @param ... additional arguments, not currently used
#'
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
    }
}
