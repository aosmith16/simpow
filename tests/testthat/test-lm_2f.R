test_that("error if trt means vector length doesn't match num trt", {
    expect_error(lm_2f(ntrt = 2, trtmeans = c(1, 2, 3)),
                 "You must provide allmeans")
})

test_that("error if block means vector length doesn't match num blocks", {
    expect_error(lm_2f(ntrt = 2, trtmeans = c(1, 1),
                       nblock = 3, blockmeans = rep(1, 4),
                       sd_resid = 2),
                 "You must provide allmeans")
})

test_that("error if all means vector length doesn't match num trt*blocks", {
    expect_error(lm_2f(ntrt = 2,
                       nblock = 3,
                       allmeans = rep(1, 5),
                       sd_resid = 2),
                 "You must provide a mean")
})

test_that("error if trt names vector length doesn't match num trt", {
    expect_error(lm_2f(ntrt = 2, trtmeans = c(1, 2),
                       trtnames = c("a")),
                 "You must provide a name")
})


test_that("error if nonconstant variance sd vector length doesn't match num trt", {
    expect_error(lm_2f(trtmeans = c(40, 50),
                       blockmeans = c(35, 50, 50),
                       sd_resid = c(1, 2, 3),
                       sd_eq = FALSE),
                 "You are allowing nonconstant variance")
})

test_that("mean to have constant variance", {
    expect_error(lm_2f(nrep = 2,
                       allmeans = c(30, 40, 45, 55, 45, 55),
                       sd_resid = c(1, 100)),
                 "You are allowing constant variance")
})

test_that("error if marginal means don't match", {
    expect_error(lm_2f(trtmeans = c(1, 1),
                       blockmeans = c(2, 2, 2),
                       sd_resid = 1),
                 "The mean of trtmeans must equal")
})

test_that("warnings if provide both allmeans and others", {

    expect_warning(lm_2f(ntrt = 2, trtmeans = c(1, 2), sd_resid = 2,
                         allmeans = c(1, 2, 1, 2, 1, 2)),
                   "Using allmeans in simulation")

    expect_warning(lm_2f(ntrt = 2, blockmeans = c(1, 2, 3), sd_resid = 2,
                        allmeans = c(1, 2, 1, 2, 1, 2)),
                  "Using allmeans in simulation")
})

test_that("data length matches design parameters", {
    ntrt = 2
    nblock = 3
    nrep = 2
    res = lm_2f(test = "none",
                ntrt = ntrt,
                nblock = nblock,
                allmeans = rep(1, ntrt*nblock),
                nrep = nrep,
                sd_resid = 4,
                keep_data = TRUE)
    expect_equal(nrow(res$data[[1]]), ntrt*nblock*nrep)
})

test_that("data is ordered by blocks then treatments", {

    res1 = lm_2f(test = "none",
                 ntrt = 2,
                 allmeans = rep(1, 10),
                 nblock = 5,
                 nrep = 1,
                 sd_resid = 4,
                 keep_data = TRUE)$data[[1]]

    trt1 = rep(LETTERS[1:2], times = 5, each = 1)
    block1 = rep(as.character(1:5), each = 2)

    expect_equal(res1[, 1], trt1)
    expect_equal(res1[, 2], block1)

    res2 = lm_2f(test = "none",
                 ntrt = 2,
                 allmeans = rep(1, 10),
                 nblock = 5,
                 nrep = 3,
                 sd_resid = 4,
                 keep_data = TRUE)$data[[1]]

    trt2 = rep(LETTERS[1:2], times = 5, each = 3)
    block2 = rep(as.character(1:5), each = 2*3)

    expect_equal(res2[, 1], trt2)
    expect_equal(res2[, 2], block2)
})


test_that("calculating combined means correctly", {
    mean1 = c(35, 40)
    mean2 = c(32.5, 27.5, 52.5)
    allmeans = mean(mean1) +
        rowSums(expand.grid((mean1 - mean(mean1)), (mean2 - mean(mean2))))
    expect_equal(allmeans, c(30, 35, 25, 30, 50, 55))

    mean3 = c(40, 50)
    mean4 = c(35, 50, 50)
    allmeans2 = mean(mean3) +
        rowSums(expand.grid((mean3 - mean(mean3)), (mean4 - mean(mean4))))
    expect_equal(allmeans2, c(30, 40, 45, 55, 45, 55))
})

test_that("get resid order to match dataset when nonconstant variance", {
    # ntrt 2, nblock 3, nrep 2
    set.seed(16)
    blocks = rep(as.character(1:3), each = 2*2)
    trt = rep(LETTERS[1:2], times = 3, each = 2)

    # Create values for linear predictor
    combeff = rep(c(30, 40, 45, 55, 45, 55), each = 2)
    resid = stats::rnorm(n = 2*3*2, mean = 0, sd = c(1, 100))

    # Reorder resid to match order above if non-constant variance
    trt2 = rep(LETTERS[1:2], times = 3*2)
    residorder = data.frame(blocks, trt2, resid)
    residorder = residorder[order(residorder$blocks, residorder$trt2), ]
    resid = residorder$resid

    y = combeff + resid

    set.seed(16)
    res = lm_2f(test = "none",
                allmeans = c(30, 40, 45, 55, 45, 55),
                nrep = 2,
                sd_resid = c(1, 100),
                sd_eq = FALSE,
                keep_data = TRUE)$data[[1]]$response

    expect_equal(resid, c(0.476413393493845, 1.09621619893093, -12.5379998377005, -144.422903512362,
                          1.14782929548965, -1.00595059489047, -46.8412042880619, 6.35626782142669,
                          1.0249725985369, 1.84718210064237, 57.3142017009185, 11.1933369409721))
    expect_equal(y, c(30.4764133934938, 31.0962161989309, 27.4620001622995, -104.422903512362,
                      46.1478292954897, 43.9940494051095, 8.1587957119381, 61.3562678214267,
                      46.0249725985369, 46.8471821006424, 112.314201700919, 66.1933369409721))

    expect_equal(y, res)
    expect_equal(residorder$trt2, trt)
})

