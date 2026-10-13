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

samps = c( 0.5, 2, 4, 6, 8 )
admin = Administration( outcome = "RespPK", timeDose = 0, dose = 30 )
sts   = SamplingTimes( outcome = "RespPK", samplings = samps )
stc   = SamplingTimeConstraints(
  outcome = "RespPK",
  initialSamplings = samps,
  numberOfsamplingsOptimisable = 3
)
adc = AdministrationConstraints( outcome = "RespPK", doses = list( 30 ) )
arm = Arm(
  name = "arm1", size = 40,
  administrations = list( admin ),
  samplingTimes   = list( sts ),
  administrationsConstraints = list( adc ),
  samplingTimesConstraints   = list( stc )
)
design = Design( name = "design1", arms = list( arm ) )

optimization = Optimization(
  name                    = "mult_Sex_Treatment",
  modelEquations          = modelEquations,
  modelParameters         = modelParameters,
  modelCovariates         = list( sex, treatment ),
  modelCovariatesEquation = "exponential",
  numberOfOccasions       = 2,
  modelError              = modelError,
  optimizer               = "MultiplicativeAlgorithm",
  optimizerParameters     = list(
    lambda             = 0.99,
    numberOfIterations = 1000L,
    weightThreshold    = 0.01,
    delta              = 1e-4,
    showProcess        = TRUE
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
stem        = "mult_Sex_Treatment_population"
saveRDS( result, file.path( outputPath, paste0( stem, ".rds" ) ) )
Report( result, outputPath, paste0( stem, ".html" ), plotOptions )
