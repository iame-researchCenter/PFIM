# Model equations
modelEquations = list(
  
  outcomes = list( "RespPK" = "C1",
                   "RespPD" = "C2" ),
  
  equations = list(  "Deriv_C1" = "(dose_RespPK * ka * exp(-(ka * t)) - Cl * C1)/V",
                     "Deriv_C2" = "(Rin * (1 - (Imax*C1)/(C1 + C50)) - kout * C2)" )
)

# MyStatisticalModel = setParametersOdeSolver( MyStatisticalModel, list( .relStep=1e-8, atol=1e-8, rtol=1e-8 ) )

# model parameters
modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1.24, omega = sqrt(0.0) ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 12.2, omega = sqrt(0.25) ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 28.1, omega = sqrt(0.433) ) ),
  ModelParameter( name = "Rin", distribution = LogNormal( mu = 5.4, omega = sqrt(0.2) ) ),
  ModelParameter( name = "kout",distribution = LogNormal( mu = 0.06, omega = sqrt(0.02) ) ),
  ModelParameter( name = "C50",distribution = LogNormal( mu = 1.2, omega = sqrt(0.01) ) ),
  ModelParameter( name = "Imax", distribution = LogNormal( mu = 1.0, omega = sqrt(0.1) ) ) )

# error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
errorModelRespPD  = Constant( outcome = "RespPD", sigmaInter = 4 )
modelError = list( errorModelRespPK,  errorModelRespPD )



# arm
administrationRespPK = Administration( outcome = "RespPK", timeDose = c( 0 ), dose = c( 100 ) )

# sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0.5, 8, 20, 120 ) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD", samplings = c( 2, 12, 30, 115 ) )

# Constraints


# samplingConstraints
samplingConstraintsRespPK  = SamplingTimeConstraints( outcome = "RespPK",
                                                      initialSamplings = c( 0.5, 8, 20, 120 ),
                                                      samplingsWindows = list( c( 0,40),c(60,120) ),
                                                      numberOfTimesByWindows = c(2,2),
                                                      minSampling = 5 )

samplingConstraintsRespPD  = SamplingTimeConstraints( outcome = "RespPD",
                                                      initialSamplings = c( 2, 12, 30, 115 ),
                                                      samplingsWindows = list( c( 0,40),c(60, 120) ),
                                                      numberOfTimesByWindows = c(2,2),
                                                      minSampling = 5 )

# Create the arm with constraint
armTest = Arm( name = "Bras test",
               size = 200,
               administrations = list( administrationRespPK ),
               samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ),
               samplingTimesConstraints = list( samplingConstraintsRespPK, samplingConstraintsRespPD ),
               initialCondition = list( "C1" = 0, "C2" = 90 )
               )

design1 = Design( name = "design1", arms = list(armTest ) )


# --------------------------------------
# Optimization

# optimize the Fisher Information Matrix for the PopulationFIM
optimizationPopFIM = Optimization( name = "PKPD_ode",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   
                                   optimizer = "PGBOAlgorithm",
                                   
                                   optimizerParameters = list(
                                     N = 30,
                                     muteEffect = 0.25,
                                     maxIteration = 100,
                                     purgeIteration = 10,
                                     seed = 42,
                                     showProcess = TRUE  ),
                                   
                                   designs = list( design1 ),
                                   fim = "population",
                                   outcomes = list( "RespPK" = "C1","RespPD" = "C2" ) )

optimizationPopFIM = run( optimizationPopFIM )

# optimize the Fisher Information Matrix for the individualFIM
optimizationIndFIM = Optimization( name = "PKPD_ode",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   
                                   optimizer = "PGBOAlgorithm",
                                   
                                   optimizerParameters = list(
                                     N = 30,
                                     muteEffect = 0.25,
                                     maxIteration = 100,
                                     purgeIteration = 10,
                                     seed = 42,
                                     showProcess = TRUE  ),
                                   
                                   designs = list( design1 ),
                                   fim = "individual",
                                   outcomes = list( "RespPK" = "C1","RespPD" = "C2" ) )

optimizationIndFIM = run( optimizationIndFIM )

# optimize the Fisher Information Matrix for the bayesianFIM
optimizationBayeFIM  = Optimization( name = "PKPD_ode",
                                     modelEquations = modelEquations,
                                     modelParameters = modelParameters,
                                     modelError = modelError,
                                     
                                     optimizer = "PGBOAlgorithm",
                                     
                                     optimizerParameters = list(
                                       N = 30,
                                       muteEffect = 0.25,
                                       maxIteration = 100,
                                       purgeIteration = 10,
                                       seed = 42,
                                       showProcess = TRUE  ),
                                     
                                     designs = list( design1 ),
                                     fim = "Bayesian",
                                     outcomes = list( "RespPK" = "C1","RespPD" = "C2" ) )


optimizationBayeFIM = run( optimizationBayeFIM )


plotOptions = list( unitTime=c("unit time"),
                    unitResponses= c("unit RespPK") )

outputFile = paste0("Optimization_PGBO_PKPD_ode_populationFIM.html")
Report( optimizationPopFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("Optimization_PGBO_PKPD_ode_individualFIM.html")
Report( optimizationIndFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("Optimization_PGBO_PKPD_ode_bayesianFIM.html")
Report( optimizationBayeFIM, saveReportPath, outputFile, plotOptions )

