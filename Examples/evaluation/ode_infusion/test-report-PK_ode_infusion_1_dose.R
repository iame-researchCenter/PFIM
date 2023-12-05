# model equations
modelEquations = list(
  
  outcomes = list( "RespPK" = "C1" ),
  
  equations = list( duringInfusion = list( "Deriv_C1" = expression( dose_RespPK / ( V*Tinf_RespPK ) - k*C1 ) ),
                    afterInfusion  = list( "Deriv_C1" = expression( - k*C1 ) ) ) )

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
                                       Tinf = c( 2 ),
                                       timeDose = c( 0 ),
                                       dose = c( 30 ) )

# Sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK", samplings = c( 0.5, 1, 4, 8 ) )

# Arms
arm1 = Arm( name = "BrasTest1",
            size = 40,
            administrations = list( administrationRespPK ) ,
            samplingTimes = list( samplingTimesRespPK ),
            initialCondition = list( "C1" = 0 ) )

# Design
design1 = Design( name = "design1", arms = list( arm1 ) )


# --------------------------------------
# Evaluation

# Evaluate the Fisher Information Matrix for the PopulationFIM
evaluationPopFIM = Evaluation( name = "PK_ODE_Infusion_1_dose_populationFIM",
                               modelEquations = modelEquations,
                               modelParameters = modelParameters,
                               modelError = modelError,
                               outcomes = list( "RespPK" = "C1" ),
                               designs = list( design1 ),
                               fim = "population",
                               odeSolverParameters = list( atol = 1e-10, rtol = 1e-10 ) )
evaluationPopFIM = run( evaluationPopFIM )

# Evaluate the Fisher Information Matrix for the individualFIM
evaluationIndFIM = Evaluation( name = "PK_ODE_Infusion_1_dose_individualFIM",
                               modelEquations = modelEquations,
                               modelParameters = modelParameters,
                               modelError = modelError,
                               outcomes = list( "RespPK" = "C1" ),
                               designs = list( design1 ),
                               fim = "individual",
                               odeSolverParameters = list( atol = 1e-10, rtol = 1e-10 ) )
evaluationIndFIM = run( evaluationIndFIM )

# Evaluate the Fisher Information Matrix for the bayesianFIM
evaluationBayeFIM = Evaluation( name = "PK_ODE_Infusion_1_dose_bayesianFIM",
                                modelEquations = modelEquations,
                                modelParameters = modelParameters,
                                modelError = modelError,
                                outcomes = list( "RespPK" = "C1" ),
                                designs = list( design1 ),
                                fim = "Bayesian",
                                odeSolverParameters = list( atol = 1e-10, rtol = 1e-10 ) )
evaluationBayeFIM = run( evaluationBayeFIM )

### Reports

plotOptions = list( unitTime=c("unit time"),
                    unitResponses= c("unit RespPK","unit RespPD" ) )

outputFile = paste0("PK_ODE_Infusion_1_dose_populationFIM.html")
Report( evaluationPopFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PK_ODE_Infusion_1_dose_individualFIM.html")
Report( evaluationIndFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PK_ODE_Infusion_1_dose_bayesianFIM.html")
Report( evaluationBayeFIM, saveReportPath, outputFile, plotOptions )





