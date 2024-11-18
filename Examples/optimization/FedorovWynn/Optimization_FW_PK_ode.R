# Model equations
modelEquations = list(
  outcomes = list( "RespPK" = "C1" ),
  equations = list( "Deriv_C1" = "-k*C1") )

# model parameters
modelParameters = list(
  ModelParameter( name = "k", distribution = LogNormal( mu = 0.082, omega = sqrt(0.25) ) ))

# error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
modelError = list( errorModelRespPK )

# arm
administrationRespPK = Administration( outcome = "C1", timeDose = c( 0), dose = c( 100 ) )

## sampling times
samplingTimesRespPK = SamplingTimes( outcome = "C1", samplings = c( 0.5, 14, 30, 150  ) )



# constraints
administrationConstraintsRespPK = AdministrationConstraints( outcome = "C1", doses = c( 100 ) )

samplingConstraintsRespPK  = SamplingTimeConstraints( outcome = "C1",
                                                      initialSamplings = c( 0.5 ,2 ,14, 30, 110, 150 ),
                                                      numberOfsamplingsOptimisable = 4
                                                      )

arm1 = Arm( name = "BrasTest1",
            size = 100,
            administrations = list( administrationRespPK ),
            samplingTimes   = list( samplingTimesRespPK ),
            administrationsConstraints = list( administrationConstraintsRespPK ),
            samplingTimesConstraints = list( samplingConstraintsRespPK ),
            initialCondition = list( "C1" = "dose" ) )

design1 = Design( name = "design1", arms = list( arm1 ), numberOfArms = 100 )

# --------------------------------------
# Optimization

# optimize the Fisher Information Matrix for the PopulationFIM
optimizationPopFIM = Optimization( name = "PK_ode_populationFIM",
                             modelEquations = modelEquations,
                             modelParameters = modelParameters,
                             modelError = modelError,
                             optimizer = "FedorovWynnAlgorithm",
                             optimizerParameters = list( elementaryProtocols = list( c( 0.5, 14, 30, 150  ) ),
                                                         numberOfSubjects = c(100),
                                                         proportionsOfSubjects = c(1),
                                                         showProcess = T ),
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
                                   optimizer = "FedorovWynnAlgorithm",
                                   optimizerParameters = list( elementaryProtocols= list( c( 0.5, 14, 30, 150  ) ),
                                                               numberOfSubjects = c(100),
                                                               proportionsOfSubjects = c(1),
                                                               showProcess = T ),
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
                                   optimizer = "FedorovWynnAlgorithm",
                                   optimizerParameters = list( elementaryProtocols= list( c( 0.5, 14, 30, 150  ) ),
                                                               numberOfSubjects = c(100),
                                                               proportionsOfSubjects = c(1),
                                                               showProcess = T ),
                                   designs = list( design1 ),
                                   fim = "Bayesian",
                                   outcomes = list( "RespPK" = "C1" ),
                                   odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )

optimizationBayeFIM = run( optimizationBayeFIM )

# reports


plotOptions = list( unitTime=c("unit time"),
                    unitResponses= c("unit RespPK") )

outputFile = paste0("Optimization_FedorovWynnAlgorithm_PK_ode_populationFIM.html")
Report( optimizationPopFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("Optimization_FedorovWynnAlgorithm_PK_ode_individualFIM.html")
Report( optimizationIndFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("Optimization_FedorovWynnAlgorithm_PK_ode_bayesianFIM.html")
Report( optimizationBayeFIM, saveReportPath, outputFile, plotOptions )



