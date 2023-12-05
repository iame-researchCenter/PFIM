# Model equations
modelEquations = list(

  outcomes = list( "RespPK" ),

  equations = list( "RespPK" = "dose_RespPK / V * ka/(ka - k) * (exp(-k * t)/(1-exp(-k*tau)) - exp(-ka * t)/(1-exp(-ka*tau)))" ) )


modelParameters = list(
  ModelParameter( name = "V",
                  distribution = LogNormal( mu = 8, omega = sqrt(0.02) ),
                  fixedMu=TRUE ),
  ModelParameter( name = "k",
                  distribution = LogNormal( mu = 1.04, omega = sqrt(0.05) ) ),
  ModelParameter( name = "ka",
                  distribution = LogNormal( mu = 1.6, omega = sqrt(0.1) ) ) )


# Error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
modelError = list( errorModelRespPK )

# administration & multi-doses
administrationRespPK = Administration( outcome = "RespPK",
                                       dose = c(100),
                                       tau = c(48) )

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
                            fim = fimType )

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






