# =================================================================================
# Optimization Simplex n-dimension
# Model analytic multidoses
# population FIM
# =================================================================================

# Model equations
modelEquations = list(

  outcomes = list( "RespPK", "RespPD" ),

  equations = list(  "RespPK" = "dose_RespPK/V * ka/(ka - Cl/V) * (exp(-Cl/V * t) - exp(-ka * t))",
                     "RespPD" = "S0 * (1 - Imax * RespPK/( RespPK + C50 ))" ) )

# model parameters
modelParameters = list(
  ModelParameter( name = "V",    distribution = LogNormal( mu = 8, omega = 0.02 ) ),
  ModelParameter( name = "Cl",   distribution = LogNormal( mu = 0.13, omega = 0.06 ) ),
  ModelParameter( name = "S0",   distribution = LogNormal( mu = 100, omega = 0.1 ) ),
  ModelParameter( name = "C50",  distribution = LogNormal( mu = 0.17, omega = 0.7 ) ),
  ModelParameter( name = "ka",   distribution = LogNormal( mu = 1.6, omega = 0.1 ) ),
  ModelParameter( name = "Imax", distribution = LogNormal( mu = 0.73, omega = 0.3 ) ) )

# error model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
errorModelRespPD = Constant( outcome = "RespPD", sigmaInter = 2 )
modelError = list( errorModelRespPK, errorModelRespPD )

# arm
administrationRespPK = Administration( outcome = "RespPK", timeDose = c( 0,20,50,70 ), dose = c( 100,80,50,20 ) )

# sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0, 2, 3, 8, 12, 24, 36, 50, 72, 120 ) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD", samplings = c( 0, 4, 8, 12, 24, 36, 72, 100, 120 ) )


# sampling times constraints
samplingConstraintsRespPK  = SamplingTimeConstraints( outcome = "RespPK",
                                                      initialSamplings = c( 0, 2, 3, 8, 12, 24, 36, 50, 72, 120 ),
                                                      samplingsWindows = list( c(0,24), c(35,130) ),
                                                      numberOfTimesByWindows = c(6,4),
                                                      minSampling = c(1,2) )

samplingConstraintsRespPD  = SamplingTimeConstraints( outcome = "RespPD",
                                                      initialSamplings = c( 0, 4, 8, 12, 24, 36, 72, 100, 120 ),
                                                      samplingsWindows = list( c(0,24), c(35,130) ),
                                                      numberOfTimesByWindows = c(5,4),
                                                      minSampling = c(1,0 ) )

# with all sampling times constraints

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

# with partial sampling times constraints

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
                             optimizer = "SimplexAlgorithm",
                             optimizerParameters = list( pctInitialSimplexBuilding = 20,
                                                         maxIteration = 100,
                                                         tolerance = 1e-6,
                                                         showProcess = TRUE  ),
                             designs = list( design1 ),
                             fim = "population",
                             outcomes = list( "RespPK","RespPD" ) )

optimizationSimplex = run( optimization )


