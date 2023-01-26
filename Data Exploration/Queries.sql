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
SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM covid_deaths
WHERE continent IS NOT NULL
--WHERE location = 'United States'
ORDER BY 1,2;

--total pop vs vaccination
-- shows percentage of population that has received atleast one covid vaccine
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
SUM(CAST(vax.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM covid_deaths death
JOIN covid_vaccinations vax
	ON death.location = vax.location
	AND death.date = vax.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE
-- calc on partition in previous query
WITH PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) AS
(
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
SUM(CAST(vax.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM covid_deaths death
JOIN covid_vaccinations vax
	ON death.location = vax.location
	AND death.date = vax.date
WHERE death.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccvsPop
FROM PopvsVac;

-- using temp table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date timestamp,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);


INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date;
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

