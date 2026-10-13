# PFIM 8.0.1 — Integration tests

Official test suite for the [iame-researchCenter/PFIM](https://github.com/iame-researchCenter/PFIM) repository: **`PFIM_integration_tests/`**.

End-to-end validation for beta testers and release checks: FIM evaluation, design optimization, and covariates / inter-occasion variability (IOV).

**Workflow:** install PFIM from CRAN → `setwd()` to `PFIM_integration_tests/` → run `run_tests.R` → each script writes outputs under its local `results/` folder.

If a script fails, the error is logged and the run continues. A summary of **OK / failures** is printed at the end (console and log file).

### Requirements

| Component | Purpose |
|-----------|---------|
| **R ≥ 4.5** and **PFIM 8.0.1** (`install.packages("PFIM")`) | FIM and optimization |
| **Pandoc** (recommended) | HTML reports from `Report()` — bundled with RStudio or from [pandoc.org](https://pandoc.org/) |

Evaluation and optimization scripts call `Report()`. Without Pandoc, FIM computation may succeed while HTML generation fails.

---

## Running the test suite

From the root of your Git clone:

```text
PFIM/
└── PFIM_integration_tests/    ← run from here
    └── run_tests.R
```

### Terminal (PowerShell, bash, cmd)

```bash
cd PFIM_integration_tests
Rscript run_tests.R
Rscript run_tests.R --sections=cov,evaluation,optimisation
```

### R / RStudio (console)

The `Rscript ... --sections=` flag is not available in the RStudio console. Use `source()` and optionally `PFIM_TEST_SECTIONS`:

```r
setwd("path/to/PFIM/PFIM_integration_tests")

# Full campaign (64 runs)
source("run_tests.R")

# Covariates / IOV only (5)
Sys.setenv(PFIM_TEST_SECTIONS = "cov")
source("run_tests.R")

# Evaluation only (51)
Sys.setenv(PFIM_TEST_SECTIONS = "evaluation")
source("run_tests.R")

# Evaluation + optimization (59)
Sys.setenv(PFIM_TEST_SECTIONS = "evaluation,optimisation")
source("run_tests.R")

# Reset to full campaign
Sys.unsetenv("PFIM_TEST_SECTIONS")
source("run_tests.R")
```

Each run creates a timestamped log in this folder:

```text
run_tests_YYYYMMDD_HHMMSS.log
```

The log mirrors the full console output, including the final summary.

---

## Three sections

| Section | Content | Count |
|---------|---------|------:|
| `cov` | Covariates / IOV (evaluation + optimization) | 5 |
| `evaluation` | All `.R` files under `Evaluation/` | 51 |
| `optimisation` | All `.R` files under `Optimisation/` | 8 |
| **Total** | | **64** |

Execution order: **cov → evaluation → optimisation** (only the sections you request are run).

Allowed section names: `cov`, `evaluation`, `optimisation`.

---

## Section details

### `cov` — Covariates / IOV (5 scripts)

| Script | Output |
|--------|--------|
| `Covariables_iov/evaluation/script_tests_cov_and_iov_and_tests_tost_equi_noequiv.R` (10 cases) | `Covariables_iov/evaluation/results/` |
| `Covariables_iov/optimization/optimisation_algo_mult_withCov_mixed.R` | `Covariables_iov/optimization/results/` |
| `Covariables_iov/optimization/optimisation_algo_simplex_withCov_mixed.R` | same |
| `Covariables_iov/optimization/optimisation_algo_simplex_withCov_withIOV.R` | same |
| `Covariables_iov/optimization/optimisation_algo_simplex_withCovOccasion.R` | same |

### `evaluation` — FIM evaluation (51 scripts)

All `.R` files under `Evaluation/` (recursive discovery, excluding `results/`). Each script writes to `./results/` next to the script.

### `optimisation` — Design optimization (8 scripts)

Under `Optimisation/continuous/` (Simplex, PSO, PGBO) and `Optimisation/discrete/` (Fedorov–Wynn, multiplicative algorithm).

---

## Directory layout

```text
PFIM_integration_tests/
├── run_tests.R
├── README.md
├── README.html
├── run_tests_YYYYMMDD_HHMMSS.log          (generated)
│
├── Covariables_iov/
│   ├── evaluation/
│   │   ├── script_tests_cov_and_iov_and_tests_tost_equi_noequiv.R
│   │   └── results/
│   └── optimization/
│       ├── optimisation_algo_*.R
│       └── results/
│
├── Evaluation/
│   ├── features/
│   │   ├── modelErrorModifCode/
│   │   └── model_ode_pkpd_one_sampling_time/
│   ├── library_of_models/
│   │   ├── pk_analytic/
│   │   ├── pk_analytic_infusion/
│   │   ├── pk_analytic_infusion_pd_analytic/
│   │   ├── pk_analytic_infusion_pd_ode/
│   │   ├── pk_analytic_infusion_steady_state/
│   │   ├── pk_analytic_pd_analytic/
│   │   ├── pk_analytic_pd_ode/
│   │   ├── pk_analytic_steady_state/
│   │   └── pk_analytic_steady_state_pd_analytic/
│   └── user_defined_model/
│       ├── model_analytic/
│       ├── model_analytic_infusion/
│       ├── model_analytic_steady_state/
│       ├── model_ode_bolus/
│       ├── model_ode_dose_in_equations/
│       ├── model_ode_dose_not_in_equations/
│       └── model_ode_infusion_dose_in_equations/
│       (each scenario: one or more .R scripts + results/)
│
└── Optimisation/
    ├── continuous/
    │   ├── PGBO/
    │   ├── PSO/
    │   └── Simplex/
    └── discrete/
        ├── FedorovWynn/
        └── MultiplicativeAlgorithm/
        (each algorithm: test_*.R + results/)
```

> Do not rename `Evaluation/`, `Optimisation/`, or `Covariables_iov/`, and do not move `run_tests.R` — relative paths depend on this layout.

---

## Running a single script

```r
library(PFIM)
setwd("path/to/PFIM/PFIM_integration_tests/Evaluation/user_defined_model/model_analytic")
source("model_analytic_pk_md.R")
```

Outputs are written to `./results/` beside the script.

---

## HTML documentation

A formatted version of this guide is available as [`README.html`](README.html).
