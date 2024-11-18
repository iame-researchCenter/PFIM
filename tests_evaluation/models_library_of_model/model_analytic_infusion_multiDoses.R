# --------------------------------------
# model equations
# --------------------------------------

# model equations
modelEquations = list(

  outcomes = list( "RespPK", "RespPD" ),
  modelFromLibrary = list("PKModel" = "Linear1InfusionSingleDose_ClV",
                          "PDModel" = "ImmediateDrugLinear_S0Alin") )

# --------------------------------------
# model parameters
# --------------------------------------

modelParameters = list(
  ModelParameter( name = "V",    distribution = LogNormal( mu = 3.5, omega = 0.09 ) ),
  ModelParameter( name = "Cl",   distribution = LogNormal( mu = 2,   omega = 0.09 ) ),
  ModelParameter( name = "Alin", distribution = LogNormal( mu = 10,  omega = 0.5 ) ),
  ModelParameter( name = "S0",   distribution = LogNormal( mu = 0.1,   omega = 0.0 ) ) )

# --------------------------------------
# error model
# --------------------------------------

errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.1, sigmaSlope = 0.1 )
errorModelRespPD = Constant(  outcome = "RespPD", sigmaInter = 0.8 )

modelError = list( errorModelRespPK, errorModelRespPD )

# --------------------------------------
# Arm
# --------------------------------------

## administration & multi-doses
administrationRespPK = Administration( outcome = "RespPK",
                                       Tinf = c(2,5,10),
                                       timeDose = c( 0,10,20 ),
                                       dose = c( 10,20,30 ) )
## sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK",
                                     samplings = c( 0, 1, 2, 5, 7, 8, 10, 12, 14, 15, 16, 20, 21, 30, 40, 50, 60, 70, 80, 100 ) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD",
                                     samplings = c( 0, 2, 10, 12, 14, 20, 30, 40, 50, 60, 70, 80, 100 ) )

## arms
arm1 = Arm( name = "BrasTest",
            size = 40,
            administrations = list( administrationRespPK ) ,
            samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ) )

# --------------------------------------
# Design
# --------------------------------------

design1 = Design( name = "design1",
                  arms = list( arm1 ) )

# --------------------------------------
# Evaluation
# --------------------------------------

evaluation = Evaluation( name = "PKPD_ODE_multi_doses_populationFIM",
                            modelEquations = modelEquations,
                            modelParameters = modelParameters,
                            modelError = modelError,
                            outcomes = list( "RespPK", "RespPD" ),
                            designs = list( design1 ),
                            fim = fimType,
                            odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )


evaluationFIM = run( evaluation )

# plots
plotOptions = list( unitTime=c("unit time"),
                    unitOutcomes = c("unit RespPK","unit RespPD" ) )

plotOutcomesEvaluation = plotEvaluation( evaluationFIM, plotOptions )
plotSensitivityIndice = plotSensitivityIndice( evaluationFIM, plotOptions )

plotSE = plotSE( evaluationFIM, plotOptions )
plotRSE = plotRSE( evaluationFIM, plotOptions )




