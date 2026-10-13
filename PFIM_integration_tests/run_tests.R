# PFIM 8.0.1 — Run the full integration test suite (single entry point).
# Documentation: README.md (PFIM_integration_tests/).
#
# Requires: PFIM installed; Pandoc recommended for Report() HTML output.
#
# Terminal (from PFIM_integration_tests/) :
#   Rscript run_tests.R
#   Rscript run_tests.R --sections=cov,evaluation,optimisation
#
# R / RStudio (console) :
#   setwd(".../PFIM_integration_tests")
#   source("run_tests.R")
#   Sys.setenv(PFIM_TEST_SECTIONS = "cov") ; source("run_tests.R")
#
# On failure: error is logged and the run continues.
# Summary of OK / failures at the end.

.all_sections = c( "cov", "evaluation", "optimisation" )

.parse_sections = function( x ) {
  if ( !length( x ) || !nzchar( x[[ 1L ]] ) )
    return( .all_sections )
  parts = unlist( strsplit( paste( x, collapse = "," ), ",", fixed = TRUE ), use.names = FALSE )
  tolower( trimws( parts ) )
}

args = commandArgs( trailingOnly = TRUE )
sec_arg = grep( "^--sections=", args, value = TRUE )
env_sec = Sys.getenv( "PFIM_TEST_SECTIONS", unset = "" )

sections = if ( length( sec_arg ) ) {
  .parse_sections( sub( "^--sections=", "", sec_arg[[ 1L ]] ) )
} else if ( nzchar( env_sec ) ) {
  .parse_sections( env_sec )
} else {
  .all_sections
}

unknown = setdiff( sections, .all_sections )
if ( length( unknown ) )
  stop(
    "Unknown section(s): ", paste( unknown, collapse = ", " ),
    ". Allowed: ", paste( .all_sections, collapse = ", " ),
    call. = FALSE
  )

.pfimTestsRoot = function() {
  wd = normalizePath( getwd(), winslash = "/", mustWork = FALSE )
  if ( file.exists( file.path( wd, "run_tests.R" ) ) )
    return( wd )
  f = grep( "^--file=", commandArgs( trailingOnly = FALSE ), value = TRUE )
  if ( length( f ) ) {
    script = sub( "^--file=", "", f[[ 1L ]] )
    if ( basename( script ) == "run_tests.R" )
      return( dirname( normalizePath( script, winslash = "/", mustWork = TRUE ) ) )
  }
  for ( i in rev( seq_along( sys.frames() ) ) ) {
    ofile = sys.frame( i )$ofile
    if ( !is.null( ofile ) && nzchar( ofile ) && basename( ofile ) == "run_tests.R" )
      return( dirname( normalizePath( ofile, winslash = "/", mustWork = TRUE ) ) )
  }
  wd
}

tests_root = .pfimTestsRoot()
log_file = file.path(
  tests_root,
  paste0( "run_tests_", format( Sys.time(), "%Y%m%d_%H%M%S" ), ".log" )
)

log_con = file( log_file, open = "wt", encoding = "UTF-8" )
sink( log_con, type = "output", split = TRUE )
sink( log_con, type = "message", append = TRUE )
on.exit({
  sink( type = "message" )
  sink( type = "output" )
  close( log_con )
}, add = TRUE )

if ( !requireNamespace( "PFIM", quietly = TRUE ) )
  stop( "Install the PFIM package before running run_tests.R.", call. = FALSE )
library( PFIM )
cat( "Package : PFIM", as.character( packageVersion( "PFIM" ) ), "\n" )
cat( "Library :", find.package( "PFIM" ), "\n" )

.rel_from_root = function( path, root ) {
  path = normalizePath( path, winslash = "/", mustWork = FALSE )
  root = normalizePath( root, winslash = "/", mustWork = FALSE )
  sub( paste0( "^", gsub( "([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", root ), "/?" ), "", path )
}

