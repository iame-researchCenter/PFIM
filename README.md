[![CRAN version](https://www.r-pkg.org/badges/version/PFIM)](https://cran.r-project.org/package=PFIM)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/PFIM)](https://cran.r-project.org/package=PFIM)
[![License: GPL-3](https://img.shields.io/badge/license-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)

# PFIM <img src="Logo_PFIM.png" align="right" width="120" alt="PFIM logo" />

**Population Fisher Information Matrix — design evaluation and optimization for nonlinear mixed-effects models in R**

PFIM evaluates the expected precision of parameter estimates and optimizes experimental designs using the Fisher information matrix (FIM). It is intended primarily for population pharmacokinetic and pharmacodynamic (PK/PD) studies, but also supports other nonlinear mixed-effects models specified through analytical equations or ordinary differential equations (ODEs).

**PFIM 8** introduces a complete rewrite based on the **S7 object system**, with compiled **C++ (Rcpp/Armadillo)** kernels for Fisher information calculations and optimization. It supports population, individual and Bayesian FIMs, categorical covariates, inter-occasion variability (IOV), five design optimization algorithms and covariate-effect tests. The public interface centres on `Evaluation()`, `Optimization()`, `run()`, `Report()` and dedicated `get*()`/`plot*()` accessors.

**Version 8.0.1** is a maintenance update addressing macOS/CRAN compatibility and packaging checks; the redesigned architecture and scientific features were introduced in PFIM 8.0. See [NEWS.md](NEWS.md) for release details.

## Features of PFIM 8

### A redesigned architecture

The R interface uses S7 classes to describe models, parameters, administrations, sampling schedules, study arms, designs, FIMs and optimization algorithms. Evaluation and optimization share a common object-based workflow; internal computational steps are separated from the public API. The codebase combines modular R functions with compiled numerical routines and provides registration mechanisms for extending model, FIM and optimizer types.

### FIM evaluation and uncertainty

- **Population, individual and Bayesian FIMs**, with access to information matrices, D-criteria, standard errors (SE), relative standard errors (RSE), correlations and relevant diagnostic plots.
- **Analytical and ODE models**, including user-defined equations and a library of PK, PD and PK/PD models. Model states can be transformed into observed responses using `outputs`; residual error is defined on the observed scale.
- **Residual error models**: `Constant`, `Proportional`, `Combined1` and `Combined2`, with residual parameters expressed on the standard-deviation scale.
- **Categorical covariates**, including between-subject categories and within-subject occasion sequences, with additive or exponential parameterizations of covariate effects.
- **Inter-occasion variability (IOV)** on selected model parameters, alongside inter-individual variability, with occasion-aware FIM calculations.
- **Covariate effect assessment** through `covariateTest()` (also available as `tost()`), including significance, equivalence/non-relevance and clinical-relevance assessments, as well as power and sample-size calculations for the supported population-FIM setting.

**Interpretation of individual and Bayesian FIMs.** When results are combined across arms or covariate strata, PFIM uses a weighted mixture of within-stratum covariance matrices, rather than the inverse of a sum of stratum information matrices. These results should not be assumed numerically interchangeable with PFIM 6 or PopED for such designs; see [NEWS.md](NEWS.md) for details.

### Five design optimizers

| Algorithm | Search space | Purpose |
|---|---|---|
| Multiplicative | Discrete | Optimize weights assigned to candidate protocols |
| Fedorov–Wynn | Discrete | Search a finite set of candidate designs/protocols |
| Simplex | Continuous | Derivative-free optimization of sampling times |
| Particle swarm optimization (PSO) | Continuous | Population-based search over sampling times |
| Population genetics-based optimization (PGBO) | Continuous | Population-based search over sampling times |

Discrete optimization supports candidate sampling-time and administration grids, as well as designs with multiple arms. Subject allocations are converted to integer counts by the largest-remainder (Hamilton) method, preserving the total study size. Continuous optimization supports sampling windows and constraints on the number and spacing of samples.

### Computational implementation

FIM assembly, residual-variance calculations and optimization routines use compiled C++ kernels. The implementation also caches reusable FIM calculations, ODE solutions and finite-difference gradients; continuous optimizers reuse an evaluation context during a search. These measures target repeated computations in design evaluation and optimization. **No general speedup factor is claimed**: runtime depends on the model, candidate designs, solver settings and hardware.

## Installation

Install the version currently published on CRAN:

```r
install.packages("PFIM")
library(PFIM)
packageVersion("PFIM")
```

PFIM 8 requires **R 4.5.0 or later**. Building from source requires a **C++17** toolchain. The CRAN version badge reports the release currently available from CRAN and may not yet match the version in this repository while an update is being processed.

## Getting started

Use the package vignettes for worked evaluations and optimizations:

```r
vignette("Vignette_01_discrete_design")
vignette("Vignette_02_continuous_design")
vignette("Vignette_03_covariates_analytical_pk")
vignette("Vignette_04_tim_waterhouse_pediatric")
vignette("Vignette_05_gcse_pkpd")
vignette("LibraryOfModels")
```

| Tutorial | Content |
|---|---|
| `Vignette_01_discrete_design` | Population-FIM evaluation and discrete optimization with Fedorov–Wynn and multiplicative algorithms |
| `Vignette_02_continuous_design` | Continuous sampling-time optimization using Simplex, PSO and PGBO within sampling windows |
| `Vignette_03_covariates_analytical_pk` | Analytical PK models with categorical covariates, IOV, covariate-effect tests and design optimization |
| `Vignette_04_tim_waterhouse_pediatric` | Sparse pediatric PK design, based on a Tim Waterhouse/PopED example |
| `Vignette_05_gcse_pkpd` | Filgrastim (G-CSF) PK/PD ODE example and comparison with PopED Design 1 |
| `LibraryOfModels` | Available PK/PD model families, parameterizations and examples |

The typical workflow constructs a model and study design, creates an `Evaluation()` or `Optimization()` object, executes `run()`, and inspects the result with accessors or `Report()`. Start with the vignettes for complete, model-specific code rather than treating these constructors as interchangeable across model classes.

`Report()` generates HTML reports for evaluations and optimizations. See `?run`, `?Report`, `?covariateTest`, `?definePKModel`, `?definePKPDModel` and `?pfim_set_option` for the interface and configuration options.

## Source code and documentation

| Location | Contents |
|---|---|
| `R/` | S7 classes, exported functions, model evaluation, covariates, reporting and R-side optimization logic |
| `src/` | Rcpp/Armadillo numerical and optimization kernels |
| `man/` | R reference documentation |
| `vignettes/` | Worked scientific examples and model-library guide |
| `tests/testthat/` | Unit and regression tests for FIM computations, models, covariates and optimizers |
| `inst/` | Package resources, including prebuilt vignette materials and example data where applicable |
| `PFIM_integration_tests/` | Repository-level end-to-end evaluation, optimization and covariate/IOV checks (when included in the repository) |

The documented `tests/testthat/` suite includes FIM regression checks and comparisons with reference examples. If the separate integration-test directory is distributed with the repository, its [`README.md`](PFIM_integration_tests/README.md) describes the end-to-end checks. Automated tests complement, but do not replace, independent verification for a particular model and design.

The release notes in [NEWS.md](NEWS.md) document the PFIM 8 redesign, numerical corrections, covariate/IOV support, optimization methods and the 8.0.1 compatibility adjustments. In particular, the numerical treatment of individual and Bayesian FIMs across strata differs from certain earlier implementations.

## Selected methodological references

- Mentré F, Mallet A, Baccar D (1997). [DOI: 10.1093/biomet/84.2.429](https://doi.org/10.1093/biomet/84.2.429).
- Retout S, Comets E, Samson A, Mentré F (2007). [DOI: 10.1002/sim.2910](https://doi.org/10.1002/sim.2910).
- Bazzoli C, Retout S, Mentré F (2009). [DOI: 10.1002/sim.3573](https://doi.org/10.1002/sim.3573).
- Combes FP, Retout S, Frey N, Mentré F (2013). [DOI: 10.1007/s11095-013-1079-3](https://doi.org/10.1007/s11095-013-1079-3).
- Seurat J, Tang Y, Mentré F, Nguyen TT (2021). [DOI: 10.1016/j.cmpb.2021.106126](https://doi.org/10.1016/j.cmpb.2021.106126).

## How to cite PFIM

To cite the PFIM software, use the reference provided by
the installed package:

```r
citation("PFIM")
```

## Project and contributors

PFIM is an open-source R package distributed under the **GPL-3 license** and developed within the [IAME research environment](https://github.com/iame-researchCenter). The package, documentation and examples are available through the [PFIM GitHub repository](https://github.com/iame-researchCenter/PFIM) and the [project website](https://www.pfim.biostat.fr/).

**PFIM 8** represents a complete redevelopment of the software, building on the methodological foundations and scientific contributions of earlier PFIM versions while introducing a new software architecture and numerical implementation.

### Contributors

- **Romain Leroux** (`aut`) — Sole author and developer of the entire PFIM 8 codebase, including the R/S7 architecture, C++ numerical implementation, optimization algorithms, automated tests and technical documentation.
- **France Mentré** (`cre`) — Package maintainer.
- **Jérémy Seurat** (`ctb`) — Contributions to the package vignettes.
- **Antoine Croxo** (`ctb`) — Contribution to one package vignette and beta testing.
- **Lucie Fayette** (`ctb`) — Contribution to one package vignette, beta testing and logo design.

### Support and feedback

Bug reports can be submitted through [GitHub Issues](https://github.com/iame-researchCenter/PFIM/issues). Please include a minimal reproducible example, the output of `packageVersion("PFIM")` and `R.version.string`, and any relevant error messages or diagnostic information.

For general questions, suggestions and discussions about PFIM, please use [GitHub Discussions](https://github.com/iame-researchCenter/PFIM/discussions).
