library(shiny)
library(fresh)
library(tidyverse)
library(shinyDataFilter)
library(DT)

hmda_data <- readRDS("data/HMDA_2020_WA_data.rds") %>%
  select(activity_year,
         lender,
         lei,
         loan_type,
         loan_amount,
         loan_term,
         purchaser_type,
         derived_dwelling_category,
         derived_race,
         derived_ethnicity,
         derived_sex,
         applicant_age,
         action_taken,
         `denial_reason-1`,
         `denial_reason-2`,
         `denial_reason-3`)

hmda_data$activity_year <- as_factor(hmda_data$activity_year)
hmda_data$derived_race <- as_factor(hmda_data$derived_race)
hmda_data$derived_dwelling_category <- as_factor(hmda_data$derived_dwelling_category)
hmda_data$derived_ethnicity <- as_factor(hmda_data$derived_ethnicity)
hmda_data$derived_sex <- as_factor(hmda_data$derived_sex)
hmda_data$lei <- as_factor(hmda_data$lei)
hmda_data$lender <- as_factor(hmda_data$lender)
hmda_data$loan_term <- as_factor(hmda_data$loan_term)

attr(hmda_data$action_taken, "label") <- "The action taken on the covered loan or application"
attr(hmda_data$activity_year, "label") <- "The calendar year the data submission covers"
attr(hmda_data$applicant_age, "label") <- "The age, in years, of the applicant or borrower"
attr(hmda_data$`denial_reason-1`, "label") <- "The principal reason, or reasons, for denial"
attr(hmda_data$`denial_reason-2`, "label") <- "The principal reason, or reasons, for denial"
attr(hmda_data$`denial_reason-3`, "label") <- "The principal reason, or reasons, for denial"
attr(hmda_data$derived_dwelling_category, "label") <- "Derived dwelling type from Construction Method and Total Units fields for easier querying of specific records"
attr(hmda_data$derived_ethnicity, "label") <- "Single aggregated ethnicity categorization derived from applicant/borrower and co-applicant/co-borrower ethnicity fields"
attr(hmda_data$derived_race, "label") <- "Single aggregated race categorization derived from applicant/borrower and co-applicant/co-borrower race fields"
attr(hmda_data$derived_sex, "label") <- "Single aggregated sex categorization derived from applicant/borrower and co-applicant/co-borrower sex fields"
attr(hmda_data$lei, "label") <- "A financial institution’s Legal Entity Identifier"
attr(hmda_data$lender, "label") <- "A financial institution’s name"
attr(hmda_data$loan_amount, "label") <- "The amount of the covered loan, or the amount applied for"
attr(hmda_data$loan_term, "label") <- "The number of months after which the legal obligation will mature or terminate, or would have matured or terminated"
attr(hmda_data$loan_type, "label") <- "The type of covered loan or application"
attr(hmda_data$purchaser_type, "label") <- "Type of entity purchasing a covered loan from the institution"


colnames(hmda_data) <- c("Activity Year",
                         "Lender Name",
                         "LEI",
                         "Loan Type",
                         "Loan Amount",
                         "Loan Term",
                         "Purchaser Type",
                         "Derived Dwelling Category",
                         "Derived Race",
                         "Derived Ethnicity",
                         "Derived Sex",
                         "Applicant Age",
                         "Action Taken",
                         "Denial Reason #1",
                         "Denial Reason #2",
                         "Denial Reason #3")