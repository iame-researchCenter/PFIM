# Model equations
modelEquations = list(
  
  outcomes = list( "RespPK"="Cc",
                   "RespPD" = "E" ),
  
  equations = list( duringInfusion = list( "Deriv_Cc" = "dose_RespPK / ( V * Tinf_RespPK ) - (Cl/V) * Cc",
                                           "Deriv_E" = "Rin * (1-(Imax*Cc)/(Cc+C50))-kout*E" ),
                    
                    afterInfusion  = list( "Deriv_Cc" = "-(Cl/V) * Cc" ,
                                           "Deriv_E" =  "Rin * (1-Imax*Cc/(Cc+C50))-kout*E" ) )
)

# model parameters
modelParameters = list(
  ModelParameter( name = "V",
                  distribution = LogNormal( mu = 8.0, omega = sqrt( 0.02 ) ) ),
  ModelParameter( name = "Cl",
                  distribution = LogNormal( mu = 0.13, omega = sqrt( 0.06 ) ) ),
  ModelParameter( name = "Imax",
                  distribution = LogNormal( mu = 1.0, omega = sqrt( 0.0 ) ) ),
  ModelParameter( name = "Rin",
                  distribution = LogNormal( mu = 5.4, omega = sqrt( 0.2 ) ) ),
  ModelParameter( name = "kout",
                  distribution = LogNormal( mu = 0.06, omega = sqrt( 0.02 ) ) ),
  ModelParameter( name = "C50",
                  distribution = LogNormal( mu = 1.2, omega = sqrt( 0.01 ) ) )
)

# Error Model
# Error Model
errorModelRespPK = Combined1( outcome = "RespPK", sigmaInter = 0.6, sigmaSlope = 0.07 )
errorModelRespPD = Constant( outcome = "RespPD",  sigmaInter = 4.0)
modelError = list( errorModelRespPK, errorModelRespPD )


# Administration
administrationRespPK = Administration( outcome = "RespPK",
                                        Tinf = c(5),
                                        timeDose = c( 0 ),
                                        dose = c( 100 ) )

# Sampling times
samplingTimesRespPK = SamplingTimes( outcome = "RespPK",
                                      samplings = c( 0.5, 1, 2, 6, 9, 12, 24, 36, 48, 72, 96, 120 ) )

samplingTimesRespPD = SamplingTimes( outcome = "RespPD",
                                     samplings = c( 0, 2, 6, 11, 24, 36, 48, 72, 96, 120 ) )


# Arms
arm1 = Arm( name = "BrasTest1",
            size = 32,
            administrations = list( administrationRespPK ) ,
            samplingTimes = list( samplingTimesRespPK, samplingTimesRespPD ),
            initialCondition = list( "Cc" = 0, "E" = "Rin/kout" ) )

# Design
design1 = Design( name = "design1", arms = list( arm1 ) )

# --------------------------------------
# Evaluation

# Evaluate the Fisher Information Matrix for the PopulationFIM
evaluationPopFIM = Evaluation( name = "PKPD_ODE_Infusion_1_dose_populationFIM",
                               modelEquations = modelEquations,
                               modelParameters = modelParameters,
                               modelError = modelError,
                               outcomes = list( "RespPK" = "Cc", "RespPD" = "E" ),
                               designs = list( design1 ),
                               fim = "population",
                               odeSolverParameters = list( atol = 1e-10, rtol = 1e-10 ) )
evaluationPopFIM = run( evaluationPopFIM )

# Evaluate the Fisher Information Matrix for the individualFIM
evaluationIndFIM = Evaluation( name = "PKPD_ODE_Infusion_1_dose_individualFIM",
                               modelEquations = modelEquations,
                               modelParameters = modelParameters,
                               modelError = modelError,
                               outcomes = list( "RespPK" = "Cc", "RespPD" = "E" ),
                               designs = list( design1 ),
                               fim = "individual",
                               odeSolverParameters = list( atol = 1e-10, rtol = 1e-10 ) )
evaluationIndFIM = run( evaluationIndFIM )

# Evaluate the Fisher Information Matrix for the bayesianFIM
evaluationBayeFIM = Evaluation( name = "PKPD_ODE_Infusion_1_dose_bayesianFIM",
                                modelEquations = modelEquations,
                                modelParameters = modelParameters,
                                modelError = modelError,
                                outcomes = list( "RespPK" = "Cc", "RespPD" = "E" ),
                                designs = list( design1 ),
                                fim = "Bayesian",
                                odeSolverParameters = list( atol = 1e-10, rtol = 1e-10 ) )
evaluationBayeFIM = run( evaluationBayeFIM )

### Reports

plotOptions = list( unitTime=c("unit time"),
                    unitResponses= c("unit RespPK","unit RespPD" ) )

outputFile = paste0("PKPD_ODE_Infusion_1_dose_populationFIM.html")
Report( evaluationPopFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PKPD_ODE_Infusion_1_dose_individualFIM.html")
Report( evaluationIndFIM, saveReportPath, outputFile, plotOptions )

outputFile = paste0("PKPD_ODE_Infusion_1_dose_bayesianFIM.html")
Report( evaluationBayeFIM, saveReportPath, outputFile, plotOptions )







