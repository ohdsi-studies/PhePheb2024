#' @export
execute <- function(
  connectionDetails,
  outputFolder,
  targetCohortIds = NULL,
  outcomeCohortIds = NULL,
  databaseId = NULL,
  cdmDatabaseSchema,
  cohortDatabaseSchema,
  cohortTable = "phe_pheb_cohort",
  createCohortTable = FALSE,
  createCohorts = FALSE,
  runCohortDiagnostics = FALSE,
  runIncidenceAnalysis = FALSE
) {

  start <- Sys.time()

  dbOutputFolder <- file.path(outputFolder, databaseId)
  if (!file.exists(dbOutputFolder)) {
    dir.create(dbOutputFolder, recursive = TRUE)
  }

  if (createCohortTable) {

    CohortGenerator::createCohortTables(
      connectionDetails = connectionDetails,
      cohortDatabaseSchema = cohortDatabaseSchema,
      cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable),
      incremental = TRUE
    )
  }

  if (createCohorts) {

    PhePheb2024::createCohorts(
      cohortIds = c(targetCohortIds, outcomeCohortIds),
      connectionDetails = connectionDetails,
      cdmDatabaseSchema = cdmDatabaseSchema,
      cohortDatabaseSchema = cohortDatabaseSchema,
      cohortTable = cohortTable,
      outputFolder = dbOutputFolder
    )
  }

  if (runCohortDiagnostics) {

    PhePheb2024::runCohortDiagnostics(
      connectionDetails = connectionDetails,
      cohortTable = cohortTable,
      cohortDatabaseSchema = cohortDatabaseSchema,
      cdmDatabaseSchema = cdmDatabaseSchema,
      cohortIds = outcomeCohortIds,
      outputFolder = dbOutputFolder,
      databaseId = databaseId
    )

  }

  if (runIncidenceAnalysis) {

    PhePheb2024::runIncidenceAnalysis(
      connectionDetails = connectionDetails,
      cdmDatabaseSchema = cdmDatabaseSchema,
      cohortDatabaseSchema = cohortDatabaseSchema,
      cohortTable = cohortTable,
      databaseId = databaseId,
      targetCohortIds = targetCohortIds,
      outcomeCohortIds = outcomeCohortIds,
      cleanWindows = cleanWindows,
      outputFolder = dbOutputFolder
    )
  }

  delta <- Sys.time() - start
  sprintf("Executing study took %f %s", signif(delta, 3), attr(delta, "units"))
}
