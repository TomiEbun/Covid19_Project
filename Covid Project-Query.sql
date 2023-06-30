-- ANALYSIS OF COVID DATA FROM 3rd January, 2020 t0 28th June ,2023	
------BY OLUWATOMISIN AROKODARE 06/30/2023

SELECT *
FROM CovidProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

----- THIS IS THE DATA WE ARE GOING TO BE STARTING WITH
SELECT Location,date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

------ TOTAL CASES VS TOTAL DEATHS
--This shows the likelihood of dying if you contact covid in your country
SELECT Location,date,total_cases,total_deaths, (cast(total_deaths as decimal))/(cast(total_cases as decimal))*100 AS Death_Percentage
FROM CovidDeaths
WHERE Location LIKE '%states'
AND continent IS NOT NULL
ORDER BY 1, 2;

SELECT Location,date,total_cases,total_deaths, (cast(total_deaths as decimal))/(cast(total_cases as decimal))*100 AS Death_Percentage
FROM CovidDeaths
WHERE Location LIKE '%Nigeria%'
AND continent IS NOT NULL
ORDER BY 1, 2;

SELECT Location,date,total_cases,total_deaths, (cast(total_deaths as decimal))/(cast(total_cases as decimal))*100 AS Death_Percentage
FROM CovidDeaths
WHERE Location LIKE '%Kingdom%'
AND continent IS NOT NULL
ORDER BY 1, 2;

----COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(cast(total_cases as decimal)/population) * 100 AS PercentPopulationInfected 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY  PercentPopulationInfected DESC;

----CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION (BREAKING IT DOWN BY CONTINENT)
--We use where continent is null because if you check the excel sheet, the locations has the names of the continent in them, instead of the names of the countries.
--This method gives you the accurate result if you want to break it down by continent
----SHOWING LOCATION WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT location, SUM(cast(new_deaths as int)) as Total_Death_Count
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY Location
ORDER BY Total_Death_Count DESC;

--SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION
-----However, we will use this for visualization purposes in order to drill down
SELECT continent, SUM(cast(new_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;

---GLOBAL NUMBERS(Calculation across the entire world)
SELECT Date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Date
ORDER BY 1, 2;

Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- ASSESSING VACCINATION DATA
SELECT *
FROM CovidVaccinations;

-- JOINING THE TWO TABLES TOGETHER FOR VIEWING(COVIDDEATH AND COVIDVACCINATIONS)
SELECT * 
FROM CovidDeaths death
JOIN CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date;

----TOTAL POPULATION VS VACCINATIONS
------ Showing Percentage of Population that has recieved at least one Covid Vaccine
SELECT death.continent, death.location, death.population,death.date, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) 
OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_People_Vaccinated
FROM  CovidDeaths death
JOIN CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3;


-- Getting the percentage of RollingPeopleVaccinated for each location
-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (Continent, Location, Population, Date, new_vaccination, Rolling_People_Vaccinated)
AS
(
SELECT death.continent, death.location, death.population,death.date, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS bigint)) 
OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_People_Vaccinated
FROM  CovidDeaths death
JOIN CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(Rolling_People_Vaccinated/Population) * 100 AS Percentage_of_People_Vaccinated
FROM PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS  #Percentage_of_Population_Vaccinated
CREATE TABLE #Percentage_of_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
Date datetime,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #Percentage_of_Population_Vaccinated
SELECT death.continent, death.location, death.population,death.date, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS bigint)) 
OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_People_Vaccinated
FROM  CovidDeaths death
JOIN CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date

SELECT *,(Rolling_People_Vaccinated/Population) * 100 AS Percentage_of_Population_Vaccinated
FROM #Percentage_of_Population_Vaccinated;


-- CREATING VIEWS TO STORE DATA FOR DATA VISUALIZATION-IN TABLEAU
----1 
CREATE VIEW  Percentage_of_Population_Vaccinated AS 
WITH PopvsVac (Continent, Location, Population, Date, new_vaccination, Rolling_People_Vaccinated)
AS
(
SELECT death.continent, death.location, death.population,death.date, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS bigint)) 
OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_People_Vaccinated
FROM  CovidDeaths death
JOIN CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL
)

SELECT *,(Rolling_People_Vaccinated/Population) * 100 AS Percentage_of_People_Vaccinated
FROM PopvsVac;

----2
CREATE VIEW  globalNumbers AS 
Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL

----3
CREATE VIEW Location_with_the_highest_Death_Count AS
SELECT location, SUM(cast(new_deaths as int)) as Total_Death_Count
FROM CovidDeaths
WHERE continent is null 
AND location not in ('World', 'European Union', 'International')
Group by location
--order by Total_Death_Count desc