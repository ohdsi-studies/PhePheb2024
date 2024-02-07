#' @export
runIncidenceAnalysis <- function(
  connectionDetails,
  cdmDatabaseSchema,
  cohortDatabaseSchema,
  cohortTable,
  databaseId,
  outputFolder
) {

  irFolder <- file.path(outputFolder, "Incidence")
  if (!file.exists(irFolder)) {
    dir.create(irFolder, recursive = TRUE)
  }

  cohortDefinitionSet <- readr::read_csv(
    file = system.file("settings", "CohortsToCreate.csv", package = "PhePheb2024"),
    show_col_types = FALSE
  )

  targetCohortIds <- cohortDefinitionSet$cohortId[cohortDefinitionSet$outcome == FALSE]
  outcomeCohortIds <- cohortDefinitionSet$cohortId[cohortDefinitionSet$outcome == TRUE]

  outcomeCleanWindow <- tibble::tibble(
    outcomeCohortId = outcomeCohortIds,
    cleanWindow = rep(9999, length(outcomeCohortIds))
  )

  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)


  # create results table =======================================================

  resultsDatabaseSchema <- sprintf("%s.%s_ir_summary", cohortDatabaseSchema, cohortTable)
  dropTableSql <- sprintf("drop table if exists %s;", resultsDatabaseSchema)
  dropTableSql <- SqlRender::translate(dropTableSql, connectionDetails$dbms)
  ddlSql <- SqlRender::render(CohortIncidence::getResultsDdl(), "schemaName.incidence_summary" = resultsDatabaseSchema)
  ddlSql <- SqlRender::translate(ddlSql, targetDialect = connectionDetails$dbms)
  ddlSql <- paste(dropTableSql, ddlSql)
  DatabaseConnector::executeSql(connection, ddlSql)


  # IR specifications ==========================================================

  tList <- list()
  for (targetCohortId in targetCohortIds) {
    tDef <- CohortIncidence::createCohortRef(
      id = targetCohortId,
      name = cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == targetCohortId]
    )
    tList[[length(tList) + 1]] <- tDef
  }

  oList <- list()
  for (i in 1:nrow(outcomeCleanWindow)) {

    outcomeCohortId <- outcomeCleanWindow$outcomeCohortId[i]
    cleanWindow <- outcomeCleanWindow$cleanWindow[i]

    oDef <- CohortIncidence::createOutcomeDef(
      id = outcomeCohortId,
      name = cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == outcomeCohortId],
      cohortId = outcomeCohortId,
      cleanWindow = cleanWindow
    )
    oList[[length(oList) + 1]] <- oDef
  }

  tar365d <- CohortIncidence::createTimeAtRiskDef(
    id = 1,
    startWith = "start",
    startOffset = 0,
    endWith = "start",
    endOffset = 365
  )
  tarList <- list(tar365d)

  analysis1 <- CohortIncidence::createIncidenceAnalysis(
    targets = targetCohortIds,
    outcomes = outcomeCohortIds,
    tars = 1
  )
  analysisList <- list(analysis1)

  strataSettings <- CohortIncidence::createStrataSettings(
    byAge = TRUE,
    ageBreaks = c(5, 18, 35, 55, 65, 75, 85),
    byGender = TRUE,
    byYear = FALSE
  )

  irDesign <- CohortIncidence::createIncidenceDesign(
    targetDefs = tList,
    outcomeDefs = oList,
    tars = tarList,
    analysisList = analysisList,
    strataSettings = strataSettings
  )

  buildOptions <- CohortIncidence::buildOptions(
    cohortTable = paste(cohortDatabaseSchema, cohortTable, sep = "."),
    sourceName = databaseId,
    cdmDatabaseSchema = cdmDatabaseSchema,
    resultsDatabaseSchema = resultsDatabaseSchema,
    refId = 1
  )

  # IR execution ===============================================================

  targetCohortTable <- sprintf("%s.%s", cohortDatabaseSchema, cohortTable)
  outcomeCohortTable <- sprintf("%s.%s", cohortDatabaseSchema, cohortTable)

  irSql <- CohortIncidence::buildQuery(
    incidenceDesign = as.character(irDesign$asJSON()),
    buildOptions = buildOptions
  )
  irSql <- gsub("\\.incidence_summary", "", irSql)
  irSql <- SqlRender::translate(irSql, targetDialect = connectionDetails$dbms)

  DatabaseConnector::executeSql(connection, irSql)
  irSummarySql <- sprintf("select * from %s", resultsDatabaseSchema)
  irSummary <- DatabaseConnector::querySql(connection, irSummarySql, snakeCaseToCamelCase = TRUE)
  readr::write_csv(irSummary, file.path(irFolder, "irSummary.csv"))
}
