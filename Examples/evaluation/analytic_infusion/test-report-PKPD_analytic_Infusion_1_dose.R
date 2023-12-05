# --------------------------------------
# model definition

# model equations
modelEquations = list(
  outcomes = list( "RespPK", "RespPD" ),
  modelFromLibrary = list("PKModel" = "Linear1InfusionSingleDose_ClV",
                          "PDModel" = "ImmediateDrugLinear_S0Alin")
)


# model parameters
modelParameters = list(
  ModelParameter( name = "V",    distribution = LogNormal( mu = 3.5, omega = sqrt( 0.09 ) ) ),
  ModelParameter( name = "Cl",   distribution = LogNormal( mu = 2, omega = sqrt( 0.09 ) ) ),
  ModelParameter( name = "S0",   distribution = Normal( mu = 0, omega = 0), fixedMu = TRUE ),
  ModelParameter( name = "Alin",   distribution = LogNormal( mu = 10, omega = sqrt( 0.5 ) ) )
)


# Error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.1, sigmaSlope = 0.1 )
errorModelRespPD = Constant( outcome = "RespPD", sigmaInter = 0.8 )
modelError = list( errorModelRespPK, errorModelRespPD )


## administration
administrationRespPK = Administration( outcome = "RespPK",
                                       Tinf=c( 2 ),
                                       timeDose = c( 0 ),
                                       dose = c( 30 )
)

## sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0, 1, 2, 5, 7,8, 10,12,14, 15, 16, 20, 21, 30 ) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD", samplings = c( 0, 2, 10, 12, 14, 20, 30 ) )

## arms
arm1 = Arm( name = "BrasTest",
            size = 40,
            administrations = list( administrationRespPK ) ,
            samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ) )

# design
design1 = Design( name = "design1",
                  arms = list( arm1 ) )

# --------------------------------------
# Evaluation

# Evaluate the Fisher Information Matrix for the PopulationFIM
evaluationPopFIM = Evaluation( name = "PKPD_analytic_infusion_1_dose_populationFIM",
                               modelEquations = modelEquations,
                               modelParameters = modelParameters,
                               modelError = modelError,
                               outcomes = list( "RespPK", "RespPD"),
                               designs = list( design1 ),
                               fim = "population",
                               odeSolverParameters = list( atol = 1e-10, rtol = 1e-10 ) )
evaluationPopFIM = run( evaluationPopFIM )

# Evaluate the Fisher Information Matrix for the individualFIM
evaluationIndFIM = Evaluation( name = "PKPD_analytic_infusion_1_dose_individualFIM",
                               modelEquations = modelEquations,
                               modelParameters = modelParameters,
                               modelError = modelError,
                               outcomes = list( "RespPK", "RespPD"),
                               designs = list( design1 ),
                               fim = "individual",
                               odeSolverParameters = list( atol = 1e-10, rtol = 1e-10 ) )
evaluationIndFIM = run( evaluationIndFIM )

# Evaluate the Fisher Information Matrix for the bayesianFIM
evaluationBayeFIM = Evaluation( name = "PKPD_analytic_infusion_1_dose_bayesianFIM",
                                modelEquations = modelEquations,
                                modelParameters = modelParameters,
                                modelError = modelError,
                                outcomes = list( "RespPK", "RespPD"),
                                designs = list( design1 ),
                                fim = "Bayesian",
                                odeSolverParameters = list( atol = 1e-10, rtol = 1e-10 ) )
evaluationBayeFIM = run( evaluationBayeFIM )

### Reports

# saveReportPath = "D:/RECHERCHES/_PFIM/PFIM/PFIM6/tests_PFIM6"

plotOptions = list( unitTime=c("unit time"),
                    unitResponses= c("unit RespPK","unit RespPD" ) )

outputFile = paste0("PKPD_analytic_infusion_1_dose_populationFIM.html")
Report( evaluationPopFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PKPD_analytic_infusion_1_dose_individualFIM.html")
Report( evaluationIndFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PKPD_analytic_infusion_1_dose_bayesianFIM.html")
Report( evaluationBayeFIM, saveReportPath, outputFile, plotOptions )

