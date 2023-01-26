-- Select Data that will be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM "covid_deaths"
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, 
(CAST (total_deaths AS FLOAT)/ CAST (total_cases AS FLOAT))*100 as DeathPercentage
FROM "covid_deaths"
WHERE continent IS NOT NULL
--AND location = 'United States'
ORDER BY location, date;

-- Total Cases vs Population
-- Looking at percentage of pop that got covid
SELECT location, date, total_cases, population, 
(CAST (total_cases AS FLOAT)/ population)*100 as PercentagePopInfected
FROM "covid_deaths"
WHERE continent IS NOT NULL
--AND location = 'United States'
ORDER BY location, date;


-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  
MAX((CAST(total_cases AS FLOAT)/population))*100 AS PercentPopInfected
FROM covid_deaths
WHERE continent IS NOT NULL
--AND location = 'United States'
GROUP BY location, population
ORDER BY PercentPopInfected DESC;


-- Highest Death Count per Population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Highest Death Rate per Population
SELECT location, population, MAX(total_deaths) AS HighestDeathCount, 
MAX(CAST(total_deaths AS FLOAT)/population) *100 AS PercentPopDeath
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopDeath DESC;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
SUM(CAST(new_deaths AS Float))/SUM(new_cases)*100 AS DeathPercentage
FROM covid_deaths
WHERE continent IS NOT NULL
--WHERE location = 'United States'
ORDER BY 1,2;

--total pop vs vaccination
-- this query gets the total numbers of partial vaccinations and
-- full vaccinations and population
-- select distinct is used to get one number for total vaccinated from each location
SELECT DISTINCT ON (dea.location) dea.location, dea.continent, dea.date, dea.population
, vac.people_vaccinated AS PeopleVaccinated
, vac.people_fully_vaccinated as PeopleFullyVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.people_vaccinated IS NOT NULL
GROUP BY dea.location, dea.continent, dea.date, dea.population
, vac.people_vaccinated, vac.people_fully_vaccinated
ORDER BY dea.location, PeopleVaccinated DESC;


-- USE CTE to perform calc on previous query
-- getting percentage of people vaccinated and fully vaccinated
WITH PopvsVac (continent, location, date, population
			   , peoplevaccinated, peoplefullyvaccinated) AS
(
SELECT DISTINCT ON (dea.location) dea.location, dea.continent, dea.date, dea.population
, vac.people_vaccinated AS PeopleVaccinated, vac.people_fully_vaccinated as PeopleFullyVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.people_vaccinated IS NOT NULL
GROUP BY dea.location, dea.continent, dea.date, dea.population
, vac.people_vaccinated, vac.people_fully_vaccinated
ORDER BY dea.location, PeopleVaccinated DESC
)
SELECT *, (CAST(PeopleVaccinated AS FLOAT)/population)*100 AS PercentPopVaccinated
, (CAST(PeopleFullyVaccinated AS FLOAT)/population)*100 AS PercentPopFullyVaxed
FROM PopvsVac;

-- Practice using a temporary table to perform the same calculation 
-- as in the previous query
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date TIMESTAMP,
Population BIGINT,
PeopleVaccinated BIGINT,
PeopleFullyVaccinated BIGINT
);


INSERT INTO PercentPopulationVaccinated
SELECT DISTINCT ON (dea.location) dea.location, dea.continent, dea.date, dea.population
, vac.people_vaccinated AS PeopleVaccinated, vac.people_fully_vaccinated as PeopleFullyVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.people_vaccinated IS NOT NULL
GROUP BY dea.location, dea.continent, dea.date, dea.population
, vac.people_vaccinated, vac.people_fully_vaccinated
ORDER BY dea.location, PeopleVaccinated DESC;

SELECT *, (CAST(PeopleVaccinated AS FLOAT)/population)*100 AS PercentPopVaccinated
, (CAST(PeopleFullyVaccinated AS FLOAT)/population)*100 AS PercentPopFullyVaxed
FROM PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopVaccinated AS
SELECT DISTINCT ON (dea.location) dea.location, dea.continent, dea.date, dea.population
, vac.people_vaccinated AS PeopleVaccinated
, vac.people_fully_vaccinated AS PeopleFullyVaccinated
,(CAST(vac.people_vaccinated AS FLOAT)/population)*100 AS PercentPopVaccinated
, (CAST(vac.people_fully_vaccinated AS FLOAT)/population)*100 AS PercentPopFullyVaxed
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.people_vaccinated IS NOT NULL
GROUP BY dea.location, dea.continent, dea.date, dea.population
, vac.people_vaccinated, vac.people_fully_vaccinated
ORDER BY dea.location, PeopleVaccinated DESC;


--practice with partitions
-- same data as past few queries but using partition instead of SELECT DICSTINCT
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS PeopleVaccinated

FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY dea.location, PeopleVaccinated DESC;


-- cte
WITH PopvsVac (continent, location, date, population, peoplevaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS NumPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY dea.location, NumPeopleVaccinated DESC
)

SELECT *, (CAST(numpeoplevaccinated AS FLOAT)/population)*100 AS PercentPopVaccinated
FROM PopvsVac;
