-- 1) Daily and Cumulative Infections and Deaths by Country in 2021
SELECT 
    location,
    date,
    new_cases AS new_infections,
    SUM(new_cases) OVER (PARTITION BY location ORDER BY location, date) AS tot_infections,
    new_deaths,
    SUM(new_deaths) OVER (PARTITION BY location ORDER BY location, date) AS tot_deaths
FROM covid.case_death
Where date BETWEEN '2021-01-01' AND '2022-01-01' 
ORDER BY location, date;


-- 2) Monthly Population Infection and Death Rates (per Million People) by Location
SELECT 
    location,
    EXTRACT(YEAR FROM date) AS year,
    EXTRACT(MONTH FROM date) AS month,
    SUM(new_cases/population * 1000000) AS population_infection_rate,
    SUM(new_deaths/population * 1000000) AS population_death_rate
FROM 
    covid.case_death
GROUP BY 
    location, year, month
ORDER BY 
    location, year, month;


-- 3) Top 10 Countries with the Highest Death Rates in 2021
SELECT 
	 location,
     SUM(new_deaths/population * 1000000)  AS population_death_rate
FROM covid.case_death 
Where date BETWEEN '2021-01-01' AND '2022-01-01' 
GROUP BY location
ORDER BY population_death_rate DESC
LIMIT 10; 


-- 4) Top 10 Countries with the Highest Total COVID-19 Cases in the First TWo Months of 2020
SELECT 
	 location,
     SUM(new_cases) AS tot_new_case
FROM covid.case_death 
WHERE date BETWEEN '2020-01-01' AND '2020-03-01'
GROUP BY location 
ORDER BY tot_new_case DESC
LIMIT 10; 
  
  
-- 5) Global Peak Month of New COVID-19 Cases 
 SELECT 
    EXTRACT(YEAR FROM date) AS year,
	EXTRACT(MONTH FROM date) AS month,
    SUM(new_cases) AS tot_new_case
FROM covid.case_death
GROUP BY year, month
ORDER BY tot_new_case DESC  
Limit 1;


-- 6) Peak Month of New COVID-19 Cases by Country
WITH ranked_inf_rate AS (
SELECT
     location,
     EXTRACT(YEAR FROM date) AS year,
     EXTRACT(MONTH FROM date) AS month,
     SUM(new_cases) AS tot_new_case,
     ROW_NUMBER() OVER (PARTITION BY location ORDER BY SUM(new_cases) DESC) AS inf_rank 
FROM covid.case_death
GROUP BY location, year, month     
)
SELECT location,
	   year,
       month,
       tot_new_case
FROM ranked_inf_rate       
WHERE inf_rank = 1;
  
  
-- 7) Daily and Cumulative Vaccinations by Location in July 2021
SELECT vac.location ,
		vac.date , 
        cd.population,
        vac.daily_people_vaccinated as daily_people_vaccinated,
        Sum(vac.daily_people_vaccinated) 
        OVER (PARTITION BY vac.location ORDER BY vac.location, vac.date)
        AS cumulative_people_vaccinated
FROM covid.vaccine as vac
JOIN covid.case_death as cd
ON vac.date = cd.date AND vac.location = cd.location
Where vac.date BETWEEN '2021-07-01' AND '2021-08-01'
ORDER BY 1, 2;


-- 8) Vaccination Progress: Daily, Cumulative, and Population Percentage by Country
WITH pop_vac(location, date, population, daily_vaccine, cumulative_vaccine)
AS (
SELECT  vac.location , 
		vac.date, 
        cd.population, 
        vac.daily_people_vaccinated,
		Sum(vac.daily_people_vaccinated) 
        OVER (PARTITION BY vac.location ORDER BY vac.location, vac.date)
FROM covid.vaccine as vac
JOIN covid.case_death as cd
ON vac.date = cd.date AND vac.location = cd.location
)
SELECT location, 
		date, 
        daily_vaccine,
        cumulative_vaccine,
		cumulative_vaccine/population * 100 AS population_vaccination_percentage
From pop_vac
Where date BETWEEN '2021-01-01' AND '2022-01-01'
ORDER BY 1, 2;


