# ----------------------------------------------------------------------------
# Model analytic infusion & repeated doses
# ----------------------------------------------------------------------------

# model equations
modelEquations = list(

  outcomes = list( "RespPK", "RespPD" ),

  equations = list( duringInfusion = list( "RespPK" = "dose_RespPK/Tinf_RespPK/Cl *
                                           (1 - exp(-Cl/V * t ) )",
                                           "RespPD" = "S0 + RespPK * Alin" ),

                    afterInfusion  = list( "RespPK" = "dose_RespPK/Tinf_RespPK/Cl *
                                           (1 - exp(-Cl/V * Tinf_RespPK)) * (exp(-Cl/V * (t - Tinf_RespPK ) ) )",
                                           "RespPD" = "S0 + RespPK * Alin") ) )

# model parameters
modelParameters = list(
  ModelParameter( name = "V",    distribution = LogNormal( mu = 3.5, omega = 0.09 ) ),
  ModelParameter( name = "Cl",   distribution = LogNormal( mu = 2,   omega = 0.09 ) ),
  ModelParameter( name = "Alin", distribution = LogNormal( mu = 10,  omega = 0.5 ) ),
  ModelParameter( name = "S0",   distribution = LogNormal( mu = 0,   omega = 0.0 ) ) )

# error model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.1, sigmaSlope = 0.1 )
errorModelRespPD = Constant(  outcome = "RespPD", sigmaInter = 0.8 )
modelError = list( errorModelRespPK, errorModelRespPD )

# administration
administrationRespPK = Administration( outcome = "RespPK",
                                       Tinf = c(1),
                                       tau = c(10),
                                       dose = c(30) )
# sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0, 1, 2, 5, 7,8, 10,12,14, 15, 16, 20, 21, 30 ) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD", samplings = c( 0, 2, 10, 12, 14, 20, 30 ) )

# arms
arm1 = Arm( name = "BrasTest",
            size = 40,
            administrations = list( administrationRespPK ) ,
            samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ) )

# Design
design1 = Design( name = "design1",
                  arms = list( arm1 ) )

# evaluationFIM
evaluationFIM = Evaluation( name = "PKPD_analytic_infusion_multi_doses_populationFIM",
                            modelEquations = modelEquations,
                            modelParameters = modelParameters,
                            modelError = modelError,
                            designs = list( design1 ),
                            fim = fimType,
                            outcomes = list( "RespPK","RespPD" ) )

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
