
#' Model fitting helper functions, equal or unequal variances, plus p-value extraction
#'
#' Helper functions for fitting models, not currently exported.
#'
#' @param data Dataset to use in analysis
#' @param model Fitted lme object for extracting p-value
#'
#'
#' @importFrom nlme anova.lme
fitlmm_f_eq = function(data) {

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

#' @rdname fitlmm_f_eq
fitlmm_f_uneq = function(data) {

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

#' @rdname fitlmm_f_eq
fitlm_2f_eq = function(data) {

    if(length(unique(data[["trt"]])) < 2) {
        stop(call. = FALSE,
             "You must have more than one treatment to fit a model. Check that ntrt > 1.\n",
             "Also consider using test = 'none' with nsim = 1 to look at a dataset.")
    }

    fit1 = try(stats::lm(response ~ blocks + trt,
                         data = data))
    class(fit1) = "try-error"
    while(inherits(fit1, "try-error")) {
        fit1 = try(stats::lm(response ~ blocks + trt,
                             data = data))
    }
    fit1
}

#' @rdname fitlmm_f_eq
fitlm_2f_uneq = function(data) {

    if(length(unique(data[["trt"]])) < 2) {
        stop(call. = FALSE,
             "You must have more than one treatment to fit a model. Check that ntrt > 1.\n",
             "Also consider using test = 'none' with nsim = 1 to look at a dataset.")
    }

    fit1 = try(nlme::gls(response ~ blocks + trt,
                         weights = nlme::varIdent(form = ~1|trt),
                         data = data))
    class(fit1) = "try-error"
    while(inherits(fit1, "try-error")) {
        fit1 = try(nlme::gls(response ~ blocks + trt,
                             weights = nlme::varIdent(form = ~1|trt),
                             data = data))
    }
    fit1
}

#' @rdname fitlmm_f_eq
getp_lmm_f = function(model) {
    nlme::anova.lme(model)[2, ]$"p-value"
}

#' @rdname fitlmm_f_eq
getp_lm_2f = function(model) {
    if(class(model) == "lm") {
        stats::anova(model)[2, ]$`Pr(>F)`
    } else if(class(model) == "gls") {
        anova.gls = utils::getFromNamespace("anova.gls", "nlme")
        anova.gls(model)[3, ]$"p-value"
    }
}
