# model equations
modelEquations = list(

  outcomes = list( "RespPK", "RespPD" ),

  modelFromLibrary = list("PKModel" = "Linear1FirstOrderSingleDose_kaClV",
                          "PDModel" = "ImmediateDrugImax_S0ImaxC50") )

# model parameters
modelParameters = list(
  ModelParameter( name = "V",    distribution = LogNormal( mu = 8, omega = 0.02 ),  fixedMu=TRUE ),
  ModelParameter( name = "Cl",   distribution = LogNormal( mu = 0.13, omega = 0.06 ) ),
  ModelParameter( name = "S0",   distribution = LogNormal( mu = 100, omega = 0.1 ) ),
  ModelParameter( name = "C50",  distribution = LogNormal( mu = 0.17, omega = 0.7 ) ),
  ModelParameter( name = "ka",   distribution = LogNormal( mu = 1.6, omega = 0.1 ) ),
  ModelParameter( name = "Imax", distribution = LogNormal( mu = 0.73, omega = 0.3 ) ) )


# error model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
errorModelRespPD = Constant( outcome = "RespPD", sigmaInter = 2 )
modelError = list( errorModelRespPK, errorModelRespPD )

# administration
administrationRespPK = Administration( outcome = "RespPK", tau = c(6), dose = c( 50 ) )

## sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0, 2, 3, 8, 12, 24, 36, 50, 72, 120 ) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD", samplings = c( 0, 4, 8, 12, 24, 36, 72, 100, 120 ) )

## arms
arm1 = Arm( name = "BrasTest",
            size = 32,
            administrations = list( administrationRespPK ) ,
            samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ) )

# Design
design1 = Design( name = "design1", arms = list( arm1 ) )

# Evaluation
evaluation = Evaluation( name = "PKPD_analytic_multi_doses_populationFIM",
                            modelEquations = modelEquations,
                            modelParameters = modelParameters,
                            modelError = modelError,
                            outcomes = list( "RespPK", "RespPD" ),
                            designs = list( design1 ),
                            fim = fimType )

evaluationFIM = run( evaluation )

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











