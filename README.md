Phenotype Phebruary 2024
=============

<img src="https://img.shields.io/badge/Study%20Status-Repo%20Created-lightgray.svg" alt="Study Status: Repo Created">

- Analytics use case(s): **Characterization**
- Study type: **Methods Research**
- Tags: **Phenotype Phebruary 2024**
- Study lead: **James Weaver**
- Study lead forums tag: **[jweave17](https://forums.ohdsi.org/u/jweave17)**
- Study start date: **Feb 1, 2024**
- Study end date: **Feb 29, 2024**
- Protocol: **https://forums.ohdsi.org/t/ohdsi-phenotype-phebruary-2024**
- Publications: **TBD**
- Results explorer: **TDB**

How to run
==========
1. In `R`, use the following code to install dependencies:
(Update any additional dependencies if prompted)

  ```r
  install.packages("remotes")
  remotes::install_github("ohdsi/SqlRender")
  remotes::install_github("ohdsi/DatabaseConnector")
  remotes::install_github("ohdsi/OhdsiSharing")
  remotes::install_github("ohdsi/FeatureExtraction")
  remotes::install_github("ohdsi/CohortGenerator")
  remotes::install_github("ohdsi/CohortDiagnostics")
  remotes::install_github("ohdsi/CohortIncidence")
  ```

2. In 'R', use the following code to install the PhePheb2024 package:

  ```r
  remotes::install_github("ohdsi-studies/PhePheb2024")
  ```
  
3. Once installed, you can execute the study by modifying and using the following code:

```r
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

# Sharing: TODO
```
