# =================================================================================
# Optimization Multiplicative Algorithm
# Model PK analytic multidoses
# population FIM
# =================================================================================

# Model equations
modelEquations = list(

  outcomes = list( "RespPK" = "C1",
                   "RespPD" = "C2" ),

  equations = list(  "Deriv_C1" = "(dose_RespPK * ka * exp(-(ka * t)) - Cl * C1)/V",
                     "Deriv_C2" = "(Rin * (1 - (Imax*C1)/(C1 + C50)) - kout * C2)" ) )

# model parameters
modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1.24, omega = sqrt(0.0) ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 12.2, omega = sqrt(0.25) ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 28.1, omega = sqrt(0.4333) ) ),
  ModelParameter( name = "Rin", distribution = LogNormal( mu = 5.4, omega = sqrt(0.2) ) ),
  ModelParameter( name = "kout",distribution = LogNormal( mu = 0.06, omega = sqrt(0.02) ) ),
  ModelParameter( name = "C50",distribution = LogNormal( mu = 1.2, omega = sqrt(0.01) ) ),
  ModelParameter( name = "Imax",distribution = LogNormal( mu = 1.0, omega = sqrt(0.1) ) ) )

# error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
errorModelRespPD  = Constant( outcome = "RespPD", sigmaInter = 4 )
modelError = list( errorModelRespPK,  errorModelRespPD )

# arm
administrationRespPK = Administration( outcome = "RespPK", timeDose = c( 0), dose = c( 100 ) )

## sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0.5, 1, 2, 6, 9, 12, 24, 36, 48, 72, 96, 120 ) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD", samplings = c( 0, 24, 36, 48, 72, 96, 120 ) )

# constraints
administrationConstraintsRespPK = AdministrationConstraints( outcome = "RespPK", doses = c( 100 ) )

samplingConstraintsRespPK  = SamplingTimeConstraints( outcome = "RespPK",
                                                      initialSamplings = c( 0.5, 1, 2, 6, 9, 12, 24, 36, 48, 72, 96, 120 ),
                                                      numberOfsamplingsOptimisable = 5,
                                                      fixedTimes = c(0.5, 1, 9, 96 ) )

samplingConstraintsRespPD = SamplingTimeConstraints( outcome = "RespPD",
                                                     initialSamplings = c( 0, 24, 36, 48, 72, 96, 120 ),
                                                     numberOfsamplingsOptimisable = 5,
                                                     fixedTimes = c( 0, 24, 72, 120 ) )

arm1 = Arm( name = "BrasTest1",
            size = 100,
            administrations = list( administrationRespPK ),
            samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ),
            administrationsConstraints = list( administrationConstraintsRespPK ),
            samplingTimesConstraints = list( samplingConstraintsRespPK, samplingConstraintsRespPD ),
            initialCondition = list( "C1" = 0, "C2" = "Rin/kout" ) )

design1 = Design( name = "design1", arms = list( arm1 ), numberOfArms = 100 )

optimization = Optimization( name = "PKPD_ODE_multi_doses_populationFIM",
                             modelEquations = modelEquations,
                             modelParameters = modelParameters,
                             modelError = modelError,
                             optimizer = "MultiplicativeAlgorithm",
                             optimizerParameters = list( lambda = 0.99,
                                                         numberOfIterations = 1000,
                                                         delta = 1e-04, showProcess = T ),
                             designs = list( design1 ),
                             fim = "population",
                             outcomes = list( "RespPK" = "C1","RespPD" = "C2" ),
                             odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )

optimizationMA = run( optimization )

show( optimizationMA )

# # ===============================================
# # Report
# # ===============================================
# 
# outputPath = "C:/Users/ADMIN Romain LEROUX/Documents/GIT PFIM/PFIM/PFIM6/tests_PFIM6"
# 
# outputFile = "reportPopFim_algoMult_pkpd_analytic_multiDoses.html"
# 
# plotOptions = list( unitTime=c("unit time"),
#                     unitOutcomes = c("unit RespPK","unit RespPD" ),
#                     threshold = 0.01 )
# 
# Report( optimizationMA, outputPath, outputFile, plotOptions )
