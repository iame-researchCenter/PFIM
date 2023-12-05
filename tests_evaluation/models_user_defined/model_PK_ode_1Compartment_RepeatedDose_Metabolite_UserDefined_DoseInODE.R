
# Model equations
modelEquations = list(

  outcomes = list( "RespPK1"  = "C1",
                   "RespPK2"  = "C2" ),

  equations = list(  "Deriv_C1" = "dose_RespPK1 * ka / V  * exp( -ka * t ) - Cl * C1/V",
                     "Deriv_C2" = "V*C1/Vm - Clm/Vm * C2" ) )

# model parameters
modelParameters = list(
  ModelParameter( name = "ka",
                  distribution = LogNormal( mu = 1.24, omega =sqrt ( 0 ) ) ),
  ModelParameter( name = "V",
                  distribution = LogNormal( mu = 750, omega = sqrt( 0 ) ) ),
  ModelParameter( name = "Cl",
                  distribution = LogNormal( mu = 28.1, omega = ( 0.433 ) ) ),
  ModelParameter( name = "Vm",
                  distribution = LogNormal( mu = 1860, omega = ( 0 ) ) ),
  ModelParameter( name = "Clm",
                  distribution = LogNormal( mu = 53.6, omega = ( 0.499 ) ) ) )


# Error Model
errorModelRespPK1 = Proportional( outcome = "RespPK1", sigmaSlope = 0.0954  )
errorModelRespPK2 = Proportional( outcome = "RespPK2", sigmaSlope = 0.153  )
modelError = list( errorModelRespPK1, errorModelRespPK2 )

## administration
administrationCompC1 = Administration( outcome = "RespPK1", tau = c(24), dose = c(200) )

## sampling times
samplingTimesCompC1 = SamplingTimes( outcome = "RespPK1", samplings = c( 0.5, 170, 180, 192 ) )
samplingTimesCompC2 = SamplingTimes( outcome = "RespPK2", samplings = c( 0.5, 170, 180, 192 ) )

# arms
arm1 = Arm( name = "BrasTest",
            size = 20,
            administrations  = list( administrationCompC1 ) ,
            samplingTimes    = list( samplingTimesCompC1, samplingTimesCompC2 ),
            initialCondition = list( "C1"= 0, "C2" = 0 ) )

# Design
design1 = Design( name = "design1",
                  arms = list( arm1 ) )


evaluationFIM = Evaluation( name = "",
                               modelEquations = modelEquations,
                               modelParameters = modelParameters,
                               modelError = modelError,
                               outcomes = list( "RespPK1"  = "C1", "RespPK2"  = "C2" ),
                               designs = list( design1  ),
                               odeSolverParameters = list( atol=1e-10, rtol=1e-10 ),
                               fim = fimType )

evaluationFIM = run( evaluationFIM )

show( evaluationFIM )

# plots
plotOptions = list( unitTime=c("unit time"),
                    unitOutcomes = c("unit RespPK","unit RespPD" ) )

plotEvaluationPopulation = plot( evaluationFIM, plotOptions )

plotOutcomesEvaluation = plotEvaluationPopulation$plotOutcomesEvaluation
plotOutcomesGradient = plotEvaluationPopulation$plotOutcomesGradient

plotSE = plotSE( evaluationFIM, plotOptions )
plotRSE = plotRSE( evaluationFIM, plotOptions )

print( plotOutcomesEvaluation )
print( plotOutcomesGradient )
print( plotSE )
print( plotRSE )

# # ==========================================================
# # evaluation fims
# # ==========================================================
# 
# evaluationPoPFIM = Evaluation( name = "",
#                             modelEquations = modelEquations,
#                             modelParameters = modelParameters,
#                             modelError = modelError,
#                             outcomes = list( "RespPK1"  = "C1", "RespPK2"  = "C2" ),
#                             designs = list( design1  ),
#                             odeSolverParameters = list( atol=1e-10, rtol=1e-10 ),
#                             fim = "population" )
# 
# evaluationIndFIM = Evaluation( name = "",
#                             modelEquations = modelEquations,
#                             modelParameters = modelParameters,
#                             modelError = modelError,
#                             outcomes = list( "RespPK1"  = "C1", "RespPK2"  = "C2" ),
#                             designs = list( design1  ),
#                             odeSolverParameters = list( atol=1e-10, rtol=1e-10 ),
#                             fim = "individual" )
# 
# evaluationBayesianFIM = Evaluation( name = "",
#                             modelEquations = modelEquations,
#                             modelParameters = modelParameters,
#                             modelError = modelError,
#                             outcomes = list( "RespPK1"  = "C1", "RespPK2"  = "C2" ),
#                             designs = list( design1  ),
#                             odeSolverParameters = list( atol=1e-10, rtol=1e-10 ),
#                             fim = "Bayesian" )
# 
# evaluationPoPFIM = run( evaluationPopFIM )
# evaluationIndFIM = run( evaluationIndFIM )
# evaluationBayesianFIM = run( evaluationBayesianFIM )
# 
# show( evaluationPoPFIM )
# show( evaluationIndFIM )
# show( evaluationBayesianFIM )

# # ==========================================================
# # Report
# # ==========================================================
# 
# outputPath = "D:/RECHERCHES/_PFIM/PFIM/PFIM6/tests_PFIM6/tests_Lucie_Romain/reports_models_user_defined"
# 
# outputFilePop = "reportPopFim.html"
# outputFileInd = "reportIndFim.html"
# outputFileBay = "reportBayFim.html"
# 
# plotOptions = list( unitTime=c("unit time"),
#                     unitOutcomes = c("unit RespPK","unit RespPD" ) )
# 
# Report( evaluationPopFIM, outputPath, outputFilePop, plotOptions )
# Report( evaluationIndFIM, outputPath, outputFileInd, plotOptions )
# Report( evaluationBayesianFIM, outputPath, outputFileBay, plotOptions )
# 
# 
# 
# 

