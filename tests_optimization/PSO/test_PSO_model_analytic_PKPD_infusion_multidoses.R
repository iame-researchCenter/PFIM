# =================================================================================
# Optimization PSO
# Model analytic infusion multidoses
# population FIM
# =================================================================================

# model equations
modelEquations = list(

  outcomes = list( "RespPK", "RespPD" ),

  equations = list( duringInfusion = list( "RespPK" = "dose_RespPK/Tinf_RespPK/Cl * (1 - exp(-Cl/V * t ) )",
                                           "RespPD" = "S0 + RespPK * Alin" ),

                    afterInfusion  = list( "RespPK" = "dose_RespPK/Tinf_RespPK/Cl * (1 - exp(-Cl/V * Tinf_RespPK)) * (exp(-Cl/V * (t - Tinf_RespPK ) ) )",
                                           "RespPD" = "S0 + RespPK * Alin") ) )

# model parameters
modelParameters = list(
  ModelParameter( name = "V",    distribution = LogNormal( mu = 3.5, omega = 0.09 ) ),
  ModelParameter( name = "Cl",   distribution = LogNormal( mu = 2,   omega = 0.09 ) ),
  ModelParameter( name = "Alin", distribution = LogNormal( mu = 10,  omega = 0.5 ) ),
  ModelParameter( name = "S0",   distribution = LogNormal( mu = 1.0, omega = 0.1 ), fixedMu = TRUE ) )

# error model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.1, sigmaSlope = 0.1 )
errorModelRespPD = Constant(  outcome = "RespPD", sigmaInter = 0.8 )
modelError = list( errorModelRespPK, errorModelRespPD )

# administration
administrationRespPK = Administration( outcome = "RespPK",
                                       Tinf = c(2, 5),
                                       timeDose = c( 0, 10 ),
                                       dose = c( 5, 15 ) )

# sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0, 1, 2, 5, 7,8, 10,12,14, 15, 16, 20, 21, 30 ) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD", samplings = c( 0, 2, 10, 12, 14, 20, 30 ) )

# samplingConstraints
samplingConstraintsRespPK  = SamplingTimeConstraints( outcome = "RespPK",
                                                      initialSamplings = c( 0, 1, 2, 5, 7,8, 10,12,14, 15, 16, 20, 21, 30  ),
                                                      samplingsWindows = list( c( 0,15 ), c( 16,30 ) ),
                                                      numberOfTimesByWindows = c( 10,4 ),
                                                      minSampling = c( 1, 2 ) )

samplingConstraintsRespPD  = SamplingTimeConstraints( outcome = "RespPD",
                                                      initialSamplings = c( 0, 2, 10, 12, 14, 20, 30  ),
                                                      samplingsWindows = list( c( 0,14 ),c( 20, 30 ) ),
                                                      numberOfTimesByWindows = c( 6, 1 ),
                                                      minSampling = c( 2, 0 ) )

# =============================================================
# complete and partial sampling times constraints
# =============================================================

# arm1 = Arm( name = "BrasTest1",
#             size = 100,
#             administrations = list( administrationRespPK ),
#             samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ),
#             samplingTimesConstraints = list( samplingConstraintsRespPK, samplingConstraintsRespPD ) )
#
# arm2 = Arm( name = "BrasTest2",
#             size = 100,
#             administrations = list( administrationRespPK ),
#             samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ),
#             samplingTimesConstraints = list( samplingConstraintsRespPK, samplingConstraintsRespPD ) )


arm1 = Arm( name = "BrasTest1",
            size = 100,
            administrations = list( administrationRespPK ),
            samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ),
            samplingTimesConstraints = list( samplingConstraintsRespPD ) )

arm2 = Arm( name = "BrasTest2",
            size = 100,
            administrations = list( administrationRespPK ),
            samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ),
            samplingTimesConstraints = list( samplingConstraintsRespPK ) )


design1 = Design( name = "design1", arms = list( arm1, arm2 ), numberOfArms = 100 )

optimization = Optimization( name = "PKPD_ODE_multi_doses_populationFIM",

                             modelEquations = modelEquations,
                             modelParameters = modelParameters,
                             modelError = modelError,

                             optimizer = "PSOAlgorithm",

                             optimizerParameters = list(
                               maxIteration = 100,
                               populationSize = 10,
                               personalLearningCoefficient = 2.05,
                               globalLearningCoefficient = 2.05,
                               seed = 1234,
                               showProcess = T  ),

                             designs = list( design1 ),

                             fim = "population",

                             outcomes = list( "RespPK","RespPD" ) )

optimizationPSO = run( optimization )

