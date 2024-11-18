# Model equations
modelEquations = list(
  
  outcomes = list( "RespPK" ),
  
  equations = list(  "RespPK" = "dose_RespPK/V * ka/(ka - k) * (exp(-k * t) - exp(-ka * t))" )
)

# model parameters
modelParameters = list(
  ModelParameter( name = "V",    distribution = LogNormal( mu = 15, omega = sqrt( 0.1 ) ) ),
  ModelParameter( name = "k",   distribution = LogNormal( mu = 0.25, omega = sqrt( 0.25 ) ) ),
  ModelParameter( name = "ka",   distribution = LogNormal( mu = 2.0, omega = sqrt( 0.0 ) ), fixedMu = TRUE )
)


# error model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.5, sigmaSlope = 0.15 )
modelError = list( errorModelRespPK )


# arm
administrationRespPK = Administration( outcome = "RespPK", timeDose = c( 0 ), dose = c( 100 ) )

# sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0.5, 3, 8, 12 ) )


#sampling constraint 
samplingConstraintsRespPK  = SamplingTimeConstraints( outcome = "RespPK",
                                                      initialSamplings = c( 0.5, 3, 8, 12 ),
                                                      samplingsWindows = list(  c(0,4), c(5,12) ),
                                                      numberOfTimesByWindows = c(2,2),
                                                      minSampling = 1.5 
                                                      )

arm1 = Arm( name = "Bras Test",
            size = 200,
            administrations = list( administrationRespPK ),
            samplingTimes   = list( samplingTimesRespPK ),
            samplingTimesConstraints = list( samplingConstraintsRespPK ) )


design1 = Design( name = "design1", arms = list( arm1 ))

# optimize the Fisher Information Matrix for the PopulationFIM
optimizationPopFIM = Optimization( name = "PK_analytic_fixedParameters_populationFIM",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   optimizer = "SimplexAlgorithm",
                                   optimizerParameters = list( pctInitialSimplexBuilding = 20,
                                                               maxIteration = 5000,
                                                               tolerance = 1e-6,
                                                               showProcess = TRUE  ),
                                   designs = list( design1 ),
                                   fim = "population",
                                   outcomes = list( "RespPK" ) )

optimizationPopFIM = run( optimizationPopFIM )

# optimize the Fisher Information Matrix for the individualFIM
optimizationIndFIM = Optimization( name = "PK_analytic_fixedParameters_individualFIM",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   optimizer = "SimplexAlgorithm",
                                   optimizerParameters = list( pctInitialSimplexBuilding = 20,
                                                               maxIteration = 5000,
                                                               tolerance = 1e-6,
                                                               showProcess = TRUE  ),
                                   designs = list( design1 ),
                                   fim = "individual",
                                   outcomes = list( "RespPK" ) )


optimizationIndFIM = run( optimizationIndFIM )

# optimize the Fisher Information Matrix for the bayesianFIM
optimizationBayeFIM  = Optimization( name = "PK_analytic_fixedParameters_bayesianFIM",
                                     modelEquations = modelEquations,
                                     modelParameters = modelParameters,
                                     modelError = modelError,
                                     optimizer = "SimplexAlgorithm",
                                     optimizerParameters = list( pctInitialSimplexBuilding = 20,
                                                                 maxIteration = 5000,
                                                                 tolerance = 1e-6,
                                                                 showProcess = TRUE  ),
                                     designs = list( design1 ),
                                     fim = "Bayesian",
                                     outcomes = list( "RespPK" ) )


optimizationBayeFIM = run( optimizationBayeFIM )


plotOptions = list( unitTime=c("unit time"),
                    unitResponses= c("unit RespPK") )

outputFile = paste0("Optimization_Simplex_PK_analytic_fixedParameters_populationFIM.html")
Report( optimizationPopFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("Optimization_Simplex_PK_analytic_fixedParameters_individualFIM.html")
Report( optimizationIndFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("Optimization_Simplex_PK_analytic_fixedParameters_bayesianFIM.html")
Report( optimizationBayeFIM, saveReportPath, outputFile, plotOptions )

