-- With Tableau Public it is not possible to link to sql through Tableau
-- The queries below are used to generate the needed tables which are 
-- then copied into excel and loaded into Tableau

-- 1) Looking at the global total cases, deaths, and death percentage
-- summing new cases/deaths easier than summing total cases as there would be overlap
-- would have to select max total cases and then add
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
SUM(CAST(new_deaths AS FLOAT))/SUM(New_Cases)*100 AS DeathPercentage
FROM covid_deaths
WHERE continent IS NOT null 
ORDER BY 1,2;

-- 2) The below query will show total death count in all continents and in areas with differing levels of income
-- world, european union, and international are removed to do so without overlap between continents
-- European Union is part of Europe

SELECT location, SUM(new_deaths) AS TotalDeathCount
FROM covid_deaths
WHERE continent IS null 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;

 
-- 3) looking at population and infection count/percentage of each location in the original dataset
-- removed locations with no data for total cases and removed international as it has no population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
MAX((CAST(total_cases AS FLOAT)/population))*100 AS PercentPopInfected
FROM covid_deaths
WHERE total_cases IS NOT NULL 
AND NOT location = 'International'
GROUP BY location, population
ORDER BY PercentPopInfected DESC;


-- 4) Above query but with date
-- removed locations with no data for total cases and removed international as it has no population

SELECT DISTINCT ON (location) location, population, date, total_cases as HighestInfectionCount, 
MAX((CAST(total_cases AS FLOAT)/population))*100 AS PercentPopInfected
FROM covid_deaths
WHERE total_cases IS NOT NULL 
AND NOT location = 'International'
GROUP BY location, population, total_cases, date
ORDER BY location, total_cases DESC;

-- 5) Shows highest number of people vaccinated in each location
-- original data for this is not excellent
-- not every location has  a recent (january 2023 at time of writing) count
-- shows people with one vaccine shot and people with two or more (fully vaccinated)

SELECT DISTINCT ON (dea.location) dea.location, dea.continent, dea.date, dea.population
, vac.people_vaccinated AS PeopleVaccinated, vac.people_fully_vaccinated as PeopleFullyVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.people_vaccinated IS NOT NULL
GROUP BY dea.location, dea.continent, dea.date, dea.population, vac.people_vaccinated, vac.people_fully_vaccinated
ORDER BY dea.location, PeopleVaccinated DESC;


--6) percent pop vaccinated
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

