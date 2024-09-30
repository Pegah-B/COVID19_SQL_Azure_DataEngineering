# COVID-19 Data Exploration and Dashboarding Project

This project focuses on the exploration and visualization of COVID-19 data using SQL and Power BI, conducted in both cloud and local environments. An ETL process was implemented, including extracting data from HTTP links and storing it in Azure Data Lake Storage. A SQL server was created in the cloud, utilizing Azure SQL Database for structured querying, and insights were visualized through an interactive dashboard created in Power BI.

## Dataset
Data is sourced from [Our World in Data (OWID) GitHub repository](https://github.com/owid/covid-19-data/tree/master/public/data). 

The data extraction and preprocessing resulted in four key tables:

- ``data_case_death.csv``: COVID-19 case and death counts
- ``data_vaccine.csv``: COVID-19 vaccination data
- ``data_hosp_icu.csv``: Hospitalization and ICU admissions
- ``data_location.csv``: Location information for COVID-19 data

## Cloud and Local Architecture

### 1. Data Extraction and Storage
   
Data was extracted from public links available on the OWID GitHub repository. It was ingested and stored in Azure Data Lake Storage (ADLS) using Azure Data Factory for cloud computing. A local copy of the data was also saved for on-premises use.

### 2. Database Setup and SQL Queries

**Azure SQL Database:** An Azure SQL server is created to store and query the data. The Azure Data Factory pipeline was used to copy data from Azure Data Lake Storage into the SQL database.

**Query Execution:**
Queries were run in the cloud using Azure Data Studio. The SQL scripts can be found in ``SQL-Queries in Azure Data Studio.sql``. Queries were also executed locally using MySQL Workbench. The relevant scripts are available in ``SQL-Queries in MySQL Workbench.sql``.

### 3. Dashboarding

An interactive dashboard ``Dashboard.pbix`` was developed to visualize key insights from the data. In the cloud setup, Power BI integrated within Azure was used to connect directly to the Azure SQL server. Additionally, a local version of the dashboard was developed using Power BI Desktop, running on VMware on my Mac. 
