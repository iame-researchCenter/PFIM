# --------------------------------------
# model definition

# model equations
modelEquations = list(
  
  outcomes = list( "RespPK" = "Cc",
                   "RespPD" = "E"),
  
  modelFromLibrary = list("PKModel" = "Linear1FirstOrderSingleDose_kaClV",
                          "PDModel" = "TurnoverRinFullImax_RinCC50koutE")
)

# model parameters
modelParameters = list(
  ModelParameter( name = "ka",    distribution = LogNormal( mu = 1.6, omega = sqrt( 0.7 ) ) ),
  ModelParameter( name = "V",   distribution = LogNormal( mu = 8, omega = sqrt( 0.02 ) ) ),
  ModelParameter( name = "Cl",   distribution = LogNormal( mu = 0.13, omega = sqrt( 0.06 ) ) ),
  ModelParameter( name = "Rin",   distribution = LogNormal( mu = 5.4, omega = sqrt( 0.2 ) ) ),
  ModelParameter( name = "kout",   distribution = LogNormal( mu = 0.06, omega = sqrt( 0.02 ) ) ),
  ModelParameter( name = "C50",   distribution = LogNormal( mu = 1.2, omega = sqrt( 0.01 ) ) )
)


# Error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
errorModelRespPD = Constant( outcome = "RespPD", sigmaInter = 0.4 )
modelError = list( errorModelRespPK, errorModelRespPD )


## administration
administrationRespPK = Administration( outcome = "RespPK",
                                       tau = c( 20 ),
                                       dose = c( 50 )
)

## sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK",
                                     samplings = c(0.5, 1, 2, 6, 9, 12, 24, 36, 48, 72, 96, 120) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD",
                                     samplings = c(0, 24, 36, 48, 72, 96, 120) )

## arms
arm1 = Arm( name = "BrasTest",
            size = 32,
            administrations = list( administrationRespPK ) ,
            samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ),
            initialCondition = list( "Cc" = 0 , "E" = 90)
)

# design
design1 = Design( name = "design1",
                  arms = list( arm1 ) )

# --------------------------------------
# Evaluation

# Evaluate the Fisher Information Matrix for the PopulationFIM
evaluationPopFIM = Evaluation( name = "PKPD_ODE_repetead_doses_populationFIM",
                               modelEquations = modelEquations,
                               modelParameters = modelParameters,
                               modelError = modelError,
                               outcomes = list( "RespPK" = "Cc", "RespPD" = "E"),
                               designs = list( design1 ),
                               fim = "population",
                               odeSolverParameters = list( atol = 1e-10, rtol = 1e-10  ) )
evaluationPopFIM = run( evaluationPopFIM )

# Evaluate the Fisher Information Matrix for the individualFIM
evaluationIndFIM = Evaluation( name = "PKPD_ODE_repetead_doses_individualFIM",
                               modelEquations = modelEquations,
                               modelParameters = modelParameters,
                               modelError = modelError,
                               outcomes = list( "RespPK" = "Cc", "RespPD" = "E"),
                               designs = list( design1 ),
                               fim = "individual",
                               odeSolverParameters = list( atol = 1e-10, rtol = 1e-10  ) )
evaluationIndFIM = run( evaluationIndFIM )

# Evaluate the Fisher Information Matrix for the bayesianFIM
evaluationBayeFIM = Evaluation( name = "PKPD_ODE_repetead_doses_bayesianFIM",
                                modelEquations = modelEquations,
                                modelParameters = modelParameters,
                                modelError = modelError,
                                outcomes = list( "RespPK" = "Cc", "RespPD" = "E"),
                                designs = list( design1 ),
                                fim = "Bayesian",
                                odeSolverParameters = list( atol = 1e-10, rtol = 1e-10  ) )
evaluationBayeFIM = run( evaluationBayeFIM )

### Reports

plotOptions = list( unitTime=c("unit time"),
                    unitResponses= c("unit RespPK","unit RespPD" ) )

outputFile = paste0("PKPD_ODE_repetead_doses_populationFIM.html")
Report( evaluationPopFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PKPD_ODE_repetead_doses_individualFIM.html")
Report( evaluationIndFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PKPD_ODE_repetead_doses_bayesianFIM.html")
Report( evaluationBayeFIM, saveReportPath, outputFile, plotOptions )
