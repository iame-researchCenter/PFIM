# =================================================================================
# Optimization PGBO
# Model analytic multidoses
# population FIM
# =================================================================================

# Model equations
modelEquations = list(

  outcomes = list( "RespPK", "RespPD" ),

  equations = list(  "RespPK" = "dose_RespPK / V * ka/(ka - (Cl/V)) * (exp(-(Cl/V) * t) - exp(-ka * t))",
                     "RespPD" = "S0 * ( 1 - 0.73 * RespPK / ( RespPK + S0 ) )" ) )

# model parameters
modelParameters = list(
  ModelParameter( name = "V",    distribution = LogNormal( mu = 8, omega = 0.02 ) ),
  ModelParameter( name = "Cl",   distribution = LogNormal( mu = 0.13, omega = 0.06 ) ),
  ModelParameter( name = "S0",   distribution = LogNormal( mu = 100, omega = 0.1 ) ),
  ModelParameter( name = "ka",  distribution = LogNormal( mu = 1.6, omega = 0.7 ) ) )

# error model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
errorModelRespPD = Constant( outcome = "RespPD", sigmaInter = 8 )
modelError = list( errorModelRespPK, errorModelRespPD )

# arm
administrationRespPK = Administration( outcome = "RespPK", timeDose = c( 0,20,50,70 ), dose = c( 100,80,50,20 ) )

# sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0.5, 8, 20, 120 ) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD", samplings = c( 2, 12, 30, 115 ) )

# samplingConstraints
samplingConstraintsRespPK  = SamplingTimeConstraints( outcome = "RespPK",
                                                      initialSamplings = c( 0.5, 8, 20, 120 ),
                                                      samplingsWindows = list( c( 0,40),c(60,120) ),
                                                      numberOfTimesByWindows = c(2,2),
                                                      minSampling = c(1,5 ) )

samplingConstraintsRespPD  = SamplingTimeConstraints( outcome = "RespPD",
                                                      initialSamplings = c( 2, 12, 30, 115 ),
                                                      samplingsWindows = list( c( 0,40),c(60, 115 )  ),
                                                      numberOfTimesByWindows = c(3,1),
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
            samplingTimesConstraints = list( samplingConstraintsRespPK ) )

arm2 = Arm( name = "BrasTest2",
            size = 100,
            administrations = list( administrationRespPK ),
            samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ),
            samplingTimesConstraints = list( samplingConstraintsRespPD ) )

design1 = Design( name = "design1", arms = list( arm1, arm2 ), numberOfArms = 100 )

optimization = Optimization( name = "",

                             modelEquations = modelEquations,
                             modelParameters = modelParameters,
                             modelError = modelError,

                             optimizer = "PGBOAlgorithm",

                             optimizerParameters = list(
                               N = 10,
                               muteEffect = 0.35,
                               maxIteration = 50,
                               purgeIteration = 10,
                               seed = 42,
                               showProcess = TRUE  ),

                             designs = list( design1 ),
                             fim = "population",
                             outcomes = list( "RespPK","RespPD" ) )

optimizationPGBO = run( optimization )

show( optimizationPGBO )



