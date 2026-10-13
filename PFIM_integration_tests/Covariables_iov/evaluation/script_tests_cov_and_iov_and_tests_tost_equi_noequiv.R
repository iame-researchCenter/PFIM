# ======================================================================================================
# PFIM 8.0.1 — Population FIM evaluation tests (covariates / IOV)
# ======================================================================================================
# Ecrit les resultats dans ./results/ (lance depuis ce dossier ou via run_tests.R).
# ======================================================================================================

library( PFIM )

results_dir = function() {
  d = file.path( getwd(), "results" )
  if ( !dir.exists( d ) ) dir.create( d, recursive = TRUE )
  d
}

saveResult = function( evaluation, file_name ) {
  fisherMatrix = getFisherMatrix( evaluation )$fisherMatrix
  Dcrit        = as.numeric( getDcriterion( evaluation ) )
  SE           = getSE( evaluation )
  output_lines = c(
    "===============================================",
    "        PFIM7 - Population Fisher Matrix",
    "===============================================",
    "",
    "---- Fisher Information Matrix ----",
    capture.output( print( fisherMatrix ) ),
    "",
    "---- D-criterion ----",
    paste( "D-criterion:", Dcrit ),
    "",
    "---- Standard Errors (SE) ----",
    capture.output( print( SE ) ),
    "",
    "===============================================",
    "               END OF FILE",
    "==============================================="
  )
  outPath = results_dir()
  path    = file.path( outPath, file_name )
  writeLines( output_lines, path )
  cat( "Saved:", path, "\n" )
  stem        = sub( "\\.txt$", "", file_name )
  plotOptions = list( unitTime = "", unitOutcomes = "" )
  saveRDS( evaluation, file.path( outPath, paste0( stem, ".rds" ) ) )
  Report( evaluation, outPath, paste0( stem, ".html" ), plotOptions )
}

saveResultCovariateTest = function( tostResults, file_name ) {
  outPath = results_dir()
  saveCovariateTest( tostResults, fileName = basename( file_name ), folder = outPath )
  saveRDS( tostResults, file.path( outPath, sub( "\\.txt$", ".rds", file_name ) ) )
  cat( "Saved:", file.path( outPath, file_name ), "\n" )
}

# ======================================================================================================
# ELEMENTS COMMON TO ALL CASES
# ======================================================================================================

modelEquations = list(
  "RespPK" = "dose_RespPK/V * ka/(ka - Cl/V) * (exp(-Cl/V * t) - exp(-ka * t))"
)

modelError = list( Constant( output = "RespPK", sigmaInter = 0.1 ) )

administrationRespPK = Administration( outcome = "RespPK", timeDose = c( 0 ), dose = c( 30 ) )
samplingTimesRespPK  = SamplingTimes( outcome = "RespPK", samplings = c( 0.5, 2, 4, 6, 8 ) )
arm1 = Arm(
  name = "Bras1", size = 40,
  administrations = list( administrationRespPK ),
  samplingTimes   = list( samplingTimesRespPK )
)
design1 = Design( name = "design1", arms = list( arm1 ) )

# ============================================================================================
# CASE 1: No covariates, no IOV
# ============================================================================================

modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1,   omega = sqrt( 0.09 ) ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 3.5, omega = sqrt( 0.09 ) ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 2,   omega = sqrt( 0.09 ) ) )
)

evaluation = Evaluation(
  name = "cas1_noCov_noIOV", modelParameters = modelParameters,
  modelCovariates = list(), modelCovariatesEquation = "exponential",
  modelEquations = modelEquations, modelError = modelError,
  designs = list( design1 ), fimType = "population",
  outputs = list( "RespPK" = "RespPK" ),
  odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 )
)
evaluation = run( evaluation )
show( evaluation )
saveResult( evaluation, "cas1_noCov_noIOV.txt" )

# ============================================================================================
# CASE 2: No covariates, with IOV (gamma = sqrt(0.0225), 2 occasions)
# ============================================================================================

modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 3.5, omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 2,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) )
)

