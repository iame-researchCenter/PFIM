# ----------------------------------------------------------------------------
# Model ODE & repeated doses
# Model with dose not in equation
# ----------------------------------------------------------------------------

# model equations
modelEquations = list(

  outcomes = list( "RespPK" = "C2", "RespPD" = "C3" ),

  equations = list(  "Deriv_C1" = "-ka*C1",
                     "Deriv_C2" = "ka*C1 + C3*Q/V2 - C2*(Cl/V1+Q/V1)",
                     "Deriv_C3" = "C2* Q/V1-C3*Q/V2" ) )

modelParameters = list(
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 10,   omega = 1.0 ) ),
  ModelParameter( name = "V1", distribution = LogNormal( mu = 100,  omega = 0.0 ) ),
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1,    omega = 0.433 ) ),
  ModelParameter( name = "Q",  distribution = LogNormal( mu = 3.0,  omega = 0.0 ) ),
  ModelParameter( name = "V2", distribution = LogNormal( mu = 40.0, omega = 0.499 ) ) )

# Error Model
errorModelRespPK = Proportional( outcome = "RespPK", sigmaSlope = 0.0954 )
errorModelRespPD = Proportional( outcome = "RespPD", sigmaSlope = 0.153 )
modelError = list( errorModelRespPK, errorModelRespPD )

# administration
administrationC1 = Administration( outcome = "C1", tau = c(24), dose = c(200) )
#administrationC1 = Administration( outcome = "C1", timeDose =  c(0,  24,  48,  72,  96, 120, 144, 168, 192),
#                                                    dose = c(0,200,200,200,200,200,200,200,200) )

# sampling times
samplingTimesC2 = SamplingTimes( outcome = "C2", samplings = c( 0.5, 170, 172, 175, 180, 192 ) )
samplingTimesC3 = SamplingTimes( outcome = "C3", samplings = c( 0.5, 170, 180, 192 ) )

# arms
arm1 = Arm( name = "BrasTest",
            size = 20,
            administrations  = list( administrationC1 ) ,
            samplingTimes    = list( samplingTimesC2, samplingTimesC3 ),
            initialCondition = list( "C2" = 100, "C3" = 0 ) )

design1 = Design( name = "design1", arms = list( arm1 ) )

# Evaluation
evaluationFIM = Evaluation( name = "PKPD_ODE_multi_doses_compartment_Clozapine",
                            modelEquations = modelEquations,
                            modelParameters = modelParameters,
                            modelError = modelError,
                            designs = list( design1 ),
                            fim = fimType,
                            outcomes = list( "RespPK" = "C2", "RespPD" = "C3/2" ),
                            odeSolverParameters = list( atol = 1e-8, rtol = 1e-8 ) )

evaluationFIM = run( evaluationFIM )

show( evaluationFIM )

# plots
plotOptions = list( unitTime = c("unit time"),
                    unitOutcomes = c("unit RespPK" , "unit RespPD") )

plotEvaluationPopulation = plot( evaluationFIM, plotOptions )

plotOutcomesEvaluation = plotEvaluationPopulation$plotOutcomesEvaluation
plotOutcomesGradient = plotEvaluationPopulation$plotOutcomesGradient

print( plotOutcomesEvaluation )
print( plotOutcomesGradient )

plotSE = plotSE( evaluationFIM, plotOptions )
plotRSE = plotRSE( evaluationFIM, plotOptions )

print( plotSE )
print( plotRSE )







