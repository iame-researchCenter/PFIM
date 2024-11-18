# =================================================================================
# Optimization Multiplicative Algorithm
# Model PK ode bolus multidoses
# population FIM
# =================================================================================


# Model equations
modelEquations = list(
  outcomes = list( "RespPK" = "C1" ),
  equations = list( "Deriv_C1" = "-k*C1") )

# model parameters
modelParameters = list(
  ModelParameter( name = "k", distribution = LogNormal( mu = 0.082, omega = sqrt(0.25) )))

# error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
modelError = list( errorModelRespPK )

# arm
administrationRespPK = Administration( outcome = "C1", timeDose = c( 0), dose = c( 100 ) )

## sampling times
samplingTimesRespPK = SamplingTimes( outcome = "C1", samplings = c( 0.5, 1, 24, 36, 120  ) )

# constraints
administrationConstraintsRespPK = AdministrationConstraints( outcome = "C1", doses = c( 100 ) )

samplingConstraintsRespPK  = SamplingTimeConstraints( outcome = "C1",
                                                      initialSamplings = c( 0.5, 1, 2, 6, 96 ,9, 12, 24, 36, 48, 72, 120 ),
                                                      numberOfsamplingsOptimisable = 5,
                                                      fixedTimes = c( 0.5, 96, 72 ) )

arm1 = Arm( name = "BrasTest1",
            size = 100,
            administrations = list( administrationRespPK ),
            samplingTimes   = list( samplingTimesRespPK ),
            administrationsConstraints = list( administrationConstraintsRespPK ),
            samplingTimesConstraints = list( samplingConstraintsRespPK ),
            initialCondition = list( "C1" = "dose" ) )

design1 = Design( name = "design1", arms = list( arm1 ), numberOfArms = 100 )


optimization = Optimization( name = "PKPD_ODE_multi_doses_populationFIM",
                             modelEquations = modelEquations,
                             modelParameters = modelParameters,
                             modelError = modelError,
                             optimizer = "MultiplicativeAlgorithm",
                             optimizerParameters = list( lambda = 0.99,
                                                         numberOfIterations = 1000,
                                                         weightThreshold = 0.001,
                                                         delta = 1e-04, showProcess = T ),
                             designs = list( design1 ),
                             fim = "population",
                             outcomes = list( "RespPK" = "C1" ),
                             odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )

optimizationAlgoMult = run( optimization )