evaluation = Evaluation(
  name = "cas2_noCov_withIOV", modelParameters = modelParameters,
  modelCovariates = list(), modelCovariatesEquation = "exponential",
  modelEquations = modelEquations, modelError = modelError,
  designs = list( design1 ), fimType = "population",
  outputs = list( "RespPK" = "RespPK" ),
  odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 )
)
evaluation = run( evaluation )
show( evaluation )
saveResult( evaluation, "cas2_noCov_withIOV.txt" )

# ============================================================================================
# CASE 3: Fixed covariate Sex on V, no IOV
# ============================================================================================

modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1,   omega = sqrt( 0.09 ) ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 3.5, omega = sqrt( 0.09 ) ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 2,   omega = sqrt( 0.09 ) ) )
)

sex = Covariate(
  name = "Sex", categories = c( "M", "F" ), categoriesProportions = c( 0.5, 0.5 ),
  effects = list( "F" = c( "V" = log( 1.2 ) ) )
)

evaluation = Evaluation(
  name = "cas3_withCov_noIOV", modelParameters = modelParameters,
  modelCovariates = list( sex ), modelCovariatesEquation = "exponential",
  modelEquations = modelEquations, modelError = modelError,
  designs = list( design1 ), fimType = "population",
  outputs = list( "RespPK" = "RespPK" ),
  odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 )
)
evaluation = run( evaluation )
show( evaluation )
saveResult( evaluation, "cas3_withCov_noIOV.txt" )

resultsClinicalRelevance = covariateTest(
  evaluation,
  thetaL = log( 0.80 ), thetaU = log( 1.25 ),
  targetPower = 0.90, alpha = 0.05
)
show( resultsClinicalRelevance )
saveResultCovariateTest( resultsClinicalRelevance, "cas3_withCov_noIOV_resultsClinicalRelevance.txt" )

# ============================================================================================
# CASE 4: Fixed covariate Sex on V + IOV (2 occasions)
# ============================================================================================

modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 3.5, omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 2,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) )
)

sex = Covariate(
  name = "Sex", categories = c( "M", "F" ), categoriesProportions = c( 0.5, 0.5 ),
  effects = list( "F" = c( "V" = log( 1.2 ) ) )
)

evaluation = Evaluation(
  name = "cas4_withCov_withIOV", modelParameters = modelParameters,
  modelCovariates = list( sex ), modelCovariatesEquation = "exponential",
  modelEquations = modelEquations, modelError = modelError,
  designs = list( design1 ), fimType = "population",
  outputs = list( "RespPK" = "RespPK" ),
  odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 )
)
evaluation = run( evaluation )
show( evaluation )
saveResult( evaluation, "cas4_withCov_withIOV.txt" )

resultsClinicalRelevance = covariateTest(
  evaluation,
  thetaL = log( 0.80 ), thetaU = log( 1.25 ),
  targetPower = 0.90, alpha = 0.05
)
show( resultsClinicalRelevance )
saveResultCovariateTest( resultsClinicalRelevance, "cas4_withCov_withIOV_resultsClinicalRelevance.txt" )

# ============================================================================================
# CASE 5: Fixed covariate Sex on V + occasion covariate Treatment on Cl
# ============================================================================================

modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 3.5, omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 2,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) )
)

sex = Covariate(
  name = "Sex", categories = c( "M", "F" ), categoriesProportions = c( 0.5, 0.5 ),
  effects = list( "F" = c( "V" = log( 1.2 ) ) )
)

treatment = Covariate(
  name = "Treatment", categories = c( "A", "B" ),
  sequences = list( c( "A", "B" ), c( "B", "A" ) ),
  sequencesProportions = c( 0.5, 0.5 ),
  effects = list( "B" = c( "Cl" = log( 1.1 ) ) )
)

evaluation = Evaluation(
  name = "cas5_withCov_mixed", modelParameters = modelParameters,
  modelCovariates = list( sex, treatment ), modelCovariatesEquation = "exponential",
  modelEquations = modelEquations, modelError = modelError,
  designs = list( design1 ), fimType = "population",
  outputs = list( "RespPK" = "RespPK" ),
  odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 )
)
evaluation = run( evaluation )
show( evaluation )
saveResult( evaluation, "cas5_withCov_mixed.txt" )

