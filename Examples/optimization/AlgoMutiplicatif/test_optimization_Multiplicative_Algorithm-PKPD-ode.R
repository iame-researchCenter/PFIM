# Model equations
modelEquations = list(
  
  outcomes = list( "RespPK" = "C1",
                   "RespPD" = "C2" ),
  
  equations = list(  "Deriv_C1" = "(dose_RespPK * ka * exp(-(ka * t)) - Cl * C1)/V",
                     "Deriv_C2" = "(Rin * (1 - (Imax*C1)/(C1 + C50)) - kout * C2)" ) )

# model parameters
modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1.24, omega = sqrt(0.0) ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 12.2, omega = sqrt(0.25) ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 28.1, omega = sqrt(0.4333) ) ),
  ModelParameter( name = "Rin", distribution = LogNormal( mu = 5.4, omega = sqrt(0.2) ) ),
  ModelParameter( name = "kout",distribution = LogNormal( mu = 0.06, omega = sqrt(0.02) ) ),
  ModelParameter( name = "C50",distribution = LogNormal( mu = 1.2, omega = sqrt(0.01) ) ),
  ModelParameter( name = "Imax",distribution = LogNormal( mu = 1.0, omega = sqrt(0.1) ) ) )

# error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
errorModelRespPD  = Constant( outcome = "RespPD", sigmaInter = 4 )
modelError = list( errorModelRespPK,  errorModelRespPD )


# arm
administrationRespPK = Administration( outcome = "RespPK", timeDose = c( 0), dose = c( 100 ) )

## sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0.5, 1, 2, 6, 9, 12, 24, 36, 48, 72, 96, 120 ) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD", samplings = c( 0, 24, 36, 48, 72, 96, 120 ) )

# constraints
administrationConstraintsRespPK = AdministrationConstraints( outcome = "RespPK", doses = c( 100 ) )

samplingConstraintsRespPK  = SamplingTimeConstraints( outcome = "RespPK",
                                                      initialSamplings = c( 0.5, 1, 2, 6, 9, 12, 24, 36, 48, 72, 96, 120 ),
                                                      numberOfsamplingsOptimisable = 5,
                                                      fixedTimes = c(0.5, 1, 9, 96 ) )

samplingConstraintsRespPD = SamplingTimeConstraints( outcome = "RespPD",
                                                     initialSamplings = c( 0, 24, 36, 48, 72, 96, 120 ),
                                                     numberOfsamplingsOptimisable = 5,
                                                     fixedTimes = c( 0, 24, 72, 120 ) )

# number of fims
## dim(combn(12-4,5-4))[2] * dim(combn(7-4,5-4))[2]

arm1 = Arm( name = "BrasTest1",
            size = 100,
            administrations = list( administrationRespPK ),
            samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ),
            administrationsConstraints = list( administrationConstraintsRespPK ),
            samplingTimesConstraints = list( samplingConstraintsRespPK, samplingConstraintsRespPD ),
            initialCondition = list( "C1" = 0, "C2" = 90) )

design1 = Design( name = "design1", arms = list( arm1 ), numberOfArms = 100 )

# --------------------------------------
# Optimization

# optimize the Fisher Information Matrix for the PopulationFIM
optimizationPopFIM = Optimization( name = "PKPD_ode_populationFIM",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   optimizer = "MultiplicativeAlgorithm",
                                   optimizerParameters = list( lambda = 0.99,
                                                               numberOfIterations = 10,
                                                               delta = 1e-04, showProcess = T ),
                                   designs = list( design1 ),
                                   fim = "population",
                                   outcomes = list( "RespPK" = "C1","RespPD" = "C2" ),
                                   odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )
optimizationPopFIM = run( optimizationPopFIM )

# optimize the Fisher Information Matrix for the individualFIM
optimizationIndFIM = Optimization( name = "PKPD_ode_individualFIM",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   optimizer = "MultiplicativeAlgorithm",
                                   optimizerParameters = list( lambda = 0.99,
                                                               numberOfIterations = 1000,
                                                               delta = 1e-04, showProcess = T ),
                                   designs = list( design1 ),
                                   fim = "individual",
                                   outcomes = list( "RespPK" = "C1","RespPD" = "C2" ),
                                   odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )
optimizationIndFIM = run( optimizationIndFIM )

# optimize the Fisher Information Matrix for the bayesianFIM
optimizationBayeFIM = Optimization( name = "PKPD_ode_bayesianFIM",
                                    modelEquations = modelEquations,
                                    modelParameters = modelParameters,
                                    modelError = modelError,
                                    optimizer = "MultiplicativeAlgorithm",
                                    optimizerParameters = list( lambda = 0.99,
                                                                numberOfIterations = 1000,
                                                                delta = 1e-04, showProcess = T ),
                                    designs = list( design1 ),
                                    fim = "Bayesian",
                                    outcomes = list( "RespPK" = "C1","RespPD" = "C2" ),
                                    odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )
optimizationBayeFIM = run( optimizationBayeFIM )

### Reports

plotOptions = list( unitTime=c("unit time"),
                    unitResponses= c("unit RespPK","unit RespPD" ),
                    threshold = 0.01  )

outputFile = paste0("PKPD_ode_populationFIM.html")
Report( optimizationPopFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PKPD_ode_individualFIM.html")
Report( optimizationIndFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PKPD_ode_bayesianFIM.html")
Report( optimizationBayeFIM, saveReportPath, outputFile, plotOptions )


