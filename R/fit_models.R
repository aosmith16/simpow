
#' Model fitting helper functions, equal or unequal variances, plus p-value extraction
#'
#' Helper functions for fitting models, not currently exported.
#'
#' @param data Dataset to use in analysis
#' @param model Fitted lme object for extracting p-value
#'
#'
#' @importFrom nlme anova.lme
fitmodel_eq = function(data) {

    if(length(unique(data[["trt"]])) < 2) {
        stop(call. = FALSE,
             "You must have more than one treatment to fit a model. Check that ntrt > 1.\n",
             "Also consider using test = 'none' with nsim = 1 to look at a dataset.")
    }

    fit1 = try(nlme::lme(response ~ trt,
                         random = ~1|blocks,
                         data = data))
    class(fit1) = "try-error"
    while(inherits(fit1, "try-error")) {
        fit1 = try(nlme::lme(response ~ trt,
                             random = ~1|blocks,
                             data = data))
    }
    fit1
}

#' @rdname fitmodel_eq
fitmodel_uneq = function(data) {

    if(length(unique(data[["trt"]])) < 2) {
        stop(call. = FALSE,
             "You must have more than one treatment to fit a model. Check that ntrt > 1.\n",
             "Also consider using test = 'none' with nsim = 1 to look at a dataset.")
    }

    fit1 = try(nlme::lme(response ~ trt,
                         random = ~1|blocks,
                         weights = nlme::varIdent(form = ~1|trt),
                         data = data))
    class(fit1) = "try-error"
    while(inherits(fit1, "try-error")) {
        fit1 = try(nlme::lme(response ~ trt,
                             random = ~1|blocks,
                             weights = nlme::varIdent(form = ~1|trt),
                             data = data))
    }
    fit1
}

#' @rdname fitmodel_eq
getp_lme = function(model) {
    nlme::anova.lme(model)[2, ]$"p-value"
}