resultsClinicalRelevance = covariateTest(
  evaluation,
  thetaL = log( 0.80 ), thetaU = log( 1.25 ),
  targetPower = 0.90, alpha = 0.05
)
show( resultsClinicalRelevance )
saveResultCovariateTest( resultsClinicalRelevance, "cas5_withCov_mixed_resultsClinicalRelevance.txt" )

# ============================================================================================
# CASE 6: Occasion covariate Treatment on Cl only (no fixed covariate)
# ============================================================================================

modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 3.5, omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 2,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) )
)

treatment = Covariate(
  name = "Treatment", categories = c( "A", "B" ),
  sequences = list( c( "A", "B" ), c( "B", "A" ) ),
  sequencesProportions = c( 0.5, 0.5 ),
  effects = list( "B" = c( "Cl" = log( 1.1 ) ) )
)

evaluation = Evaluation(
  name = "cas6_noCovFixed_withCovOccasion_withIOV", modelParameters = modelParameters,
  modelCovariates = list( treatment ), modelCovariatesEquation = "exponential",
  modelEquations = modelEquations, modelError = modelError,
  designs = list( design1 ), fimType = "population",
  outputs = list( "RespPK" = "RespPK" ),
  odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 )
)
evaluation = run( evaluation )
show( evaluation )
saveResult( evaluation, "cas6_noCovFixed_withCovOccasion_withIOV.txt" )

resultsClinicalRelevance = covariateTest(
  evaluation,
  thetaL = log( 0.80 ), thetaU = log( 1.25 ),
  targetPower = 0.90, alpha = 0.05
)
show( resultsClinicalRelevance )
saveResultCovariateTest( resultsClinicalRelevance, "cas6_noCovFixed_withCovOccasion_withIOV_resultsClinicalRelevance.txt" )

# ============================================================================================
# CASE 7: Occasion covariate Treatment on Cl — 3 occasions + IOV
# ============================================================================================

modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 3.5, omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 2,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) )
)

treatment3 = Covariate(
  name = "Treatment", categories = c( "A", "B" ),
  sequences = list( c( "A", "A", "B" ), c( "B", "A", "A" ) ),
  sequencesProportions = c( 0.5, 0.5 ),
  effects = list( "B" = c( "Cl" = log( 1.1 ) ) )
)

evaluation = Evaluation(
  name = "cas7_Treatment3occ_withIOV", modelParameters = modelParameters,
  modelCovariates = list( treatment3 ), modelCovariatesEquation = "exponential",
  modelEquations = modelEquations, modelError = modelError,
  designs = list( design1 ), fimType = "population",
  outputs = list( "RespPK" = "RespPK" ),
  odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 )
)
evaluation = run( evaluation )
show( evaluation )
saveResult( evaluation, "cas7_Treatment3occ_withIOV.txt" )

resultsClinicalRelevance = covariateTest(
  evaluation,
  thetaL = log( 0.80 ), thetaU = log( 1.25 ),
  targetPower = 0.90, alpha = 0.05
)
show( resultsClinicalRelevance )
saveResultCovariateTest( resultsClinicalRelevance, "cas7_Treatment3occ_withIOV_resultsClinicalRelevance.txt" )

# ============================================================================================
# CASE 8: Occasion covariate Treatment on Cl — 4 occasions + IOV
# ============================================================================================

modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 3.5, omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 2,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) )
)

treatment4 = Covariate(
  name = "Treatment", categories = c( "A", "B" ),
  sequences = list( c( "A", "B", "A", "B" ), c( "B", "A", "B", "A" ) ),
  sequencesProportions = c( 0.5, 0.5 ),
  effects = list( "B" = c( "Cl" = log( 1.1 ) ) )
)

