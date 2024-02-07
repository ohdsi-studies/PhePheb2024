# Package maintenance, developer only

library(magrittr)
baseUrl <- keyring::key_get("BASE_URL")
ROhdsiWebApi::authorizeWebApi(baseUrl, "windows")

targetCohortIds <- 15476
outcomeCohortIds <- c(15478, 15480, 15481, 15482, 15483, 15486, 15487, 15488, 15526, 15490, 15007, 15523)
cohortIds <- c(targetCohortIds, outcomeCohortIds)

cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = cohortIds,
  generateStats = FALSE
) %>%
  dplyr::mutate(
    outcome = ifelse(cohortId == targetCohortIds, FALSE, TRUE)
  )

readr::write_csv(
  x = cohortDefinitionSet,
  file = file.path("inst", "settings", "CohortsToCreate.csv")
)

# rebuild
