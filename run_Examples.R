library(stringr)
library(Deriv)
library(Matrix)
library(pracma)
library(deSolve)
library(ggplot2)

# install.packages("PFIM")
library(PFIM)


locationPath = dirname(rstudioapi::getSourceEditorContext()$path)
generalSavePath = paste(locationPath, "Outputs_test", sep="/") 
dir.create(generalSavePath)

saveScriptExecution <- function(saveFolderPath, scriptsList, scriptsLocationPath){
  for(s in scriptsList){
    scriptPath = paste(scriptsLocationPath, s, sep="/")
    
    saveReportPath = saveFolderPath

    # Execute File
    source(scriptPath, local = TRUE)

    
  }
}

######################################################



# Script location
pathTests_examples = paste(locationPath,"Examples", sep="/")

# Save files location
saveTests_examplesName = "Examples"
saveTests_examplesPath = paste(generalSavePath, saveTests_examplesName, sep="/")
dir.create(saveTests_examplesPath)

# ----------------------------------------------------------------------------
# Evaluation 
# ----------------------------------------------------------------------------

# Script location
pathTestsEvaluation = paste(pathTests_examples,"evaluation", sep="/")

# Save files location
saveTestsEvaluation_Name = "evaluation"
saveTestsEvaluationPath = paste(saveTests_examplesPath, saveTestsEvaluation_Name, sep="/")
dir.create(saveTestsEvaluationPath)

#---analytic_

# Script location
pathEvaluationanalytic = paste( pathTestsEvaluation, "analytic", sep="/")

# Save files location
saveTests_analytic_Name = "analytic"
saveTests_analytic_Path = paste(saveTestsEvaluationPath, saveTests_analytic_Name, sep="/")
dir.create(saveTests_analytic_Path)

scriptsList = list.files(pathEvaluationanalytic, pattern = "\\.[RrSsQq]$")

saveScriptExecution(saveTests_analytic_Path, scriptsList, pathEvaluationanalytic)

#---analytic_infusion

# Script location
pathEvaluationanalytic_infusion = paste( pathTestsEvaluation, "analytic_infusion", sep="/")

# Save files location
saveTests_analytic_infusionName = "analytic_infusion"
saveTests_analytic_infusionPath = paste(saveTestsEvaluationPath, saveTests_analytic_infusionName, sep="/")
dir.create(saveTests_analytic_infusionPath)

scriptsList = list.files(pathEvaluationanalytic_infusion, pattern = "\\.[RrSsQq]$")

# Execute scripts
saveScriptExecution(saveTests_analytic_infusionPath, scriptsList, pathEvaluationanalytic_infusion)

#---ode

# Script location
pathEvaluationode = paste( pathTestsEvaluation, "ode", sep="/")

# Save files location
saveTests_odeName = "ode"
saveTests_odePath = paste(saveTestsEvaluationPath, saveTests_odeName, sep="/")
dir.create(saveTests_odePath)

scriptsList = list.files(pathEvaluationode, pattern = "\\.[RrSsQq]$")

# Execute scripts
saveScriptExecution(saveTests_odePath, scriptsList, pathEvaluationode)

#---ode_infusion

# Script location
pathEvaluationode_infusion = paste( pathTestsEvaluation, "ode_infusion", sep="/")

# Save files location
saveTests_ode_infusionName = "ode_infusion"
saveTests_ode_infusionPath = paste(saveTestsEvaluationPath, saveTests_ode_infusionName, sep="/")
dir.create(saveTests_ode_infusionPath)

scriptsList = list.files(pathEvaluationode_infusion, pattern = "\\.[RrSsQq]$")

# Execute scripts
saveScriptExecution(saveTests_ode_infusionPath, scriptsList, pathEvaluationode_infusion)


# ----------------------------------------------------------------------------
# Optimization
# ----------------------------------------------------------------------------

# Script location
pathTestsOptimization= paste(pathTests_examples,"optimization", sep="/")

# Save files location
saveTestsoptimization_Name = "optimization"
saveTestsoptimizationPath = paste(saveTests_examplesPath, saveTestsoptimization_Name, sep="/")
dir.create(saveTestsoptimizationPath)

#---AlgoMutiplicatif

# Script location
pathOptimizationAlgoMutiplicatif = paste( pathTestsOptimization, "AlgoMutiplicatif", sep="/")

# Save files location
saveTests_AlgoMutiplicatifName = "AlgoMutiplicatif"
saveTests_AlgoMutiplicatifPath = paste(saveTestsoptimizationPath, saveTests_AlgoMutiplicatifName, sep="/")
dir.create(saveTests_AlgoMutiplicatifPath)

scriptsList = list.files(pathOptimizationAlgoMutiplicatif, pattern = "\\.[RrSsQq]$")

# Execute scripts
saveScriptExecution(saveTests_AlgoMutiplicatifPath, scriptsList, pathOptimizationAlgoMutiplicatif)


#---FedorovWynn

# Script location
pathOptimizationFedorovWynn = paste( pathTestsOptimization, "FedorovWynn", sep="/")

# Save files location
saveTests_FedorovWynnName = "FedorovWynn"
saveTests_FedorovWynnPath = paste(saveTestsoptimizationPath, saveTests_FedorovWynnName, sep="/")
dir.create(saveTests_FedorovWynnPath)

scriptsList = list.files(pathOptimizationFedorovWynn, pattern = "\\.[RrSsQq]$")

# Execute scripts
saveScriptExecution(saveTests_FedorovWynnPath, scriptsList, pathOptimizationFedorovWynn)


#---PGBO

# Script location
pathOptimizationPGBO = paste( pathTestsOptimization, "PGBO", sep="/")

# Save files location
saveTests_PGBOName = "PGBO"
saveTests_PGBOPath = paste(saveTestsoptimizationPath, saveTests_PGBOName, sep="/")
dir.create(saveTests_PGBOPath)

scriptsList = list.files(pathOptimizationPGBO, pattern = "\\.[RrSsQq]$")

# Execute scripts
saveScriptExecution(saveTests_PGBOPath, scriptsList, pathOptimizationPGBO)


#---PSO

# Script location
pathOptimizationPSO = paste( pathTestsOptimization, "PSO", sep="/")

# Save files location
saveTests_PSOName = "PSO"
saveTests_PSOPath = paste(saveTestsoptimizationPath, saveTests_PSOName, sep="/")
dir.create(saveTests_PSOPath)

scriptsList = list.files(pathOptimizationPSO, pattern = "\\.[RrSsQq]$")

# Execute scripts
saveScriptExecution(saveTests_PSOPath, scriptsList, pathOptimizationPSO)


#---Simplex

# Script location
pathOptimizationSimplex = paste( pathTestsOptimization, "Simplex", sep="/")

# Save files location
saveTests_SimplexName = "Simplex"
saveTests_SimplexPath = paste(saveTestsoptimizationPath, saveTests_SimplexName, sep="/")
dir.create(saveTests_SimplexPath)

scriptsList = list.files(pathOptimizationSimplex, pattern = "\\.[RrSsQq]$")

# Execute scripts
saveScriptExecution(saveTests_SimplexPath, scriptsList, pathOptimizationSimplex)

