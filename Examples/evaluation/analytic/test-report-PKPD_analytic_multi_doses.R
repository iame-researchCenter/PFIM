# --------------------------------------
# model definition

# model equations
modelEquations = list(
  outcomes = list( "RespPK", "RespPD" ),
  modelFromLibrary = list("PKModel" = "Linear1FirstOrderSingleDose_kaClV",
                          "PDModel" = "ImmediateDrugImax_S0ImaxC50")
)

# model parameters
modelParameters = list(
  ModelParameter( name = "V",    distribution = LogNormal( mu = 8, omega = sqrt( 0.02 ) ) , fixedMu = TRUE ),
  ModelParameter( name = "Cl",   distribution = LogNormal( mu = 0.13, omega = sqrt( 0.06 ) ) ),
  ModelParameter( name = "S0",   distribution = LogNormal( mu = 100, omega = sqrt( 0.1 ) ) ),
  ModelParameter( name = "C50",  distribution = LogNormal( mu = 0.17, omega = sqrt( 0.7 ) ) ),
  ModelParameter( name = "ka",   distribution = LogNormal( mu = 1.6, omega = sqrt( 0.1 ) ) ),
  ModelParameter( name = "Imax", distribution = LogNormal( mu = 0.73, omega = sqrt( 0.3 ) ) )
)

# Error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
errorModelRespPD = Constant( outcome = "RespPD", sigmaInter = 2 )
modelError = list( errorModelRespPK, errorModelRespPD )

## administration
administrationRespPK = Administration( outcome = "RespPK", timeDose = c( 0,20,30,50 ), dose = c( 10,20,30,40 ) )

## sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c(  0, 2, 3, 8, 12, 24, 36, 50, 72, 120) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD", samplings = c( 0, 4, 8, 12, 24, 36, 72, 100, 120) )

## arms
arm1 = Arm( name = "BrasTest",
            size = 32,
            administrations = list( administrationRespPK ) ,
            samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ) )

# design
design1 = Design( name = "design1",
                  arms = list( arm1 ) )

# --------------------------------------
# Evaluation

# Evaluate the Fisher Information Matrix for the PopulationFIM
evaluationPopFIM = Evaluation( name = "PKPD_analytic_multi_doses_populationFIM",
                               modelEquations = modelEquations,
                               modelParameters = modelParameters,
                               modelError = modelError,
                               outcomes = list( "RespPK", "RespPD"),
                               designs = list( design1 ),
                               fim = "population",
                               odeSolverParameters = list( atol = 1e-10, rtol = 1e-10 ) )
evaluationPopFIM = run( evaluationPopFIM )

# Evaluate the Fisher Information Matrix for the individualFIM
evaluationIndFIM = Evaluation( name = "PKPD_analytic_multi_doses_individualFIM",
                               modelEquations = modelEquations,
                               modelParameters = modelParameters,
                               modelError = modelError,
                               outcomes = list( "RespPK", "RespPD"),
                               designs = list( design1 ),
                               fim = "individual",
                               odeSolverParameters = list( atol = 1e-10, rtol = 1e-10 ) )
evaluationIndFIM = run( evaluationIndFIM )

# Evaluate the Fisher Information Matrix for the bayesianFIM
evaluationBayeFIM = Evaluation( name = "PKPD_analytic_multi_doses_bayesianFIM",
                                modelEquations = modelEquations,
                                modelParameters = modelParameters,
                                modelError = modelError,
                                outcomes = list( "RespPK", "RespPD"),
                                designs = list( design1 ),
                                fim = "Bayesian",
                                odeSolverParameters = list( atol = 1e-10, rtol = 1e-10 ) )
evaluationBayeFIM = run( evaluationBayeFIM )

### Reports

plotOptions = list( unitTime=c("unit time"),
                    unitResponses= c("unit RespPK","unit RespPD" ) )

outputFile = paste0("PKPD_analytic_multi_doses_populationFIM.html")
Report( evaluationPopFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PKPD_analytic_multi_doses_individualFIM.html")
Report( evaluationIndFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PKPD_analytic_multi_doses_bayesianFIM.html")
Report( evaluationBayeFIM, saveReportPath, outputFile, plotOptions )

