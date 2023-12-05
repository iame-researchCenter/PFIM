# Model equations
modelEquations = list(
  
  outcomes = list( "RespPK" = "C1",
                   "RespPD" = "C2" ),
  
  equations = list(  "Deriv_C1" = "(dose_RespPK * ka * exp(-(ka * t)) - Cl * C1)/V",
                     "Deriv_C2" = "(Rin * (1 - (Imax*C1)/(C1 + C50)) - kout * C2)" )
)


# model parameters
modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1.6, omega = sqrt(0.7) ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 8, omega = sqrt(0.02) ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 0.13, omega = sqrt(0.06) ) ),
  ModelParameter( name = "Rin", distribution = LogNormal( mu = 5.4, omega = sqrt(0.2) ), fixedMu = TRUE, fixedOmega = TRUE ),
  ModelParameter( name = "kout",distribution = LogNormal( mu = 0.06, omega = sqrt(0.02) ) ),
  ModelParameter( name = "C50",distribution = LogNormal( mu = 1.2, omega = sqrt(0.01) ) ),
  ModelParameter( name = "Imax", distribution = LogNormal( mu = 1.0, omega = sqrt(0.0) ), fixedMu = TRUE, fixedOmega = TRUE) )

# error Model
errorModelRespPK = Proportional( outcome = "RespPK", sigmaSlope = 0.2 )
errorModelRespPD  = Constant( outcome = "RespPD", sigmaInter = 0.1 )
modelError = list( errorModelRespPK,  errorModelRespPD )

# arm
administrationRespPK = Administration( outcome = "RespPK", timeDose = c( 0 ), dose = c( 100 ) )

## sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0.5, 2, 30 ) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD", samplings = c( 14, 110, 150 ) )


# constraints
administrationConstraintsResp1 = AdministrationConstraints( outcome = "RespPK", doses = c( 100 ) )

samplingConstraintsResp1  = SamplingTimeConstraints( outcome = "RespPK",
                                                     initialSamplings = c( 0.5 ,2 , 30, 49, 180 ),
                                                     numberOfsamplingsOptimisable = 3 )

samplingConstraintsResp2  = SamplingTimeConstraints( outcome = "RespPD",
                                                     initialSamplings = c( 0.5 ,2 ,14, 110 ),
                                                     numberOfsamplingsOptimisable = 3 )

arm1 = Arm( name = "BrasTest1",
            size = 100,
            administrations = list( administrationRespPK ),
            samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ),
            administrationsConstraints = list( administrationConstraintsResp1 ),
            samplingTimesConstraints = list( samplingConstraintsResp1, samplingConstraintsResp2 ),
            initialCondition = list( "C1" = 30, "C2" = 0 ) )

design1 = Design( name = "design1", arms = list( arm1 ), numberOfArms = 100 )


# --------------------------------------
# Optimization

# optimize the Fisher Information Matrix for the PopulationFIM
optimizationPopFIM2 = Optimization( name = "PKPD_ODEpopulationFIM",
                             modelEquations = modelEquations,
                             modelParameters = modelParameters,
                             modelError = modelError,
                             optimizer = "FedorovWynnAlgorithm",
                             optimizerParameters = list(elementaryProtocols = list( c( 0.5, 2, 30 ),
                                                                                     c( 2, 14, 110)),
                                                         numberOfSubjects = c(100),
                                                         proportionsOfSubjects = c(1),
                                                         showProcess = T ),
                             designs = list( design1 ),
                             fim = "population",
                             outcomes = list( "RespPK" = "C1","RespPD" = "C2" ),
                             odeSolverParameters = list( atol=1e-10, rtol=1e-10 ) )

optimizationPopFIM2 = run( optimizationPopFIM2 )

# optimize the Fisher Information Matrix for the individualFIM
optimizationIndFIM = Optimization( name = "PKPD_ODEpopulationFIM",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   optimizer = "FedorovWynnAlgorithm",
                                   optimizerParameters = list( elementaryProtocols = list( c( 0.5, 2, 30 ),
                                                                                           c( 2, 14, 110)),
                                                               numberOfSubjects = c(100),
                                                               proportionsOfSubjects = c(1),
                                                               showProcess = T ),
                                   designs = list( design1 ),
                                   fim = "individual",
                                   outcomes = list( "RespPK" = "C1","RespPD" = "C2" ),
                                   odeSolverParameters = list( atol=1e-10, rtol=1e-10 ) )

optimizationIndFIM = run( optimizationIndFIM )

# optimize the Fisher Information Matrix for the bayesianFIM
optimizationBayeFIM  = Optimization( name = "PKPD_ODEpopulationFIM",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   optimizer = "FedorovWynnAlgorithm",
                                   optimizerParameters = list( elementaryProtocols = list( c( 0.5, 2, 30 ),
                                                                                           c( 2, 14, 110)),
                                                               numberOfSubjects = c(100),
                                                               proportionsOfSubjects = c(1),
                                                               showProcess = T ),
                                   designs = list( design1 ),
                                   fim = "Bayesian",
                                   outcomes = list( "RespPK" = "C1","RespPD" = "C2" ),
                                   odeSolverParameters = list( atol=1e-10, rtol=1e-10 ) )

optimizationBayeFIM = run( optimizationBayeFIM )


plotOptions = list( unitTime=c("unit time"),
                    unitResponses= c("unit RespPK") )

outputFile = paste0("Optimization_FW_PKPD_ode_populationFIM.html")
Report( optimizationPopFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("Optimization_FW_PKPD_ode_individualFIM.html")
Report( optimizationIndFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("Optimization_FW_PKPD_ode_bayesianFIM.html")
Report( optimizationBayeFIM, saveReportPath, outputFile, plotOptions )
