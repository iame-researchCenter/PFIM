# model equations
modelEquations = list(
  
  outcomes = list( "RespPK1" = "C1", "RespPK2" = "C2" ),
  
  equations = list(  "Deriv_C1" = "dose_RespPK1 * ka / V  * exp( -ka * t ) - Cl * C1/V",
                     "Deriv_C2" = "Cl/V*C1 - Clm/Vm * C2" 
  )
)

modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1.24, omega = 0 ) ),
  ModelParameter( name = "V", distribution = LogNormal( mu = 750,  omega = 0.0 ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 28.1,   omega = 0.433 ) ),
  ModelParameter( name = "Vm", distribution = LogNormal( mu = 1860, omega = 0.499 ) ),
  ModelParameter( name = "Clm",  distribution = LogNormal( mu = 53.6,  omega = 0.499 ) )
)

# Error Model
errorModelRespPK1 = Proportional( outcome = "RespPK1", sigmaSlope = 0.0954 )
errorModelRespPK2 = Proportional( outcome = "RespPK2", sigmaSlope = 0.153 )
modelError = list( errorModelRespPK1, errorModelRespPK2 )

# administration
administrationC1 = Administration( outcome = "RespPK1", tau = c(24), dose = c(200) )

# sampling times
samplingTimesC1 = SamplingTimes( outcome = "RespPK1", samplings = c( 0.5, 170, 180, 192 ) )
samplingTimesC2 = SamplingTimes( outcome = "RespPK2", samplings = c( 0.5, 170, 180, 192 ) )


# arms
arm1 = Arm( name = "BrasTest",
            size = 20,
            administrations  = list( administrationC1 ) ,
            samplingTimes    = list( samplingTimesC1, samplingTimesC2 ),
            initialCondition = list( "C1" = 0, "C2" = 0 ) )

design1 = Design( name = "design1", arms = list( arm1 ) )


# --------------------------------------
# Evaluation

# Evaluate the Fisher Information Matrix for the PopulationFIM
evaluationPopFIM = Evaluation( name = "PKPD_ODE_repetead_doses_Clozapine_populationFIM",
                               modelEquations = modelEquations,
                               modelParameters = modelParameters,
                               modelError = modelError,
                               outcomes = list( "RespPK1" = "C1/V", "RespPK2" = "C2/Vm" ),
                               designs = list( design1 ),
                               fim = "population",
                               odeSolverParameters = list( atol = 1e-12, rtol = 1e-12  ) )
evaluationPopFIM = run( evaluationPopFIM )

# Evaluate the Fisher Information Matrix for the individualFIM
evaluationIndFIM = Evaluation( name = "PKPD_ODE_repetead_doses_Clozapine_individualFIM",
                               modelEquations = modelEquations,
                               modelParameters = modelParameters,
                               modelError = modelError,
                               outcomes = list( "RespPK1" = "C1/V", "RespPK2" = "C2/Vm" ),
                               designs = list( design1 ),
                               fim = "individual",
                               odeSolverParameters = list( atol = 1e-10, rtol = 1e-10  ) )
evaluationIndFIM = run( evaluationIndFIM )

# Evaluate the Fisher Information Matrix for the bayesianFIM
evaluationBayeFIM = Evaluation( name = "PKPD_ODE_repetead_doses_Clozapine_bayesianFIM",
                                modelEquations = modelEquations,
                                modelParameters = modelParameters,
                                modelError = modelError,
                                outcomes = list( "RespPK1" = "C1/V", "RespPK2" = "C2/Vm" ),
                                designs = list( design1 ),
                                fim = "Bayesian",
                                odeSolverParameters = list( atol = 1e-10, rtol = 1e-10  ) )
evaluationBayeFIM = run( evaluationBayeFIM )

### Reports

plotOptions = list( unitTime=c("unit time"),
                    unitResponses= c("unit RespPK1","unit RespPK2" ) )

outputFile = paste0("PKPD_ODE_repetead_doses_Clozapine_populationFIM.html")
Report( evaluationPopFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PKPD_ODE_repetead_doses_Clozapine_individualFIM.html")
Report( evaluationIndFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PKPD_ODE_repetead_doses_Clozapine_bayesianFIM.html")
Report( evaluationBayeFIM, saveReportPath, outputFile, plotOptions )
