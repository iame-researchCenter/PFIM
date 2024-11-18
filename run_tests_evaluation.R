library(stringr)
library(Deriv)
library(Matrix)
library(pracma)
library(deSolve)
library(ggplot2)

# install.packages("PFIM")
# library(PFIM)


locationPath = dirname(rstudioapi::getSourceEditorContext()$path)
generalSavePath = paste(locationPath, "Outputs", sep="/")
dir.create(generalSavePath)

saveScriptExecution = function(saveFolderPath, scriptsList, scriptsLocationPath){

  for(s in scriptsList){
    currentFileNamewithoutExt = tools::file_path_sans_ext(s)

    savePath = paste(saveFolderPath, currentFileNamewithoutExt, sep="/")
    dir.create(savePath)

    saveFileName = paste0(currentFileNamewithoutExt, ".txt")
    saveFilePath = paste(savePath, saveFileName, sep="/")

    scriptPath = paste(scriptsLocationPath, s, sep="/")

    savePlotPath = savePath

    # Writing console output to log file
    sink(saveFilePath, append = TRUE, type = "output")

    # Execute File
    source(scriptPath, local = TRUE)

    closeAllConnections()

  }
}

saveScriptExecutionFIM = function(saveFolderPath, scriptsList, scriptsLocationPath, fimTypes.List){
  for(s in scriptsList){
    currentFileNamewithoutExt = tools::file_path_sans_ext(s)

    savePath = paste(saveFolderPath, currentFileNamewithoutExt, sep="/")
    dir.create(savePath)

    # Test the different fim
    for(f in fimTypes.List){
      fimType = f

      saveFimPath = paste(savePath, fimType, sep="/")
      dir.create(saveFimPath)

      saveFileName = paste0(currentFileNamewithoutExt, "_", fimType, ".txt")
      saveFilePath = paste(saveFimPath, saveFileName, sep="/")

      scriptPath = paste(scriptsLocationPath, s, sep="/")

      savePlotPath = saveFimPath

      if(nchar(saveFilePath)>259){
        saveFilePath = str_sub(saveFilePath, 1, 255)
        saveFilePath = paste0(saveFilePath, ".txt")
      }

      # Writing console output to log file
      sink(saveFilePath, append = TRUE, type = "output")

      # Execute File
      source(scriptPath, local = TRUE)

      # Save plots
      savePlotOutcomesEvaluation(plotOutcomesEvaluation, savePlotPath)
      saveplotSensitivityIndice(plotSensitivityIndice, savePlotPath)

      savePlotSEandRSE(plotSE, "SE", savePlotPath)
      savePlotSEandRSE(plotRSE, "RSE", savePlotPath)

      outputFile = paste0("report", fimType, "Fim.html")

      Report( evaluationFIM, savePlotPath, outputFile, plotOptions )

      closeAllConnections()

    }
  }
}

# ----------------------------------------------------------------------------
# Plot functions
# ----------------------------------------------------------------------------

savePlotOutcomesEvaluation = function(plotOutcomesEvaluation, savePath){
  # Save plot result for  each response, inside each arm, inside each design
  #plotOutcomesEvaluation list: design - arm - response
  nDesigns = length(plotOutcomesEvaluation)
  for(d in 1:nDesigns){
    nArms = length(plotOutcomesEvaluation[[d]])
    for(a in 1:nArms){
      nResponses = length(plotOutcomesEvaluation[[d]][[a]])
      for(r in 1:nResponses){
        name = paste0("plotEvaluation_Design", d, "_Arm", a, "_Response", r, ".jpg")
        path = paste(savePath, name, sep="/")
        jpeg(path,units="in", width=5, height=5, res=300)
        print(plotOutcomesEvaluation[[d]][[a]][[r]])
        dev.off()
      }
    }
  }
}

