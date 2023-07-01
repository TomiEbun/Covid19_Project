----QUERIES FOR VISUALIZATION USING POWERBI- BY OLUWATOMISIN AROKODARE 

---1 How many continents does the analysis cover? ----There are 6 continents 
SELECT count(distinct(continent)) Total_Continents  
FROM CovidProject..CovidDeaths

-- 2 How many countries does the analysis cover? ----- There are 243 reported countries 
SELECT count(distinct(location)) Total_Countries
FROM CovidProject..CovidDeaths
WHERE continent is not NULL;

------ 3. What was the most recent day of this data collection? ---28th June 2023
SELECT top 1 date, new_cases
FROM CovidProject..CovidDeaths
ORDER BY date DESC;

------- 4.Which day had the highest death record globally ? -----   24th January 2021
SELECT top 1 date, max((new_deaths)) Highest_death_by_day
FROM CovidProject..CovidDeaths
GROUP BY date
ORDER BY  Highest_death_by_day DESC;

----5. Which day had the highest case record globally ?    ---- 30th January 2022
SELECT top 1 date, max((new_cases)) Highest_case_by_count
FROM CovidProject..CovidDeaths
GROUP BY date
ORDER BY  Highest_case_by_count DESC;

------- 6. What are the top 10 countries with highest cases?
SELECT top 10 continent, location, sum(new_cases) Total_cases
FROM CovidProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, continent
ORDER BY Total_cases DESC;

------- 7. What are the top 10 countries with highest death counts?
SELECT top 10 continent, location, SUM(CAST( total_deaths AS INT)) Total_deaths
FROM CovidProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, continent
ORDER BY Total_deaths DESC;

----8 What are the total deaths by continent
SELECT continent, SUM(new_deaths) as Total_deaths
FROM CovidProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY Total_deaths DESC;


--- 9 What are the total cases per continent ? 
SELECT continent, SUM(new_cases) as Total_cases
FROM CovidProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY Total_cases DESC;

---10 Global Numbers-(Death Percentage)
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS Death_Percentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--DEFINING METRICS  
--Infection_rate = total_cases / population . Shows likelihood of getting infected per population */
-- 11. Which countries had the highest infection rate ? 
SELECT top 10 location,population,sum(new_deaths) TotalDeaths, sum(new_cases) Total_cases , round((sum(new_cases)/ population)*100,2) Infection_rate 
FROM CovidProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location,population
ORDER BY Infection_rate DESC;

-- 12. Which countries have highest death to case ratio ?
--Death_to_case ratio = total_deaths/ new_cases . Shows percentage of actually dying from covid after contracting it 
SELECT location, sum(new_deaths) Total_deaths, sum(new_cases) Total_cases, round((sum(new_deaths)/ max(total_cases))*100,2) Death_rate_Ratio 
FROM CovidProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location,population
ORDER BY Death_rate_Ratio desc;

--Death_rate = total_deaths / population . Shows likelihood of dying from covid per population
-- 13. Which countries have highest death rate? 
SELECT top 10 location, SUM(CAST(total_deaths AS INT)) Total_deaths,population,  round((SUM(CAST(total_deaths AS INT))/ population)*100,2) Mortality_rate 
FROM CovidProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location,population
ORDER BY Mortality_rate desc;

----14. What are the top countries with highest vaccination count?
SELECT location, SUM(CAST(total_vaccinations AS BIGINT)) Totalvaccinations, SUM(CAST (people_vaccinated AS BIGINT)) People_vaccinated
FROM CovidProject..CovidVaccinations
WHERE continent is not NULL
GROUP BY location
ORDER BY People_vaccinated DESC; 


-- 15. What percentage of global population was infected ,and died ? 
SELECT SUM(CAST(total_deaths AS BIGINT)) Total_deaths,SUM(CAST(total_cases AS BIGINT)) Total_cases, 
	  round(SUM(CAST(total_cases/population AS BIGINT))*100,2) Globalinfectionrate
FROM CovidProject..CovidDeaths


-----DRILLING DOWN TO UNITED STATES 
-------16 .Death Percentage in the United States 
SELECT Location,date,total_cases,total_deaths, (cast(total_deaths as decimal))/(cast(total_cases as decimal))*100 AS Death_Percentage
FROM CovidProject..CovidDeaths
WHERE Location LIKE '%states'
AND continent IS NOT NULL
ORDER BY 1, 2;


---17. Percentage_of_Population_Vaccinated in the United States using CTE
WITH PopvsVac (Continent, Location, Population, Date, new_vaccination, Rolling_People_Vaccinated)
AS
(
SELECT death.continent, death.location, death.population,death.date, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS bigint)) 
OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_People_Vaccinated
FROM CovidProject.. CovidDeaths death
JOIN CovidProject..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE vac.location LIKE '%states'
AND death.continent IS NOT NULL
)
SELECT *,(Rolling_People_Vaccinated/Population) * 100 AS Percentage_of_People_Vaccinated
FROM PopvsVac;
