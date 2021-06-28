test_that("error if means vector length doesn't match num trt", {
    expect_error(lmm_f(ntrt = 2, trtmeans = c(1, 2, 3)),
                 "You must provide a mean")
})

test_that("error if trt names vector length doesn't match num trt", {
    expect_error(lmm_f(ntrt = 2, trtmeans = c(1, 2),
                       trtnames = c("a")),
                 "You must provide a name")
})

test_that("error if nonconstant variance sd vector length doesn't match num trt", {
    expect_error(lmm_f(trtmeans = c(1, 2),
                       sd_resid = c(1, 2, 3), sd_eq = FALSE),
                 "You are allowing nonconstant variance")
})

test_that("at least 3 blocking groups", {
    expect_error(lmm_f(ntrt = 2, trtmeans = c(1, 2),
                       nblock = 2, sd_resid = 2),
                 "The number of groups")
})

test_that("data length matches design parameters", {
    ntrt = 2
    nblock = 3
    nrep = 2
    res = lmm_f(test = "none",
                ntrt = ntrt,
                trtmeans = c(1, 25),
                nblock = nblock,
                nrep = nrep,
                sd_block = 2,
                sd_resid = 4,
                keep_data = TRUE)
    expect_equal(nrow(res$data[[1]]), ntrt*nblock*nrep)
})
