#' @export
runCohortDiagnostics <- function(
  connectionDetails,
  cohortTable,
  cohortDatabaseSchema,
  cdmDatabaseSchema,
  cohortIds,
  outputFolder,
  databaseId
) {

  cdFolder <- file.path(outputFolder,"CohortDiagnostics")
  if (!file.exists(cdFolder)) {
    dir.create(cdFolder, recursive = TRUE)
  }

  cohortDefinitionSet <- readr::read_csv(
    file = system.file("settings", "CohortsToCreate.csv", package = "PhePheb2024"),
    show_col_types = FALSE
  ) %>%
  dplyr::filter(
    cohortId != 15476
  )

  CohortDiagnostics::executeDiagnostics(
    cohortDefinitionSet = cohortDefinitionSet,
    connectionDetails = connectionDetails,
    cohortTable = cohortTable,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cdmDatabaseSchema = cdmDatabaseSchema,
    exportFolder = cdFolder,
    databaseId = databaseId,
    minCellCount = 5,
    incremental = TRUE,
    incrementalFolder = file.path(cdFolder, "incremental")
  )

  CohortGenerator::dropCohortStatsTables(
    connectionDetails = connectionDetails,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = cohortTable)
  )
}
