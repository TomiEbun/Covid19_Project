----QUERIES FOR TABLEAU VISUALIZATION- BY OLUWATOMISIN AROKODARE 06/30/2023

-----1 Percentage_of_Population_Vaccinated
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

----2 Global Numbers of Death Percentage 
Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
order by 1,2;


----3 Location_with_the_highest_Death_Count
SELECT location, SUM(cast(new_deaths as int)) as Total_Death_Count
FROM CovidDeaths
WHERE continent is null 
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY Total_Death_Count DESC;


-----4 Country with the highest infection count AS
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(cast(total_cases as decimal)/population) * 100 AS PercentPopulationInfected 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY  PercentPopulationInfected DESC;

---5  Country with highest infection count with date AS
SELECT Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected desc

---6 Total Caese vs Total Death In the United States 
SELECT Location,date,total_cases,total_deaths, (cast(total_deaths as decimal))/(cast(total_cases as decimal))*100 AS Death_Percentage
FROM CovidDeaths
WHERE Location LIKE '%states'
AND continent IS NOT NULL
ORDER BY 1, 2;




