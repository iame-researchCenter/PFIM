# ----------------------------------------------------------------------------
# Model ODE & multi-doses repeated tau
# ----------------------------------------------------------------------------

# Model equations
modelEquations = list(

  outcomes = list( "RespPK" = "C1" ),

  equations = list( duringInfusion = list( "Deriv_C1" = "dose_RespPK / ( V * Tinf_RespPK ) - k * C1" ) ,
                    afterInfusion  = list( "Deriv_C1" = "-k * C1" ) ) )

# model parameters
modelParameters = list(
  ModelParameter( name = "V", distribution = LogNormal( mu = 3.5, omega = 0.09 ) ),
  ModelParameter( name = "k", distribution = LogNormal( mu = 0.6, omega = 0.09 ) ) )

# Error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.1, sigmaSlope = 0.1 )
modelError = list( errorModelRespPK )

# administration
administrationRespPK = Administration( outcome = "RespPK", Tinf = c(2), tau = c(4), dose = c(100) )

# sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0.5, 1, 4, 8,15,19 ) )

# arms
arm1 = Arm( name = "BrasTest",
            size = 40,
            administrations = list( administrationRespPK ) ,
            samplingTimes = list( samplingTimesRespPK ),
            initialCondition = list( "C1" = 0) )

# Design
design1 = Design( name = "design1",
                  arms = list( arm1 ) )

# population Fim
evaluationFIM = Evaluation( name = "evaluation",
                            modelEquations = modelEquations,
                            modelParameters = modelParameters,
                            modelError = modelError,
                            outcomes = list( "RespPK" = "C1" ),
                            designs = list( design1 ),
                            odeSolverParameters = list( atol=1e-8, rtol=1e-8 ),
                            fim = fimType )

evaluationFIM = run( evaluationFIM )

show( evaluationFIM )

# plots
plotOptions = list( unitTime = c("unit time"),
                    unitOutcomes = c("unit RespPK1" ) )
plotOptions = list( unitTime = c("hour"),
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




