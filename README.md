
<!-- README.md is generated from README.Rmd. Please edit that file -->

# simpow: Simulation-based power analysis for basic linear mixed models

<!-- badges: start -->
<!-- badges: end -->

The goal of this package is to provide helper functions for simple power
analyses based on linear mixed models (LMM’s). (Support for generalized
linear mixed models will be added in the future.)

## Installation

And the development version from [GitHub](https://github.com/) with:

You can install the **simpow** from GitHub:

    devtools::install_github("aosmith16/simpow")

## Example of `lmm_f()`

The primary function in **simpow** at the moment is called `lmm_f()`,
which uses `nlme::lme()` to fit models under the hood.

Use this function to run a simulation-based power analysis of a LMM with
a single random effect (“block”) and a single, categorical fixed effect
called “treatment”.

By default there are two groups for the treatment variable (`ntrt = 2`).
You need to provide the “true” means for those groups as well as a block
and observation-level (residual) standard deviation.

Here is the power to detect that at least one of the treatment means is
different based on 100 simulations using an alpha of 0.05. I set the
treatment means to 1 and 4 and standard deviations of 2 and 4 for the
block random effect and residual error term.

You will generally want more than 100 simulations. I use that here to
save time. I set the seed to make these results reproducible but most
often you will not set the seed when using functions from **simpow**.

    library(simpow)
    set.seed(16) 
    lmm_f(nsim = 100,
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

Add more treatment groups by changing `ntrt` away from the default.

    set.seed(16) 
    lmm_f(nsim = 100,
          ntrt = 3,
          trtmeans = c(1, 3, 4),
          nblock = 10,
          sd_block = 2,
          sd_resid = 4)
    #> Power analysis based on 100 simulations
    #> 
    #> Estimated power with alpha = 0.05: 22%
    #> Total number replicates per treatment per block: 1 
    #> Number treatments: 3 
    #> Number blocks: 10 
    #> Total observations in each dataset: 30

The default power analysis has a single replicate per treatment per
block like you might have in many completely randomized block designs.
This can be changed. Here there are 5 replicates for every treatment in
every block for a total of 100 observations in each dataset.

    set.seed(16) 
    lmm_f(nsim = 100,
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
every treatment group via `sd_resid` or you will get an error.

These models tend to fit more slowly than models assuming constant
variance of the errors so run times will be longer.

    set.seed(16) 
    lmm_f(nsim = 100,
          ntrt = 2,
          trtmeans = c(1, 4),
          nblock = 10,
          nrep = 5,
          sd_block = 2,
          sd_resid = c(1, 4),
          sd_eq = FALSE)
    #> Power analysis based on 100 simulations
    #> 
    #> Estimated power with alpha = 0.05: 99%
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

    set.seed(16) 
    results = lmm_f(nsim = 2,
                    test = "none",
                    ntrt = 2,
                    trtmeans = c(1, 4),
                    nblock = 5,
                    sd_block = 2,
                    sd_resid = 4,
                    keep_data = TRUE)
    results$data
    #> [[1]]
    #>    trt blocks    response
    #> 1    A      1  0.07917862
    #> 2    B      1  0.92902441
    #> 3    A      2  1.00349072
    #> 4    B      2  7.84913040
    #> 5    A      3  5.48500047
    #> 6    B      3 13.58116080
    #> 7    A      4 -1.44072459
    #> 8    B      4 -1.87260735
    #> 9    A      5  9.92851323
    #> 10   B      5  9.18254086
    #> 
    #> [[2]]
    #>    trt blocks   response
    #> 1    A      1 -8.9173515
    #> 2    B      1 -0.5828568
    #> 3    A      2  1.4210928
    #> 4    B      2 11.0337330
    #> 5    A      3 -1.5180749
    #> 6    B      3 11.0553882
    #> 7    A      4  4.1312489
    #> 8    B      4  7.0348207
    #> 9    A      5  6.6160176
    #> 10   B      5  7.1232330

Similarly you can keep fitted models via `keep_models = TRUE` and
extracting via `models`. (Not shown.) Other values you can extract from
the returned object is the vector of p-values (`p.values`).

## Example varying parameters or design elements

You can use the `vary_element()` to run a power analysis for different
values of a parameter or study design element. This allows the user to
explore how best to set up their study or what effect they can
realistically expect to detect.

However, using this function means doing an entire simulation multiple
times and so ultimately this may be very slow. You may want to skip
doing extremely fine-scale changes.
