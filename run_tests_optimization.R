library(stringr)
library(Deriv)
library(Matrix)
library(pracma)
library(deSolve)
library(ggplot2)
library(kableExtra)

# install.packages("PFIM")
# library(PFIM)

locationPath = dirname(rstudioapi::getSourceEditorContext()$path)
generalSavePath = paste(locationPath, "Outputs", sep="/")

saveScriptExecution = function(saveFolderPath, scriptsList, scriptsLocationPath){
  for(s in scriptsList){
    currentFileNamewithoutExt = tools::file_path_sans_ext(s)

    savePath = paste(saveFolderPath, currentFileNamewithoutExt, sep="/")
    dir.create(savePath)

    saveFileName = paste0(currentFileNamewithoutExt, ".txt")
    saveFilePath = paste(savePath, saveFileName, sep="/")

    scriptPath = paste(scriptsLocationPath, s, sep="/")

    savePlotPath = savePath
    saveReportPath = savePath

    # Writing console output to log file
    sink(saveFilePath, append = TRUE, type = "output")

    # Execute File
    source(scriptPath, local = TRUE)

    closeAllConnections()

  }
}

######################################################

# tests_optimization

######################################################

# Script location
pathTests_optimization = paste(locationPath,"tests_optimization", sep="/")

# Save files location
saveTests_optimizationName = "tests_optimization"
saveTests_optimizationPath = paste(generalSavePath, saveTests_optimizationName, sep="/")
dir.create(saveTests_optimizationPath)

folders_optimization = list.files(pathTests_optimization)

for(f in folders_optimization){

  # Script location
  path_f = paste( pathTests_optimization, f, sep="/")

  # Save files location
  saveTests_f_Path = paste(saveTests_optimizationPath, f, sep="/")
  dir.create(saveTests_f_Path)

  scriptsList = list.files(path_f, pattern = "\\.[RrSsQq]$")

  # Execute scripts
  saveScriptExecution(saveTests_f_Path, scriptsList, path_f)

}

