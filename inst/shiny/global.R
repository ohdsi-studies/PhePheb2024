library(magrittr)
source("R/MeasErrorCorrection.R")

irTable <- readr::read_csv("data/irSummary.csv", show_col_types = FALSE) %>%
  dplyr::select(-c(targetCohortDefinitionId,
                   outcomeCohortDefinitionId)) %>%
  dplyr::rename(
    source = sourceName,
    tName = targetName,
    oName = outcomeName,
    age = ageGroupName,
    sex = genderName,
    atRisk = personsAtRisk,
    IP = incidenceProportionP100p,
    IR = incidenceRateP100py
  ) %>%
  dplyr::mutate(
    IP = round(IP * 10, 3),
    IR = round(IR * 10, 3)
  ) %>%
  dplyr::relocate(
    source,
    tName,
    oName,
    age,
    sex
  ) %>%
  dplyr::mutate(
    sex = ifelse(sex =="MALE", "Male", sex),
    sex = ifelse(sex =="FEMALE", "Female", sex),
    age = ifelse(is.na(age), "0 - 85+", age),
    sex = ifelse(is.na(sex), "Male/Female", sex),
    stratum = paste(sex, age),
    tName = ifelse(tName == "[PhePheb] Persons observed on 1 Jan 2018-2022", "Persons on 1 Jan 2018-2022", tName),
    oName = stringr::str_remove(oName, "\\[PhePheb\\] ")
  )

irTable$sourceOrder <- match(
  irTable$source,
  unique(irTable$source)
)

irTable$ageOrder <- match(
  irTable$age,
  c("0 - 85+", "<5", "5 - 17", "18 - 34", "55 - 64", "35 - 54", "65 - 74", "75 - 84", ">=85")
)

irTable$sexOrder <- match(
  irTable$sex,
  c("Male/Female", "Male", "Female")
)

irTable <- irTable[order(irTable$sourceOrder,
                         irTable$sexOrder,
                         irTable$ageOrder,
                         irTable$oName), ]
irTable$ageOrder <- NULL
irTable$sexOrder <- NULL
irTable$sourceOrder <- NULL

# user inputs
methods <- c("sensSpec", "ppvNpv", "sensPpv", "fpRate")
databases <- unique(irTable$source)
ages <- unique(irTable$age)
sexes <- c("Male/Female", "Male", "Female")
outcomes <- unique(irTable$oName)
targets <- unique(irTable$tName)
strata <- unique(irTable$stratum)


# StrataOrder <- c("Male/Female 0 - 85+", "Male/Female <5", "Male/Female 5 - 17", "Male/Female 18 - 34", "Male/Female 35 - 54", "Male/Female 55 - 64", "Male/Female 65 - 74", "Male/Female 75 - 84", "Male/Female >=85",
#                  "Female 0 - 85+", "Female <5", "Female 5 - 17", "Female 18 - 34", "Female 35 - 54", "Female 55 - 64", "Female 65 - 74", "Female 75 - 84", "Female >=85",
#                  "Male 0 - 85+", "Male <5", "Male 5 - 17", "Male 18 - 34", "Male 35 - 54", "Male 55 - 64", "Male 65 - 74", "Male 75 - 84", "Male >=85")
