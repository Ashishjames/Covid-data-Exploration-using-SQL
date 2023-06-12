--SELECT *
--FROM PortfolioProject..coviddeaths

--SELECT *
--FROM PortfolioProject..covidvaccinations


-- Data to work with

SELECT location, date, total_cases, total_deaths, population
FROM PortfolioProject..coviddeaths
ORDER BY 1,2


-- Total Deaths vs Total Cases
-- Shows likelihood of Dying if you contract covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..coviddeaths
ORDER BY 1,2


-- Shows likelihood of Dying if you contract covid in you're country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE location LIKE '%India%'
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population got covid


SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Looking at Countries With Highest Infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..coviddeaths
-- WHERE location LIKE '%state%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..coviddeaths
-- WHERE location LIKE '%state%'
WHERE continent IS NOT NULL											
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Continents With Highest Death Count
-- Continent with the Highest Death Count Per Population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..coviddeaths
-- WHERE location LIKE '%state%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL 
-- WHERE location LIKE '%India%'
GROUP BY date
HAVING SUM(new_cases) <> 0 
ORDER BY 1,2


SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL 
-- WHERE location LIKE '%India%'
HAVING SUM(new_cases) <> 0 
ORDER BY 1,2



-- Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RolllingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL   
ORDER BY 2,3


-- USE CTE

WITH PopvsVac( Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RolllingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL   
-- ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentagePopulationVaccinated
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RolllingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL   
ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentagePopulationVaccinated
FROM #PercentPopulationVaccinated


-- Creating View to Store Data for later Visualizations

CREATE View PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RolllingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL   
-- ORDER BY 2,3

SELECT *
FROM PercentagePopulationVaccinated