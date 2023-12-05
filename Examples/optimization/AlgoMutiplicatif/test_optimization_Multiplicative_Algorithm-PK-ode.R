# Model equations
modelEquations = list(
  outcomes = list( "RespPK" = "C1" ),
  equations = list( "Deriv_C1" = "-k*C1") )

# model parameters
modelParameters = list(
  ModelParameter( name = "k", distribution = LogNormal( mu = 0.082, omega = sqrt(0.25) ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 8, omega = sqrt(0.02) ) ) )

# error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
modelError = list( errorModelRespPK )

# arm
administrationRespPK = Administration( outcome = "C1", timeDose = c( 0), dose = c( 100 ) )

## sampling times
samplingTimesRespPK = SamplingTimes( outcome = "C1", samplings = c( 0.5, 1, 24, 36, 120  ) )




# constraints
administrationConstraintsRespPK = AdministrationConstraints( outcome = "C1", doses = c( 100 ) )

samplingConstraintsRespPK  = SamplingTimeConstraints( outcome = "C1",
                                                      initialSamplings = c( 0.5, 1, 2, 6, 9, 12, 24, 36, 48, 72, 96, 120 ),
                                                      numberOfsamplingsOptimisable = 5
                                                      # fixedTimes = c( 0.5, 96, 72 ) 
                                                      )


arm1 = Arm( name = "BrasTest1",
            size = 100,
            administrations = list( administrationRespPK ),
            samplingTimes   = list( samplingTimesRespPK ),
            administrationsConstraints = list( administrationConstraintsRespPK ),
            samplingTimesConstraints = list( samplingConstraintsRespPK ),
            initialCondition = list( "C1" = "dose/V" ) )

design1 = Design( name = "design1", arms = list( arm1 ), numberOfArms = 100 )

evaluationFIM = Evaluation( name = "",
                            modelEquations = modelEquations,
                            modelParameters = modelParameters,
                            modelError = modelError,
                            outcomes = list( "RespPK"  = "C1" ),
                            designs = list( design1 ),
                            fim = "population",
                            odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )
evaluationFIM = run(evaluationFIM)
getRSE(evaluationFIM@designs[[1]]@fim, evaluationFIM@model)


# --------------------------------------
# Optimization

# optimize the Fisher Information Matrix for the PopulationFIM
optimizationPopFIM = Optimization( name = "PK_ode_populationFIM",
                             modelEquations = modelEquations,
                             modelParameters = modelParameters,
                             modelError = modelError,
                             optimizer = "MultiplicativeAlgorithm",
                             optimizerParameters = list( lambda = 0.99,
                                                         numberOfIterations = 1000,
                                                         delta = 1e-04, showProcess = T ),
                             designs = list( design1 ),
                             fim = "population",
                             outcomes = list( "RespPK" = "C1" ),
                             odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )
optimizationPopFIM = run( optimizationPopFIM )

# optimize the Fisher Information Matrix for the individualFIM
optimizationIndFIM = Optimization( name = "PK_ode_individualFIM",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   optimizer = "MultiplicativeAlgorithm",
                                   optimizerParameters = list( lambda = 0.99,
                                                               numberOfIterations = 1000,
                                                               delta = 1e-04, showProcess = T ),
                                   designs = list( design1 ),
                                   fim = "individual",
                                   outcomes = list( "RespPK" = "C1" ),
                                   odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )
optimizationIndFIM = run( optimizationIndFIM )

# optimize the Fisher Information Matrix for the bayesianFIM
optimizationBayeFIM = Optimization( name = "PK_ode_bayesianFIM",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   optimizer = "MultiplicativeAlgorithm",
                                   optimizerParameters = list( lambda = 0.99,
                                                               numberOfIterations = 1000,
                                                               delta = 1e-04, showProcess = T ),
                                   designs = list( design1 ),
                                   fim = "Bayesian",
                                   outcomes = list( "RespPK" = "C1" ),
                                   odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )
optimizationBayeFIM = run( optimizationBayeFIM )

### Reports

plotOptions = list( unitTime=c("unit time"),
                    unitResponses= c("unit RespPK","unit RespPD" ),
                    threshold = 0.01  )

outputFile = paste0("PK_ode_populationFIM_evaluation.html")
Report( evaluationFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PK_ode_populationFIM.html")
Report( optimizationPopFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PK_ode_individualFIM.html")
Report( optimizationIndFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PK_ode_bayesianFIM.html")
Report( optimizationBayeFIM, saveReportPath, outputFile, plotOptions )