-- 9) Monthly Average Infection, Death, and Vaccination Rates (per Million People per Month) by Location
WITH idv_rates (location, year, month, monthly_infect , monthly_death , monthly_vaccine)
AS (
SELECT cd.location,
	EXTRACT(YEAR FROM cd.date),
    EXTRACT(MONTH FROM cd.date),
    SUM(cd.new_cases/cd.population * 1000000),
    SUM(cd.new_deaths/cd.population * 1000000),
    SUM(vac.daily_people_vaccinated/cd.population * 1000000)
FROM covid.case_death cd
LEFT JOIN covid.vaccine vac
ON cd.location = vac.location AND cd.date = vac.date
GROUP BY cd.location, EXTRACT(YEAR FROM cd.date), EXTRACT(MONTH FROM cd.date)
)
SELECT location,
	year,
    AVG(monthly_infect) AS infect_rate_avg,
    AVG(monthly_death) AS death_rate_avg,
    AVG(monthly_vaccine) AS vaccine_rate_avg
FROM idv_rates 
GROUP BY location, year
ORDER BY location, year;   


-- 10) Case Fatality, Hospitalization, and ICU Rates by Country in 2021
WITH CTE_SevereCase AS(
SELECT 
	   hi.location,
       hi.date,
       SUM(weekly_hosp_admissions/7) 
       OVER (PARTITION BY hi.location ORDER BY hi.location , hi.date)
       AS tot_hosp_adm,
	   SUM(hi.weekly_icu_admissions/7)
       OVER (PARTITION BY hi.location ORDER BY hi.location , hi.date)
       AS tot_icu_adm,
       SUM(cd.new_cases) 
       OVER (PARTITION BY cd.location ORDER BY cd.location , cd.date)
       AS tot_case,
       SUM(cd.new_deaths)
       OVER (PARTITION BY cd.location ORDER BY cd.location , cd.date)
       AS tot_death,
       cd.population
FROM covid.hosp_icu AS hi
JOIN covid.case_death AS cd
ON hi.location = cd.location AND hi.date = cd.date
WHERE hi.date BETWEEN '2021-01-01' AND '2022-01-01'
)
SELECT 
	  location,
      date,
	  CASE WHEN tot_case > 0 THEN (tot_death / tot_case) * 100 ELSE 0 END AS CFR, 
	  CASE WHEN tot_case > 0 THEN (tot_hosp_adm / tot_case) * 100 ELSE 0 END AS hosp_rate,
      CASE WHEN tot_case > 0 THEN (tot_icu_adm / tot_case) * 100 ELSE 0 END AS icu_rate
FROM CTE_SevereCase
ORDER BY 1, 2;  


-- 11) Infection, Death, and Vaccination Rates by Location and Date
DROP TABLE IF EXISTS CovidRates;
CREATE TEMPORARY TABLE CovidRates
(
    continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population numeric,
    pop_infect_rate decimal(18, 2),
    pop_death_rate decimal(18, 2),
    pop_vaccine_pct decimal(18, 2)
);
INSERT INTO CovidRates (continent, location, date, population, pop_infect_rate, pop_death_rate, pop_vaccine_pct)
SELECT cd.continent,
	   vac.location, 
       vac.date, 
       cd.population, 
       SUM(cd.new_cases)
       OVER (PARTITION BY cd.location ORDER BY cd.location , cd.date) / cd.population * 1000000,
       SUM(cd.new_deaths)
       OVER (PARTITION BY cd.location ORDER BY cd.location , cd.date) / cd.population * 1000000,
       SUM(vac.daily_people_vaccinated) 
       OVER (PARTITION BY vac.location ORDER BY vac.location, vac.date) / cd.population * 100 
FROM covid.case_death AS cd 
LEFT JOIN covid.vaccine AS vac
ON vac.date = cd.date AND vac.location = cd.location
ORDER BY vac.location, vac.date;

SELECT * FROM CovidRates
WHERE location = 'Canada' AND date BETWEEN '2021-08-01' AND '2021-09-01'  -- (for example)
ORDER BY location, date;

-- 12) Population Infection, Death, and Vaccination Rates by Continent
SELECT continent,
	   MAX(pop_infect_rate) AS population_infection_rate, 
       MAX(pop_death_rate) AS population_death_rate, 
       MAX(pop_vaccine_pct) AS population_vaccination_percentage
FROM CovidRates  
WHERE continent IS NOT NULL AND continent <> ''
GROUP BY continent; 

-- 13) Death and Vaccination Rates in Top 10 Countries with Highest Infection Rates
SELECT location,
	   MAX(pop_infect_rate) AS population_infection_rate,
       MAX(pop_death_rate) AS population_death_rate,
       MAX(pop_vaccine_pct) AS population_vaccination_percentage
FROM  CovidRates
GROUP BY location
ORDER BY population_infection_rate DESC
LIMIT 10;  