saveplotSensitivityIndice = function(plotSensitivityIndice, savePath){
  # Save plot result for each parameter inside each response,
  #   inside each arm, inside each design
  # plotSensitivityIndice list: design - arm - response - parameters

  nDesigns = length(plotSensitivityIndice)
  for(d in 1:nDesigns){
    nArms = length(plotSensitivityIndice[[d]])
    for(a in 1:nArms){
      nResponses = length(plotSensitivityIndice[[d]][[a]])
      for(r in 1:nResponses){
        nParameters = length(plotSensitivityIndice[[d]][[a]][[r]])
        for(p in 1:nParameters){
          name = paste0("plotGradient_Design", d, "_Arm", a, "_Response", r, "_Parameter", p, ".jpg")
          path = paste(savePath, name, sep="/")
          jpeg(path,units="in", width=6, height=6, res=300)
          print(plotSensitivityIndice[[d]][[a]][[r]][[p]])
          dev.off()
        }


      }
    }
  }

}

savePlotSEandRSE = function(plot, SEorRSE, savePath){
  # Save plot result for both SE and RSE
  nDesigns = length(plot)
  for(d in 1:nDesigns){
    name = paste0("plot_", SEorRSE, "_Design", d, ".jpg")
    path = paste(savePath, name, sep="/")
    jpeg(path,units="in", width=6, height=6, res=300)
    print(plot[[d]])
    dev.off()
  }
}

######################################################

# tests_dev

######################################################

# Script location
pathTests_dev = paste(locationPath,"tests_evaluation", sep="/")

# Save files location
saveTests_devName = "tests_evaluation"
saveTests_devPath = paste(generalSavePath, saveTests_devName, sep="/")
dir.create(saveTests_devPath)

# FIM types available:
fimTypes.List = c("population", "individual", "Bayesian")

# ----------------------------------------------------------------------------
# EvaluationLibraryOfModels
# ----------------------------------------------------------------------------

# Script location
pathEvaluationLibraryOfModels = paste( pathTests_dev, "library_of_models", sep="/")

# Save files location
saveTests_LibraryOfModelsName = "library_of_models"
saveTests_LibraryOfModelsPath = paste(saveTests_devPath, saveTests_LibraryOfModelsName, sep="/")
dir.create(saveTests_LibraryOfModelsPath)

scriptsList = list.files(pathEvaluationLibraryOfModels, pattern = "\\.[RrSsQq]$")

# Execute scripts
saveScriptExecution(saveTests_LibraryOfModelsPath, scriptsList, pathEvaluationLibraryOfModels)

# ----------------------------------------------------------------------------
# ModelsLibraryOfModel
# ----------------------------------------------------------------------------

# Script location
pathEvaluationModelsLibraryOfModel = paste( pathTests_dev, "models_library_of_model", sep="/")

# Save files location
saveTests_ModelsLibraryOfModelName = "models_library_of_model"
saveTests_ModelsLibraryOfModelPath = paste(saveTests_devPath, saveTests_ModelsLibraryOfModelName, sep="/")
dir.create(saveTests_ModelsLibraryOfModelPath)

scriptsList = list.files(pathEvaluationModelsLibraryOfModel, pattern = "\\.[RrSsQq]$")

# Execute scripts fim = fimType,
saveScriptExecutionFIM(saveTests_ModelsLibraryOfModelPath, scriptsList,
                       pathEvaluationModelsLibraryOfModel,
                       fimTypes.List)

# ----------------------------------------------------------------------------
# UserDefinedModels
# ----------------------------------------------------------------------------

# Script location
pathEvaluationUserDefinedModels = paste( pathTests_dev, "models_user_defined", sep="/")

# Save files location
saveTests_UserDefinedModelsName = "models_user_defined"
saveTests_UserDefinedModelsPath = paste(saveTests_devPath, saveTests_UserDefinedModelsName, sep="/")
dir.create(saveTests_UserDefinedModelsPath)

scriptsList = list.files(pathEvaluationUserDefinedModels, pattern = "\\.[RrSsQq]$")

# Execute scripts
saveScriptExecutionFIM(saveTests_UserDefinedModelsPath, scriptsList,
                       pathEvaluationUserDefinedModels,
                       fimTypes.List)



