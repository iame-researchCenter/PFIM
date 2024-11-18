# ----------------------------------------------------------------------------
# ODE Infusion Multiple doses
# 1-compartment linear elimination
# ----------------------------------------------------------------------------

# model equations
modelEquations = list(

  outcomes = list( "RespPK" = "Cc" ),

  equations = list( duringInfusion = list( "Deriv_Cc" = expression( dose_RespPK / ( V*Tinf_RespPK ) - k*Cc ) ),
                    afterInfusion  = list( "Deriv_Cc" = expression( - k*Cc ) ) ) )

# model parameters
modelParameters = list(
  ModelParameter( name = "V",
                  distribution = LogNormal( mu = 3.5, omega = sqrt( 0.09 ) ) ),
  ModelParameter( name = "k",
                  distribution = LogNormal( mu = 0.6, omega = sqrt( 0.09 ) ) ) )

# Error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.1, sigmaSlope = 0.1 )
modelError = list( errorModelRespPK )

# Administration
administrationRespPK = Administration( outcome = "RespPK",
                                       Tinf = c(2,5),
                                       timeDose = c(0,10),
                                       dose = c( 50,50 ) )

# Sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c(0.5,1,4,8,10,15,20) )

# Arms
arm1 = Arm( name = "BrasTest1",
            size = 40,
            administrations = list( administrationRespPK ) ,
            samplingTimes = list( samplingTimesRespPK ),
            initialCondition = list( "Cc" = 0 ) )

# Design
design1 = Design( name = "design1", arms = list( arm1 ) )

# Evaluation
evaluationFIM = Evaluation( name = "Inf_1-lin-elim_multi-dose_ode_udef_pFIM",
                            modelEquations = modelEquations,
                            modelParameters = modelParameters,
                            modelError = modelError,
                            designs = list( design1 ),
                            fim = fimType,
                            outcomes = list( "RespPK" = "Cc" ),
                            odeSolverParameters = list( atol=1e-8, rtol=1e-8 ) )

evaluationFIM = run( evaluationFIM )

# plots
plotOptions = list( unitTime = c("unit time"),
                    unitOutcomes = c("unit RespPK") )

plotOutcomesEvaluation = plotEvaluation( evaluationFIM, plotOptions )
plotSensitivityIndice = plotSensitivityIndice( evaluationFIM, plotOptions )

plotSE = plotSE( evaluationFIM, plotOptions )
plotRSE = plotRSE( evaluationFIM, plotOptions )





