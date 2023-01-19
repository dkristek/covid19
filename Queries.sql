-- Select Data that will be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM "covid_deaths"
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (CAST (total_deaths AS FLOAT)/ CAST (total_cases AS FLOAT))*100 as DeathPercentage
FROM "covid_deaths"
WHERE continent IS NOT NULL
--AND location = 'United States'
ORDER BY location, date;

-- Total Cases vs Population
-- Looking at percentage of pop that got covid
SELECT location, date, total_cases, population, (CAST (total_cases AS FLOAT)/ population)*100 as PercentagePopInfected
FROM "covid_deaths"
WHERE continent IS NOT NULL
--AND location = 'United States'
ORDER BY location, date;


-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((CAST(total_cases AS FLOAT)/population))*100 AS PercentPopInfected
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
SELECT location, population, MAX(total_deaths) AS HighestDeathCount, MAX(CAST(total_deaths AS FLOAT)/population) *100 AS PercentPopDeath
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopDeath DESC;

