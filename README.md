
<!-- README.md is generated from README.Rmd. Please edit that file -->

# simpow: Simulation-based power analysis

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of this package is to provide helper functions for simple power
analyses based on linear and linear mixed models (LM’s and LMM’s).
Support may be added for generalized linear mixed models (GLMM’s) in the
future

## Installation

And the development version from [GitHub](https://github.com/) with:

You can install the **simpow** from GitHub:

    devtools::install_github("aosmith16/simpow")

## Simulated power analysis for basic LMM

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

## Simulated power for two-factor LM

When using very few blocks it is not uncommon to treat the blocking
variable as fixed instead of random. Instead of a basic LMM we’d want a
two-factor linear model (LM) with no interaction. You can fit such a
model in **simpow** using the `lm_2f()` function.

The main difference from `lmm_f()` is that you provide the true
treatment-block means instead of a block standard deviation.

    set.seed(16)
    lm_2f(nsim = 10,
          allmeans = c(30, 40, 45, 55, 45, 55),
          ntrt = 2,
          nblock = 3,
          sd_resid = 4)
    #> Power analysis based on 10 simulations
    #> 
    #> Estimated power with alpha = 0.05: 40%
    #> Total number replicates per treatment per block: 1 
    #> Number treatments: 2 
    #> Number blocks: 3 
    #> Total observations in each dataset: 6

You can provide vectors for the treatment means and block means
separately instead of providing the combined means. However, the overall
means between the two vectors must be the same and it may be simpler to
provide `allmeans` as above.

    set.seed(16)
    lm_2f(nsim = 10,
          ntrt = 2,
          trtmeans = c(40, 50),
          nblock = 3,
          blockmeans = c(35, 50, 50),
          sd_resid = 4)
    #> Power analysis based on 10 simulations
    #> 
    #> Estimated power with alpha = 0.05: 40%
    #> Total number replicates per treatment per block: 1 
    #> Number treatments: 2 
    #> Number blocks: 3 
    #> Total observations in each dataset: 6

## Power when varying parameters or design elements

You can use the `vary_element()` to run a power analysis for different
values of a parameter or study design element. This allows the user to
explore how best to set up their study or what effect they can
realistically expect to detect. Note only 1 element may be varied at a
time.

However, using this function means doing an entire simulation multiple
times and so ultimately this may be very slow when using 1000
simulations in each analysis. For this reason you may want to skip doing
extremely fine-scale changes.

Here’s an example of allowing for more blocks, holding all other
arguments constant for the power analysis. I unrealistically do only 10
simulations to save running time.

    set.seed(16)
    vary_element(simfun = "lmm_f",
                 tovary = "nblock",
                 values = c(5, 15),
                 nsim = 100,
                 trtmeans = c(1, 2),
                 sd_block = 2,
                 sd_resid = 4)
    #>   ntrt nblock nrep total_samp sd_block sd_resid alpha power
    #> 1    2      5    1         10        2        4  0.05     4
    #> 2    2     15    1         30        2        4  0.05     7

Change the `simfun` to explore a different simulation function. For
`lm_2f()` for limited-block-number designs this will probably be most
useful for varying the number of replicates per treatment per block or
residual standard deviation.

    set.seed(16)
    vary_element(simfun = "lm_2f",
                 tovary = "nrep",
                 values = c(1, 10),
                 nsim = 100,
                 allmeans = c(30, 40, 45, 55, 45, 55),
                 sd_resid = 4)
    #>   ntrt nblock nrep total_samp sd_resid alpha power
    #> 1    2      3    1          6        4  0.05    45
    #> 2    2      3   10         60        4  0.05   100

Note that in the `lm_wf()` case above, trying to vary the block number
would add a complexity `var_element()` can’t handle because you would
also need to provide different block means. This is not currently
possible.
