
<!-- README.md is generated from README.Rmd. Please edit that file -->

# simpow: Simulation-based power analysis for basic linear mixed models

<!-- badges: start -->
<!-- badges: end -->

The goal of this package is to provide helper functions for simple power
analyses based on linear mixed models. (Support for generalized linear
mixed models will be added in the future.)

## Installation

And the development version from [GitHub](https://github.com/) with:

You can install the **simpow** from GitHub:

    devtools::install_github("aosmith16/simpow")

## Example

The primary function in **simpow** at the moment is called
`simpow_lmm_f()`, which uses `nlme::lme()` to fit models under the hood.

Use it to run a simulation-based power analysis of a LMM with a single
random effect (“block”) and a single, categorical fixed effect called
“treatment”.

By default there are two groups for the treatment variable (`ntrt = 2`).
You need to provide the “true” means for those groups as well as a block
and observation-level (residual) standard deviation.

Here is the power to detect that at least one of the treatment means is
different based on 100 simulations, treatment means of 1 and 4, and the
provided standard deviations.

I show only 100 simulations here to save time. I set the seed only to
make these results reproducible. You will generally not set the seed
when using **simpow**.

    library(simpow)
    set.seed(16) 
    simpow_lmm_f(nsim = 100,
                 ntrt = 2,
                 trtmeans = c(1, 4),
                 nblock = 10,
                 sd_block = 2,
                 sd_resid = 4)
    #> Power analysis based on 100 simulations
    #> 
    #> Estimated power with alpha = 0.05: 35%
    #> Total number replicates per treatment per block: 1 
    #> Number treatments: 2 
    #> Number blocks: 10 
    #> Total observations in each dataset: 20

Do more groups by changing `ntrt` away from the default.

    simpow_lmm_f(nsim = 100,
                 ntrt = 3,
                 trtmeans = c(1, 3, 4),
                 nblock = 10,
                 sd_block = 2,
                 sd_resid = 4)
    #> Power analysis based on 100 simulations
    #> 
    #> Estimated power with alpha = 0.05: 24%
    #> Total number replicates per treatment per block: 1 
    #> Number treatments: 3 
    #> Number blocks: 10 
    #> Total observations in each dataset: 30

The default power analysis has a single replicate per treatment per
block, like you might have in many completely randomized block designs,
but this can be changed. Here there are 5 replicates for every treatment
in every block for a total of 100 observations in each dataset.

    simpow_lmm_f(nsim = 100,
                 ntrt = 2,
                 trtmeans = c(1, 4),
                 nblock = 10,
                 nrep = 5,
                 sd_block = 2,
                 sd_resid = 4)
    #> Power analysis based on 100 simulations
    #> 
    #> Estimated power with alpha = 0.05: 96%
    #> Total number replicates per treatment per block: 5 
    #> Number treatments: 2 
    #> Number blocks: 10 
    #> Total observations in each dataset: 100

### Nonconstant variance

If it makes sense to allow different variances per treatment group, use
`sd_eq = FALSE`. You then must provide a separate standard deviation for
every treatment group in `sd_resid` or you will get an error.

These models tend to fit more slowly than models assuming constant
variance of the errors so run times will be longer.

    simpow_lmm_f(nsim = 100,
                 ntrt = 2,
                 trtmeans = c(1, 4),
                 nblock = 10,
                 nrep = 5,
                 sd_block = 2,
                 sd_resid = c(1, 4),
                 sd_eq = FALSE)
    #> Power analysis based on 100 simulations
    #> 
    #> Estimated power with alpha = 0.05: 100%
    #> Total number replicates per treatment per block: 5 
    #> Number treatments: 2 
    #> Number blocks: 10 
    #> Total observations in each dataset: 100

### Simulated datasets

If you want to create the simulate datasets instead of (or in addition
to) doing the power analysis, use `keep_data = TRUE`. Note the use
`test = "none"` to skip the power analysis all together, where the
default `test = "overall"` does a power analysis on the overall F test
of the fixed effect.

The dataset can then by extracted from the output object via `data`.

    results = simpow_lmm_f(nsim = 2,
                           test = "none",
                           ntrt = 2,
                           trtmeans = c(1, 4),
                           nblock = 5,
                           sd_block = 2,
                           sd_resid = 4,
                           keep_data = TRUE)
    results$data
    #> [[1]]
    #>    trt blocks   response
    #> 1    A      1  6.6186882
    #> 2    B      1  7.5311949
    #> 3    A      2  2.8678492
    #> 4    B      2  6.8877437
    #> 5    A      3  6.3500780
    #> 6    B      3  0.2118523
    #> 7    A      4  6.3725285
    #> 8    B      4  2.1218322
    #> 9    A      5  1.7667563
    #> 10   B      5 -0.2636174
    #> 
    #> [[2]]
    #>    trt blocks  response
    #> 1    A      1  7.356902
    #> 2    B      1  5.473757
    #> 3    A      2 -3.432511
    #> 4    B      2  7.620205
    #> 5    A      3  2.532940
    #> 6    B      3  9.150134
    #> 7    A      4 -4.082824
    #> 8    B      4 -4.615184
    #> 9    A      5  7.372093
    #> 10   B      5 13.376858

Similarly you can keep fitted models via `keep_models = TRUE` and
extracting via `models`. (Not shown.) Other values you can extract from
the returned object is the vector of p-values (`p.values`).
