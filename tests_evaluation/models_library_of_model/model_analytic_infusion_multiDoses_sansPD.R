# --------------------------------------
# model equations
# --------------------------------------

# model equations
modelEquations = list(

  outcomes = list( "RespPK"),
  modelFromLibrary = list("PKModel" = "Linear1InfusionSingleDose_ClV"
                          ) )

# --------------------------------------
# model parameters
# --------------------------------------

modelParameters = list(
  ModelParameter( name = "V",    distribution = LogNormal( mu = 3.5, omega = 0.09 ) ),
  ModelParameter( name = "Cl",   distribution = LogNormal( mu = 2,   omega = 0.09 ) )
  )

# --------------------------------------
# error model
# --------------------------------------

errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.1, sigmaSlope = 0.1 )

modelError = list( errorModelRespPK )

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

## arms
arm1 = Arm( name = "BrasTest",
            size = 40,
            administrations = list( administrationRespPK ) ,
            samplingTimes   = list( samplingTimesRespPK ) )

# --------------------------------------
# Design
# --------------------------------------

design1 = Design( name = "design1",
                  arms = list( arm1 ) )

# --------------------------------------
# Evaluation
# --------------------------------------

evaluationFIM = Evaluation( name = "PKPD_ODE_multi_doses_populationFIM",
                            modelEquations = modelEquations,
                            modelParameters = modelParameters,
                            modelError = modelError,
                            outcomes = list( "RespPK" ),
                            designs = list( design1 ),
                            fim = fimType,
                            odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )


evaluationFIM = run( evaluationFIM )

show( evaluationFIM )

# plots
plotOptions = list( unitTime=c("unit time"),
                    unitOutcomes = c("unit RespPK","unit RespPD" ) )

plotEvaluationPopulation = plot( evaluationFIM, plotOptions )

plotOutcomesEvaluation = plotEvaluationPopulation$plotOutcomesEvaluation
plotOutcomesGradient = plotEvaluationPopulation$plotOutcomesGradient

plotSE = plotSE( evaluationFIM, plotOptions )
plotRSE = plotRSE( evaluationFIM, plotOptions )

print( plotOutcomesEvaluation )
print( plotOutcomesGradient )
print( plotSE )
print( plotRSE )





