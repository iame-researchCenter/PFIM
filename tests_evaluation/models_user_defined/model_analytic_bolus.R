# Model equations
modelEquations = list(

  outcomes = list( "RespPK" ),

  equations = list("RespPK" = "dose_RespPK/V * (exp(-k* t))" ) )


modelParameters = list(
  ModelParameter( name = "V",
                  distribution = LogNormal( mu = 8, omega = sqrt(0.02) ),
                  fixedMu=TRUE ),
  ModelParameter( name = "k",
                  distribution = LogNormal( mu = 1.04, omega = sqrt(0.05) ) ) )


# Error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
modelError = list( errorModelRespPK )

# administration & multi-doses
administrationRespPK = Administration( outcome = "RespPK", dose = c(100))

## sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK",
                                     samplings = c(0, 2, 3, 8, 12, 24, 36, 50, 72, 120) )

## arms
arm1 = Arm( name = "BrasTest",
            size = 32,
            administrations = list( administrationRespPK ) ,
            samplingTimes   = list( samplingTimesRespPK ) )

# Design
design1 = Design( name = "design1",
                  arms = list( arm1 ) )

# evaluation
evaluationFIM = Evaluation( name = "",
                            modelEquations = modelEquations,
                            modelParameters = modelParameters,
                            modelError = modelError,
                            outcomes = list( "RespPK"),
                            designs = list( design1  ),
                            fim = fimType,
                            odeSolverParameters = list( atol = 1e-10, rtol = 1e-10 ))

evaluationFIM = run( evaluationFIM )

# plots
plotOptions = list( unitTime = c("unit time"),
                    unitOutcomes = c("unit RespPK" ) )

plotOutcomesEvaluation = plotEvaluation( evaluationFIM, plotOptions )
plotSensitivityIndice = plotSensitivityIndice( evaluationFIM, plotOptions )

plotSE = plotSE( evaluationFIM, plotOptions )
plotRSE = plotRSE( evaluationFIM, plotOptions )

