test_that("returned output is same manual calls", {
    set.seed(16)
    res = vary_element(tovary = "nblock",
                    values = c(5, 15),
                    nsim = 10,
                    trtmeans = c(1, 2),
                    sd_block = 2,
                    sd_resid = 2)

    set.seed(16)
    man1 = summary(lmm_f(nsim = 10,
                         trtmeans = c(1, 2),
                         nblock = 5,
                         sd_block = 2,
                         sd_resid = 2))

    man2 = summary(lmm_f(nsim = 10,
                         trtmeans = c(1, 2),
                         nblock = 15,
                         sd_block = 2,
                         sd_resid = 2))

    expect_equal(res, rbind(man1, man2))
})