evaluation = Evaluation(
  name = "cas8_Treatment4occ_withIOV", modelParameters = modelParameters,
  modelCovariates = list( treatment4 ), modelCovariatesEquation = "exponential",
  modelEquations = modelEquations, modelError = modelError,
  designs = list( design1 ), fimType = "population",
  outputs = list( "RespPK" = "RespPK" ),
  odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 )
)
evaluation = run( evaluation )
show( evaluation )
saveResult( evaluation, "cas8_Treatment4occ_withIOV.txt" )

resultsClinicalRelevance = covariateTest(
  evaluation,
  thetaL = log( 0.80 ), thetaU = log( 1.25 ),
  targetPower = 0.90, alpha = 0.05
)
show( resultsClinicalRelevance )
saveResultCovariateTest( resultsClinicalRelevance, "cas8_Treatment4occ_withIOV_resultsClinicalRelevance.txt" )

# ============================================================================================
# CASE 9: Sex (fixed) + Treatment 3 occasions + IOV
# ============================================================================================

modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 3.5, omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 2,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) )
)

sex = Covariate(
  name = "Sex", categories = c( "M", "F" ), categoriesProportions = c( 0.5, 0.5 ),
  effects = list( "F" = c( "V" = log( 1.2 ) ) )
)

treatment3 = Covariate(
  name = "Treatment", categories = c( "A", "B" ),
  sequences = list( c( "A", "A", "B" ), c( "B", "A", "A" ) ),
  sequencesProportions = c( 0.5, 0.5 ),
  effects = list( "B" = c( "Cl" = log( 1.1 ) ) )
)

evaluation = Evaluation(
  name = "cas9_Sex_Treatment3occ_withIOV", modelParameters = modelParameters,
  modelCovariates = list( sex, treatment3 ), modelCovariatesEquation = "exponential",
  modelEquations = modelEquations, modelError = modelError,
  designs = list( design1 ), fimType = "population",
  outputs = list( "RespPK" = "RespPK" ),
  odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 )
)
evaluation = run( evaluation )
show( evaluation )
saveResult( evaluation, "cas9_Sex_Treatment3occ_withIOV.txt" )

resultsClinicalRelevance = covariateTest(
  evaluation,
  thetaL = log( 0.80 ), thetaU = log( 1.25 ),
  targetPower = 0.90, alpha = 0.05
)
show( resultsClinicalRelevance )
saveResultCovariateTest( resultsClinicalRelevance, "cas9_Sex_Treatment3occ_withIOV_resultsClinicalRelevance.txt" )

# ============================================================================================
# CASE 10: Sex (fixed) + Treatment 4 occasions + IOV
# ============================================================================================

modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 3.5, omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 2,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) )
)

sex = Covariate(
  name = "Sex", categories = c( "M", "F" ), categoriesProportions = c( 0.5, 0.5 ),
  effects = list( "F" = c( "V" = log( 1.2 ) ) )
)

treatment4 = Covariate(
  name = "Treatment", categories = c( "A", "B" ),
  sequences = list( c( "A", "B", "A", "B" ), c( "B", "A", "B", "A" ) ),
  sequencesProportions = c( 0.5, 0.5 ),
  effects = list( "B" = c( "Cl" = log( 1.1 ) ) )
)

evaluation = Evaluation(
  name = "cas10_Sex_Treatment4occ_withIOV", modelParameters = modelParameters,
  modelCovariates = list( sex, treatment4 ), modelCovariatesEquation = "exponential",
  modelEquations = modelEquations, modelError = modelError,
  designs = list( design1 ), fimType = "population",
  outputs = list( "RespPK" = "RespPK" ),
  odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 )
)
evaluation = run( evaluation )
show( evaluation )
saveResult( evaluation, "cas10_Sex_Treatment4occ_withIOV.txt" )

resultsClinicalRelevance = covariateTest(
  evaluation,
  thetaL = log( 0.80 ), thetaU = log( 1.25 ),
  targetPower = 0.90, alpha = 0.05
)
show( resultsClinicalRelevance )
saveResultCovariateTest( resultsClinicalRelevance, "cas10_Sex_Treatment4occ_withIOV_resultsClinicalRelevance.txt" )
