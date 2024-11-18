# Model equations
modelEquations = list(

  outcomes = list( "RespPK" = "C1",
                   "RespPD" = "C2" ),

  equations = list(  "Deriv_C1" = "(dose_RespPK * ka * exp(-(ka * t)) - Cl * C1)/V",
                     "Deriv_C2" = "(Rin * (1 - (C1)/(C1 + C50)) - kout * C2)" ) )

# model parameters
modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1.6, omega = sqrt(0.7) ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 8, omega = sqrt(0.02) ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 0.13, omega = sqrt(0.06) ) ),
  ModelParameter( name = "Rin", distribution = LogNormal( mu = 5.4, omega = sqrt(0.2) ), fixedMu=TRUE ),
  ModelParameter( name = "kout",distribution = LogNormal( mu = 0.06, omega = sqrt(0.01) ) ),
  ModelParameter( name = "C50",distribution = LogNormal( mu = 1.2, omega = sqrt(0.01) ) ) )

# Error Model
errorModelRespPK1 = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
errorModelRespPD  = Constant( outcome = "RespPD", sigmaInter = 4 )
modelError = list( errorModelRespPK1,  errorModelRespPD )

# Administration
administrationRespPK = Administration( outcome = "RespPK", timeDose = c( 0, 50, 100 ), dose = c( 20, 30, 50 ) )

# Sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0.5, 1, 2, 6, 9, 12, 24, 36, 48, 72, 96, 120 ) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD", samplings = c( 0, 24, 36, 48, 72, 96, 120 ) )

# Arms
arm1 = Arm( name = "BrasTest1",
            size = 32,
            administrations = list( administrationRespPK ) ,
            samplingTimes = list( samplingTimesRespPK, samplingTimesRespPD ),
            initialCondition = list( "C1" = 0, "C2" = "Rin/kout" ) )

# Design
design1 = Design( name = "design1", arms = list( arm1 ) )

# Fim

fimType = "Bayesian"
evaluationFIM = Evaluation( name = "evaluation",
                            modelEquations = modelEquations,
                            modelParameters = modelParameters,
                            modelError = modelError,
                            outcomes = list( "RespPK" = "C1", "RespPD" = "C2" ),
                            designs = list( design1 ),
                            fim = fimType,
                            odeSolverParameters = list( atol = 1e-6, rtol = 1e-6 ) )


start.time = Sys.time()
evaluationFIM = run( evaluationFIM )
end.time = Sys.time()
time.taken = end.time - start.time

print(time.taken)



plotOptions = list( unitTime = c("hour"),
                    unitOutcomes = c("unit RespPK","unit RespPD" ) )

plotOutcomesEvaluation = plotEvaluation( evaluationFIM, plotOptions )
plotSensitivityIndice = plotSensitivityIndice( evaluationFIM, plotOptions )

plotSE = plotSE( evaluationFIM, plotOptions )
plotRSE = plotRSE( evaluationFIM, plotOptions )

