SELECT *
FROM Portfolio.dbo.CovidDeaths
ORDER By 3,4


--SELECT *
--FROM Portfolio.dbo.CovidVacinations
--ORDER By 3,4

--Select data to use for this project from CovidDeaths 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio.dbo.CovidDeaths
ORDER BY 1,2


-- Total cases vs Total Deaths
-- Death percentage
SELECT location, date, total_cases,  total_deaths, ROUND((total_deaths/total_cases)*100,2) AS DeathPercent
FROM Portfolio.dbo.CovidDeaths
ORDER BY 1,2

-- Total cases vs Total Deaths percentage in Ghana
SELECT location, date, total_cases,  total_deaths, ROUND((total_deaths/total_cases)*100,2) AS DeathPercent
FROM Portfolio.dbo.CovidDeaths
WHERE location = 'Ghana'
ORDER BY 1,2

-- Total cases vs population (% of population with COVID)
SELECT location, date, total_cases,  population, ROUND((total_cases/population)*100,2) AS DeathPercent
FROM Portfolio.dbo.CovidDeaths
--WHERE location = 'Ghana'
ORDER BY 1,2

-- Total cases vs population (% of population with COVID) in the US
SELECT location, date, total_cases,  population, ROUND((total_cases/population)*100,2) AS PercentInfected
FROM Portfolio.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Countries with highest infection rates compared to population
SELECT location, MAX(total_cases) AS HighestInfections,  population, MAX(ROUND((total_cases/population)*100,2)) AS PercentInfected
FROM Portfolio.dbo.CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentInfected DESC


-- Total number of deaths in various countries
SELECT location, MAX(CAST(total_deaths AS INT)) AS 'TotalDeaths'
FROM Portfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeaths DESC


-- Analysis using continents
SELECT location, MAX(CAST(total_deaths AS INT)) AS 'TotalDeaths'
FROM Portfolio.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeaths DESC

-- Using continents with highest death per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS 'TotalDeaths'
FROM Portfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC


-- Selecting all data from both tables using joins from two columns within the tables
SELECT *
FROM Portfolio.dbo.CovidVacinations vac
JOIN Portfolio.dbo.CovidDeaths dea
ON vac.location = dea.location
AND vac.date = dea.date



-- Comparing total vaccinated people and total population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portfolio.dbo.CovidVacinations vac
JOIN Portfolio.dbo.CovidDeaths dea
ON vac.location = dea.location
AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Finding the rolling count of new vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio.dbo.CovidVacinations vac
JOIN Portfolio.dbo.CovidDeaths dea
ON vac.location = dea.location
AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE allows you to use alias columns in your queries
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio.dbo.CovidVacinations vac
JOIN Portfolio.dbo.CovidDeaths dea
ON vac.location = dea.location
AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPercentVaccinated
FROM PopvsVac