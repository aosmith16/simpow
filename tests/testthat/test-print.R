test_that("summary returns sd_block for lmm_f", {
    res = summary(lmm_f(nsim = 10,
                 ntrt = 2,
                 trtmeans = c(1, 4),
                 nblock = 10,
                 nrep = 5,
                 sd_block = 2,
                 sd_resid = 4))

    expect_match(names(res), "sd_block", all = FALSE)
})

test_that("summary does not return sd_block for lm_2f", {
    res = summary(lm_2f(nsim = 10,
                         allmeans = c(1, 2, 3, 4, 5, 6),
                         ntrt = 2,
                         nblock = 3,
                         nrep = 5,
                         sd_resid = 4))

    expect_match(names(res), "[^[sd_block]")
})
