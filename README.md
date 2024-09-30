# COVID-19 Data Exploration and Dashboarding Project

This project focuses on the exploration and visualization of COVID-19 data using SQL and Power BI. 

## Dataset
Data is sourced from [Our World in Data (OWID)](https://github.com/owid/covid-19-data/tree/master/public/data). It is composed of four tables:

- data_case_death.csv: COVID-19 case and death counts
- data_vaccine.csv: Vaccination data
- data_hosp_icu.csv: Hospitalization and ICU admissions
- data_location.csv: data for different regions

## Cloud and Local Architecture

### 1. Data Extraction and Storage
   
Data was extracted from public links available on the [OWID](https://github.com/owid/covid-19-data/tree/master/public/data) GitHub repository. It was ingested and stored in Azure Data Lake Storage (ADLS) using Azure Data Factory for cloud computing. A local copy of the data was also saved for on-premises use.

### 2. Database Setup and SQL Queries

**Azure SQL Database:** An Azure SQL server is created to store and query the data. The Azure Data Factory pipeline was used to copy data from the data lake into the SQL database.

**Query Execution:**
Queries were run in the cloud using Azure Data Studio. The SQL scripts can be found in SQL-Queries in Azure Data Studio.sql. Queries were also executed locally using MySQL Workbench. The relevant scripts are available in SQL-Queries in MySQL Workbench.sql.

### 3. Dashboarding

The Power BI integrated within Azure is used to visualize the data by connecting directly to the Azure SQL server. Additionally, the dashboard is created locally using Power BI Desktop running on VMware on my Mac. 
