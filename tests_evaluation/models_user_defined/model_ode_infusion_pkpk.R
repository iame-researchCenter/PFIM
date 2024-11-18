# model equations
modelEquations = list(

  outcomes = list( "RespPK1" = "C1", "RespPK2" = "C2"),

  equations = list( duringInfusion = list( "Deriv_C1" = "dose_RespPK1/(Tinf_RespPK1*V1) - (CL1/V1)*C1",
                                           "Deriv_C2" = "dose_RespPK2/(Tinf_RespPK2*V2) - (CL2/V2)*C2"),

                    afterInfusion  = list( "Deriv_C1" = "- (CL1/V1)*C1" ,
                                           "Deriv_C2" = "- (CL2/V2)*C2" ) ) )

# model parameters
modelParameters = list(

  ModelParameter( name = "V1",
                  distribution = LogNormal( mu = 8.0, omega = sqrt( 0.02 ) ) ),
  ModelParameter( name = "V2",
                  distribution = LogNormal( mu = 15.0, omega = sqrt( 0.1 ) ) ),
  ModelParameter( name = "CL1",
                  distribution = LogNormal( mu = 0.13, omega = sqrt( 0.06 ) ) ),
  ModelParameter( name = "CL2",
                  distribution = LogNormal( mu = 0.60, omega = sqrt( 0.2 ) ) ) )

# Error Model
errorModelRespPK1 = Combined1( outcome = "RespPK1", sigmaInter = 0.6, sigmaSlope = 0.07 )
errorModelRespPK2 = Proportional( outcome = "RespPK2", sigmaSlope = 0.15 )
modelError = list( errorModelRespPK1, errorModelRespPK2 )

# Administration
administrationRespPK1 = Administration( outcome = "RespPK1",
                                        Tinf = c(2),
                                        timeDose = c( 0 ),
                                        dose = c( 100 ) )

administrationRespPK2 = Administration( outcome = "RespPK2",
                                        Tinf = c(4),
                                        timeDose = c( 0 ),
                                        dose = c( 150 ) )

# Sampling times
samplingTimesRespPK1 = SamplingTimes( outcome = "RespPK1",
                                      samplings = c(0.5,1,2,6,9,12,24,36,48,72,96,120) )

samplingTimesRespPK2 = SamplingTimes( outcome = "RespPK2",
                                      samplings = c(0.5,1,2,4,6,12,24,36,48,72,96,120) )


# Arms
arm1 = Arm( name = "BrasTest1",
            size = 32,
            administrations = list( administrationRespPK1, administrationRespPK2 ) ,
            samplingTimes = list( samplingTimesRespPK1, samplingTimesRespPK2 ),
            initialCondition = list( "C1" = 0, "C2" = 0 ) )

# Design
design1 = Design( name = "design1", arms = list( arm1 ) )

# Evaluation
evaluationFIM = Evaluation( name = "",
                            modelEquations = modelEquations,
                            modelParameters = modelParameters,
                            modelError = modelError,
                            designs = list( design1 ),
                            fim = fimType,
                            outcomes = list( "RespPK1"="C1", "RespPK2"= "C2"),
                            odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )

evaluationFIM = run( evaluationFIM )

show( evaluationFIM )

# plots
plotOptions = list( unitTime = c("unit time"),
                    unitOutcomes = c("unit RespPK" , "unit RespPD") )



plotOutcomesEvaluation = plotEvaluation( evaluationFIM, plotOptions )
plotSensitivityIndice = plotSensitivityIndice( evaluationFIM, plotOptions )

print( plotOutcomesEvaluation )
print( plotOutcomesGradient )

plotSE = plotSE( evaluationFIM, plotOptions )
plotRSE = plotRSE( evaluationFIM, plotOptions )

print( plotSE )
print( plotRSE )



