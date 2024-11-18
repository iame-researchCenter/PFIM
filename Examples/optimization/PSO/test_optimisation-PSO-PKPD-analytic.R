# Model equations
modelEquations = list(
  
  outcomes = list( "RespPK", "RespPD" ),
  
  equations = list(  "RespPK" = "dose_RespPK / V * ka/(ka - (Cl/V)) * (exp(-(Cl/V) * t) - exp(-ka * t))",
                     "RespPD" = "S0 * ( 1 - 0.73 * RespPK / ( RespPK + S0 ) )" ) 
)

# model parameters
modelParameters = list(
  ModelParameter( name = "V",    distribution = Normal( mu = 8, omega = sqrt( 0.020 ) ) ),
  ModelParameter( name = "Cl",   distribution = Normal( mu = 0.13, omega = sqrt( 0.06 ) ) ),
  ModelParameter( name = "S0",   distribution = Normal( mu = 100, omega = sqrt( 0.1 ) ) ),
  ModelParameter( name = "ka",  distribution = Normal( mu = 1.6, omega =  sqrt( 0.7 ) ) ) 
)

# error model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
errorModelRespPD = Constant( outcome = "RespPD", sigmaInter = 8 )
modelError = list( errorModelRespPK, errorModelRespPD )


# arm
administrationRespPK = Administration( outcome = "RespPK", timeDose = c( 0 ), dose = c( 100 ) )

initalSamplingPK = c( 0.5, 8, 20, 115 )
initalSamplingPD = c( 2, 12, 30, 118 )

# sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = initalSamplingPK )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD", samplings = initalSamplingPD )


# Constraints


# samplingConstraints
samplingConstraintsRespPK  = SamplingTimeConstraints( outcome = "RespPK",
                                                      initialSamplings = initalSamplingPK,
                                                      samplingsWindows = list( c( 0,40),c(60,120) ),
                                                      numberOfTimesByWindows = c(2,2),
                                                      minSampling = 5 )

samplingConstraintsRespPD  = SamplingTimeConstraints( outcome = "RespPD",
                                                      initialSamplings = initalSamplingPD,
                                                      samplingsWindows = list( c( 0,40),c(60, 120) ),
                                                      numberOfTimesByWindows = c(2,2),
                                                      minSampling = 5 )

# Create the arm with constraint
armTest = Arm( name = "Bras test",
               size = 200,
               administrations = list( administrationRespPK ),
               samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ),
               samplingTimesConstraints = list( samplingConstraintsRespPK, samplingConstraintsRespPD ) )


design1 = Design( name = "design1", arms = list(armTest ) )


# --------------------------------------
# Optimization

# optimize the Fisher Information Matrix for the PopulationFIM
optimizationPopFIM = Optimization( name = "PKPD_analytic",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   
                                   optimizer = "PSOAlgorithm",

                                   optimizerParameters = list(
                                     maxIteration = 50,
                                     populationSize = 10,
                                     personalLearningCoefficient = 2.05,
                                     globalLearningCoefficient = 2.05,
                                     showProcess = T  ),
                                   
                                   
                                   designs = list( design1 ),
                                   fim = "population",
                                   outcomes = list( "RespPK","RespPD" ) )

optimizationPopFIM = run( optimizationPopFIM )

# optimize the Fisher Information Matrix for the individualFIM
optimizationIndFIM = Optimization( name = "PKPD_analytic",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   
                                   optimizer = "PSOAlgorithm",
                                   
                                   optimizerParameters = list(
                                     maxIteration = 50,
                                     populationSize = 10,
                                     personalLearningCoefficient = 2.05,
                                     globalLearningCoefficient = 2.05,
                                     showProcess = T  ),
                                   
                                   designs = list( design1 ),
                                   fim = "individual",
                                   outcomes = list( "RespPK","RespPD" ) )

optimizationIndFIM = run( optimizationIndFIM )

# optimize the Fisher Information Matrix for the bayesianFIM
optimizationBayeFIM  = Optimization( name = "PKPD_analytic",
                                     modelEquations = modelEquations,
                                     modelParameters = modelParameters,
                                     modelError = modelError,
                                     
                                     optimizer = "PSOAlgorithm",
                                     
                                     optimizerParameters = list(
                                       maxIteration = 50,
                                       populationSize = 10,
                                       personalLearningCoefficient = 2.05,
                                       globalLearningCoefficient = 2.05,
                                       showProcess = T  ),
                                     
                                     designs = list( design1 ),
                                     fim = "Bayesian",
                                     outcomes = list( "RespPK","RespPD" ) )


optimizationBayeFIM = run( optimizationBayeFIM )


plotOptions = list( unitTime=c("unit time"),
                    unitResponses= c("unit RespPK") )

outputFile = paste0("Optimization_PSO_PKPD_analytic_populationFIM.html")
Report( optimizationPopFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("Optimization_PSO_PKPD_analytic_individualFIM.html")
Report( optimizationIndFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("Optimization_PSO_PKPD_analytic_bayesianFIM.html")
Report( optimizationBayeFIM, saveReportPath, outputFile, plotOptions )

