# Model equations
modelEquations = list(

  outcomes = list( "RespPK" ),

  equations = list(  "RespPK" = "dose_RespPK / V * ka/(ka - k) * (exp(-k * t) - exp(-ka * t) ) " )
)

# model parameters
modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 2.0, omega = sqrt(0.0) ), fixedMu = TRUE ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 15, omega = sqrt(0.1) ) ),
  ModelParameter( name = "k", distribution = LogNormal( mu = 0.25, omega = sqrt(0.25) ) ) )

# error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.5, sigmaSlope = 0.15 )
modelError = list( errorModelRespPK )


# arm
administrationRespPK = Administration( outcome = "RespPK", timeDose = c( 0 ), dose = c( 100 ) )

## sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0.33, 1.5, 5, 12 ) )


# constraints
administrationConstraintsRespPK = AdministrationConstraints( outcome = "RespPK", doses = c( 100, 200 ) )

samplingConstraintsRespPK  = SamplingTimeConstraints( outcome = "RespPK",
                                                      initialSamplings = c( 0.33, 1, 1.5, 3, 5, 8, 12 ),
                                                      numberOfsamplingsOptimisable = 4 )

arm1 = Arm( name = "BrasTest1",
            size = 200,
            administrations = list( administrationRespPK ),
            samplingTimes   = list( samplingTimesRespPK  ),
            administrationsConstraints = list( administrationConstraintsRespPK ),
            samplingTimesConstraints = list( samplingConstraintsRespPK ) )

design1 = Design( name = "design1", arms = list( arm1 ), numberOfArms = 200 )


# --------------------------------------
# Optimization

# optimize the Fisher Information Matrix for the PopulationFIM
optimizationPopFIM = Optimization( name = "PK_analytic_populationFIM",
                             modelEquations = modelEquations,
                             modelParameters = modelParameters,
                             modelError = modelError,
                             optimizer = "FedorovWynnAlgorithm",
                             optimizerParameters = list( elementaryProtocols = list( c( 0.33, 1, 1.5, 3 ) ),
                                                         numberOfSubjects = c(200),
                                                         proportionsOfSubjects = c(1),
                                                         showProcess = T ),
                             designs = list( design1 ),
                             fim = "population",
                             outcomes = list( "RespPK" ) )

optimizationPopFIM = run( optimizationPopFIM )

# optimize the Fisher Information Matrix for the individualFIM
optimizationIndFIM = Optimization( name = "PK_analytic_individualFIM",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   optimizer = "FedorovWynnAlgorithm",
                                   optimizerParameters = list( elementaryProtocols= list( c( 0.33, 1, 1.5, 3 ) ),
                                                               numberOfSubjects = c(200),
                                                               proportionsOfSubjects = c(1),
                                                               showProcess = T ),
                                   designs = list( design1 ),
                                   fim = "individual",
                                   outcomes = list( "RespPK" ) )

optimizationIndFIM = run( optimizationIndFIM )

# optimize the Fisher Information Matrix for the bayesianFIM
optimizationBayeFIM  = Optimization( name = "PK_analytic_bayesianFIM",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   optimizer = "FedorovWynnAlgorithm",
                                   optimizerParameters = list( elementaryProtocols= list( c( 0.33, 1, 1.5, 3 ) ),
                                                               numberOfSubjects = c(200),
                                                               proportionsOfSubjects = c(1),
                                                               showProcess = T ),
                                   designs = list( design1 ),
                                   fim = "Bayesian",
                                   outcomes = list( "RespPK" ) )

optimizationBayeFIM = run( optimizationBayeFIM )

### Reports

plotOptions = list( unitTime=c("unit time"),
                    unitResponses= c("unit RespPK","unit RespPD" ) )

outputFile = paste0("Optimization_FedorovWynnAlgorithm_PK_analytic_populationFIM.html")
Report( optimizationPopFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("Optimization_FedorovWynnAlgorithm_PK_analytic_individualFIM.html")
Report( optimizationIndFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("Optimization_FedorovWynnAlgorithm_PK_analytic_bayesianFIM.html")
Report( optimizationBayeFIM, saveReportPath, outputFile, plotOptions )