.r_scripts = function( base, pattern = "\\.R$" ) {
  hits = list.files( base, pattern = pattern, recursive = TRUE, full.names = TRUE )
  hits = hits[ !grepl( "[\\\\/]results[\\\\/]", hits ) ]
  hits = hits[ basename( hits ) != "run_tests.R" ]
  sort( hits )
}

test_plan = list()

if ( "cov" %in% sections ) {
  test_plan = c( test_plan, list(
    list(
      bloc = "cov",
      kind = "r",
      rel  = "Covariables_iov/evaluation/script_tests_cov_and_iov_and_tests_tost_equi_noequiv.R"
    ),
    list( bloc = "cov", kind = "r", rel = "Covariables_iov/optimization/optimisation_algo_mult_withCov_mixed.R" ),
    list( bloc = "cov", kind = "r", rel = "Covariables_iov/optimization/optimisation_algo_simplex_withCov_mixed.R" ),
    list( bloc = "cov", kind = "r", rel = "Covariables_iov/optimization/optimisation_algo_simplex_withCov_withIOV.R" ),
    list( bloc = "cov", kind = "r", rel = "Covariables_iov/optimization/optimisation_algo_simplex_withCovOccasion.R" )
  ) )
}

if ( "evaluation" %in% sections ) {
  for ( abs in .r_scripts( file.path( tests_root, "Evaluation" ) ) ) {
    test_plan[[ length( test_plan ) + 1L ]] = list(
      bloc = "evaluation",
      kind = "r",
      rel  = .rel_from_root( abs, tests_root )
    )
  }
}

if ( "optimisation" %in% sections ) {
  for ( abs in .r_scripts( file.path( tests_root, "Optimisation" ) ) ) {
    test_plan[[ length( test_plan ) + 1L ]] = list(
      bloc = "optimisation",
      kind = "r",
      rel  = .rel_from_root( abs, tests_root )
    )
  }
}

cat( "PFIM integration tests\n" )
cat( "Root :", tests_root, "\n" )
cat( "Log :", log_file, "\n" )
cat( "Sections :", paste( sections, collapse = ", " ), "\n" )
cat( "Total :", length( test_plan ), "executions\n\n" )

results = list()
ok = 0L
err = 0L

for ( spec in test_plan ) {
  path = file.path( tests_root, spec$rel )
  if ( !file.exists( path ) ) {
    cat( "=== MISSING :", spec$rel, "===\n" )
    results[[ length( results ) + 1L ]] = data.frame(
      script = spec$rel, bloc = spec$bloc, status = "MISSING", message = "file not found",
      stringsAsFactors = FALSE
    )
    err = err + 1L
    next
  }

  cat( "===", spec$rel, "===\n" )
  status = tryCatch({
    old = getwd()
    on.exit( setwd( old ), add = TRUE )
    setwd( dirname( path ) )
    source( basename( path ), local = new.env( parent = globalenv() ) )
    list( status = "OK", message = "" )
  }, error = function( e ) {
    msg = conditionMessage( e )
    cat( "ERROR:", msg, "\n" )
    list( status = "ERROR", message = msg )
  })

  results[[ length( results ) + 1L ]] = data.frame(
    script  = spec$rel,
    bloc    = spec$bloc,
    status  = status$status,
    message = status$message,
    stringsAsFactors = FALSE
  )
  if ( status$status == "OK" ) ok = ok + 1L else err = err + 1L
  cat( "\n" )
}

cat( strrep( "=", 60 ), "\n" )
cat( "SUMMARY :", ok, "OK |", err, "failure(s)\n" )
if ( err > 0L ) {
  tab = do.call( rbind, results )
  fails = tab[ tab$status != "OK", , drop = FALSE ]
  if ( nrow( fails ) ) {
    cat( "\nFailures :\n" )
    print( fails, row.names = FALSE )
  }
}
cat( strrep( "=", 60 ), "\n" )

invisible( list( ok = ok, err = err, results = do.call( rbind, results ) ) )
