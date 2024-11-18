# ----------------------------------------------------------------------------
# IV bolus
# 1-compartment linear elimination
# Single dose
# Turnover model with full Imax effect on Rin
# User-defined ODE models
# Model parameters in initial concentration
# ----------------------------------------------------------------------------

# Model equations
modelEquations = list(

  outcomes = list( "RespPK"  = "Cc",
                   "RespPD"  = "E" ),

  equations = list(  "Deriv_Cc" = "-Cl/V * Cc",
                     "Deriv_E" = "Rin * ( 1-(Imax*(Cc/V) )/( (Cc/V)+C50 ) )-kout*E" ) )

# model parameters
modelParameters = list(

  ModelParameter( name = "V",
                  distribution = LogNormal( mu = 8, omega = sqrt(0.02) ) ),

  ModelParameter( name = "Cl",
                  distribution = LogNormal( mu = 0.13, omega = sqrt( 0.06 ) ) ),

  ModelParameter( name = "Rin",
                  distribution = LogNormal( mu = 5.4, omega = sqrt( 0.2 ) ) ),

  ModelParameter( name = "kout",
                  distribution = LogNormal( mu = 0.06, omega = sqrt( 0.02 ) ) ),

  ModelParameter( name = "Imax",
                  distribution = LogNormal( mu = 1.0, omega = sqrt(0.1) ) ),

  ModelParameter( name = "C50",
                  distribution = LogNormal( mu = 1.2, omega = sqrt( 0.01 ) ) ) )

# Error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
errorModelRespPD = Constant( outcome = "RespPD", sigmaInter = 4 )
modelError = list( errorModelRespPK, errorModelRespPD )

# Administrations
administrationRespPK = Administration( outcome = "Cc", timeDose = c(0), dose = c( 100 ) )

# sampling times
samplingTimesRespPK = SamplingTimes( outcome = "Cc",
                                     samplings = c( 0.5, 1, 2, 6, 9, 12, 24, 36, 48, 72, 96, 120 ) )

samplingTimesRespPD = SamplingTimes( outcome = "E",
                                     samplings = c( 0,24,36,48,72,96,120 ) )

## arms
arm1 = Arm( name = "BrasTest",
            size = 32,
            administrations = list( administrationRespPK ) ,
            samplingTimes   = list( samplingTimesRespPK, samplingTimesRespPD ),
            initialCondition = list( "Cc" = "dose/V",
                                     "E" = "Rin/kout" ) )

# Design
design1 = Design( name = "design1", arms = list( arm1 ) )

# --------------------------------------
# population Fim
# --------------------------------------

evaluationFIM = Evaluation( name = "",
                            modelEquations = modelEquations,
                            modelParameters = modelParameters,
                            modelError = modelError,
                            outcomes = list( "RespPK"  = "Cc", "RespPD"  = "E" ),
                            designs = list( design1 ),
                            fim = fimType,
                            odeSolverParameters = list( atol = 1e-4, rtol = 1e-4 ) )

evaluationFIM = run( evaluationFIM )

show( evaluationFIM )

# plots
plotOptions = list( unitTime=c("unit time"),
                    unitOutcomes = c("unit RespPK","unit RespPD" ) )



plotOutcomesEvaluation = plotEvaluation( evaluationFIM, plotOptions )
plotSensitivityIndice = plotSensitivityIndice( evaluationFIM, plotOptions )

print( plotOutcomesEvaluation )
print( plotOutcomesGradient )

plotSE = plotSE( evaluationFIM, plotOptions )
plotRSE = plotRSE( evaluationFIM, plotOptions )

print( plotSE )
print( plotRSE )







