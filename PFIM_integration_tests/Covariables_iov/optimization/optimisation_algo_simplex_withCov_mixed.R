library( PFIM )

modelEquations = list(
  RespPK = "dose_RespPK/V * ka/(ka - Cl/V) * (exp(-Cl/V * t) - exp(-ka * t))"
)
modelError = list( Constant( output = "RespPK", sigmaInter = 0.1 ) )
modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1,   omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 3.5, omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 0.5, omega = sqrt( 0.09 ) ), gamma = sqrt( 0.0225 ) )
)

sex = Covariate(
  name = "Sex", categories = c( "M", "F" ), categoriesProportions = c( 0.5, 0.5 ),
  effects = list( F = c( V = log( 1.2 ) ) )
)
treatment = Covariate(
  name = "Treatment", categories = c( "A", "B" ),
  sequences = list( c( "A", "B" ), c( "B", "A" ) ),
  sequencesProportions = c( 0.5, 0.5 ),
  effects = list( B = c( Cl = log( 1.1 ) ) )
)

samps = c( 0, 2, 3, 8, 12, 24, 36, 50, 72, 120 )
admin = Administration( outcome = "RespPK", timeDose = 0, dose = 30 )
sts   = SamplingTimes( outcome = "RespPK", samplings = samps )
stc   = SamplingTimeConstraints(
  outcome = "RespPK",
  initialSamplings = samps,
  samplingsWindows = list( c( 0, 24 ), c( 35, 130 ) ),
  numberOfTimesByWindows = c( 6, 4 ),
  minSampling = c( 1, 2 )
)
arm = Arm(
  name = "arm1", size = 100,
  administrations = list( admin ),
  samplingTimes   = list( sts ),
  samplingTimesConstraints = list( stc )
)
design = Design( name = "design1", arms = list( arm ) )

optimization = Optimization(
  name                    = "simplex_Sex_Treatment",
  modelEquations          = modelEquations,
  modelParameters         = modelParameters,
  modelCovariates         = list( sex, treatment ),
  modelCovariatesEquation = "exponential",
  numberOfOccasions       = 2,
  modelError              = modelError,
  optimizer               = "SimplexAlgorithm",
  optimizerParameters     = list(
    pctInitialSimplexBuilding = 20,
    maxIteration              = 200L,
    tolerance                 = 1e-6,
    showProcess               = TRUE
  ),
  designs                 = list( design ),
  fimType                 = "population",
  outputs                 = list( RespPK = "RespPK" )
)

result = run( optimization )
show( result )

outputPath  = file.path( getwd(), "results" )
dir.create( outputPath, recursive = TRUE, showWarnings = FALSE )
plotOptions = list( unitTime = "", unitOutcomes = "" )
stem        = "simplex_Sex_Treatment_population"
saveRDS( result, file.path( outputPath, paste0( stem, ".rds" ) ) )
Report( result, outputPath, paste0( stem, ".html" ), plotOptions )
