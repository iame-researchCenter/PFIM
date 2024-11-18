# Model equations
modelEquations = list(

  outcomes = list( "RespPK" = "C1",
                   "RespPD" = "C2" ),

  equations = list(  "Deriv_C1" = "dose_RespPK * ka * exp(-(ka * t)) - Cl/V * C1",
                     "Deriv_C2" = "Rin * (1 - (Imax*C1)/(C1 + C50)) - kout * C2" ) )

# model parameters
modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1.6, omega = sqrt(0.7) ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 8, omega = sqrt(0.02) ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 0.13, omega = sqrt(0.06) ) ),
  ModelParameter( name = "Rin", distribution = LogNormal( mu = 5.4, omega = sqrt(0.2) ), fixedMu = TRUE, fixedOmega = TRUE  ),
  ModelParameter( name = "kout",distribution = LogNormal( mu = 0.06, omega = sqrt(0.02) ) ),
  ModelParameter( name = "C50",distribution = LogNormal( mu = 1.2, omega = sqrt(0.01) ) ),
  ModelParameter( name = "Imax", distribution = LogNormal( mu = 1.0, omega = sqrt(0.0) ), fixedMu = TRUE, fixedOmega = TRUE ) )

# error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.0, sigmaSlope = 0.2 )
errorModelRespPD  = Constant( outcome = "RespPD", sigmaInter = 0.1 )

modelError = list( errorModelRespPK,  errorModelRespPD )

# arm
administrationRespPK = Administration( outcome = "RespPK", timeDose = c( 0 ), dose = c( 50 ) )

## sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0.5,1,2,9,48,75,96,120 ) )
samplingTimesRespPD = SamplingTimes( outcome = "RespPD", samplings = c( 0.5,1,2,9,48,75,96,120 ) )

# constraints
administrationConstraintsResp1 = AdministrationConstraints( outcome = "RespPK", doses = c( 100 ) )

samplingConstraintsResp1  = SamplingTimeConstraints( outcome = "RespPK",
                                                     initialSamplings = c( 0.5,2,9,48,96,120 ),
                                                     fixedTimes = c( 0.5, 9, 96 ),
                                                     numberOfsamplingsOptimisable = 4 )

samplingConstraintsResp2  = SamplingTimeConstraints( outcome = "RespPD",
                                                     initialSamplings = c(  0.5,2,9,48,96,120 ),
                                                     fixedTimes = c( 2, 48 ),
                                                     numberOfsamplingsOptimisable = 4 )

arm1 = Arm( name = "BrasTest1",
            size = 32,
            administrations = list( administrationRespPK ),
            samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ),
            administrationsConstraints = list( administrationConstraintsResp1 ),
            samplingTimesConstraints = list( samplingConstraintsResp1, samplingConstraintsResp2 ),
            initialCondition = list( "C1" = 0, "C2" = "Rin/kout" ) )

design1 = Design( name = "design1", arms = list( arm1 ), numberOfArms = 100 )

fimType = "population"

optimization = Optimization( name = "PKPD_ODE_multi_doses_populationFIM",
                             modelEquations = modelEquations,
                             modelParameters = modelParameters,
                             modelError = modelError,
                             optimizer = "FedorovWynnAlgorithm",
                             optimizerParameters = list(
                               elementaryProtocols = list( c(  0.5,2,9,48,96,120 ),
                                                        c(  0.5,2,9,48,96,120 ) ),

                               numberOfSubjects = c(100),
                               proportionsOfSubjects = c(1),
                               showProcess = T ),
                             designs = list( design1 ),
                             fim = fimType,
                             outcomes = list( "RespPK" = "C1","RespPD" = "C2" ),
                             odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )

optimizationFW = run( optimization )






