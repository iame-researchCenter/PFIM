# model equations
modelEquations = list(

  outcomes = list( "RespPK"),

  modelFromLibrary = list("PKModel" = "Linear1FirstOrderSingleDose_kaClV" )
)

# model parameters
modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1.6, omega = sqrt(0.7) ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 8, omega = sqrt(0.02) ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 0.13, omega = sqrt(0.06) ) )
)

# Error Model
errorModelRespPK1 = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
modelError = list( errorModelRespPK1 )

# Administration
administrationRespPK = Administration( outcome = "RespPK", timeDose = c( 0, 200, 400 ), dose = c( 20, 30, 50 ) )

# Sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0.5, 1, 2, 6, 9, 12, 24, 36, 48, 72, 96, 200, 400 ) )

# Arms
arm1 = Arm( name = "BrasTest1",
            size = 32,
            administrations = list( administrationRespPK ) ,
            samplingTimes = list( samplingTimesRespPK ),
            initialCondition = list( "RespPK" = 0) )

#arm2 = Arm( name = "BrasTest2",
#            size = 32,
#            administrations = list( administrationRespPK ) ,
#            samplingTimes = list( samplingTimesRespPK, samplingTimesRespPD ),
#            initialCondition = list( "C1" = 0, "C2" = 90 ) )

# Design
design1 = Design( name = "design1", arms = list( arm1 ) )
#design2 = Design( name = "design2", arms = list( arm1 ) )

# population Fim
evaluation = Evaluation( name = "PKPD_ODE_multi_doses_populationFIM",
                                   modelEquations = modelEquations,
                                   modelParameters = modelParameters,
                                   modelError = modelError,
                                   outcomes = list( "RespPK" ),
                                   designs = list( design1 ),
                                   fim = fimType,
                                   odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )

evaluationFIM = run( evaluation )

show( evaluationFIM )

# plots
plotOptions = list( unitTime=c("unit time"),
                    unitOutcomes = c("unit RespPK") )



plotOutcomesEvaluation = plotEvaluation( evaluationFIM, plotOptions )
plotSensitivityIndice = plotSensitivityIndice( evaluationFIM, plotOptions )

plotSE = plotSE( evaluationFIM, plotOptions )
plotRSE = plotRSE( evaluationFIM, plotOptions )

print( plotOutcomesEvaluation )
print( plotOutcomesGradient )
print( plotSE )
print( plotRSE )
