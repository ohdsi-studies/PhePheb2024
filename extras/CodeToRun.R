# specifications ========================================================

library(magrittr)
options(fftempdir = "") # directory location where any temporary files will be stored

outputFolder <- "" # directory location where study results will be saved; e.g. "G:/PhePhebAlzh"
if(!file.exists(outputFolder)){
  dir.create(outputFolder)
}

cohortDatabaseSchema <- "" # database schema name with write access
cohortTable <- "phe_pheb_cohort"

cdmDatabaseSchema <- "" # database schema where your CDM is located
databaseId <- "" # short, concise name of your database, e.g. "cuimc"


# database connection details ==================================================

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "",
  server = "",
  user = "",
  password = ""
)

PhePheb2024::execute(
  connectionDetails = connectionDetails,
  outputFolder = outputFolder,
  targetCohortIds = targetCohortIds,
  outcomeCohortIds = outcomeCohortIds,
  databaseId = databaseId,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  createCohortTable = TRUE,
  createCohorts = TRUE,
  runCohortDiagnostics = TRUE,
  runIncidenceAnalysis = TRUE
)


# review cohort diagnostics ====================================================

cdFolder <- file.path(outputFolder, databaseId, "CohortDiagnostics")

CohortDiagnostics::createMergedResultsFile(
  dataFolder = cdFolder,
  sqliteDbPath = file.path(cdFolder, "MergedCohortDiagnosticsData.sqlite"),
  overwrite = TRUE
)

CohortDiagnostics::launchDiagnosticsExplorer(
  sqliteDbPath =  file.path(cdFolder, "MergedCohortDiagnosticsData.sqlite"),
)


# review IRs ===================================================================

irDataFile <-
file.copy(
  from = file.path(outputFolder, databaseId, "Incidence", "IrSummary.csv"),
  to = "inst/shiny"/"data",
  overwrite = TRUE
)

shiny::runApp(appDir = file.path("inst/shiny"))

# sharing ======================================================================
# TODO
