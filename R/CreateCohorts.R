#' @export
createCohorts <- function(
  cohortIds,
  connectionDetails,
  cdmDatabaseSchema,
  cohortDatabaseSchema,
  cohortTable,
  outputFolder
) {

  cohortDefinitionSet <- readr::read_csv(
    file = system.file("settings", "CohortsToCreate.csv", package = "PhePheb2024"),
    show_col_types = FALSE
  )

  cohortsGenerated <- CohortGenerator::generateCohortSet(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable),
    cohortDefinitionSet = cohortDefinitionSet,
    incremental = TRUE,
    incrementalFolder = file.path(outputFolder, "incremental")
  )

  cohortCounts <- CohortGenerator::getCohortCounts(
    connectionDetails = connectionDetails,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTable = cohortTableNames$cohortTable
  )

  readr::write_csv(
    x = cohortCounts,
    file = file.path(outputFolder, "cohort_counts.csv")
  )
}
