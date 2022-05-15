SELECT   *
FROM     portfolio.dbo.coviddeaths
ORDER BY 3,
         4
--Select data to use for this project from CovidDeathsSELECT   location,
         date,
         total_cases,
         new_cases,
         total_deaths,
         population
FROM     portfolio.dbo.coviddeaths
ORDER BY 1,
         2
-- Total cases vs Total Deaths
-- Death percentageSELECT   location,
         date,
         total_cases,
         total_deaths,
         Round((total_deaths/total_cases)*100,2) AS DeathPercent
FROM     portfolio.dbo.coviddeaths
ORDER BY 1,
         2
-- Total cases vs Total Deaths percentage in GhanaSELECT   location,
         date,
         total_cases,
         total_deaths,
         Round((total_deaths/total_cases)*100,2) AS DeathPercent
FROM     portfolio.dbo.coviddeaths
WHERE    location = 'Ghana'
ORDER BY 1,
         2
-- Total cases vs population (% of population with COVID)SELECT   location,
         date,
         total_cases,
         population,
         Round((total_cases/population)*100,2) AS DeathPercent
FROM     portfolio.dbo.coviddeaths
         --WHERE location = 'Ghana'
ORDER BY 1,
         2
-- Total cases vs population (% of population with COVID) in the USSELECT   location,
         date,
         total_cases,
         population,
         Round((total_cases/population)*100,2) AS PercentInfected
FROM     portfolio.dbo.coviddeaths
WHERE    location LIKE '%states%'
ORDER BY 1,
         2
-- Countries with highest infection rates compared to populationSELECT   location,
         Max(total_cases) AS HighestInfections,
         population,
         Max(Round((total_cases/population)*100,2)) AS PercentInfected
FROM     portfolio.dbo.coviddeaths
         --WHERE location LIKE '%states%'
GROUP BY location,
         population
ORDER BY percentinfected DESC
-- Total number of deaths in various countriesSELECT   location,
         Max(Cast(total_deaths AS INT)) AS 'TotalDeaths'
FROM     portfolio.dbo.coviddeaths
WHERE    continent IS NOT NULL
GROUP BY location,
         population
ORDER BY totaldeaths DESC
-- Analysis using continentsSELECT   location,
         Max(Cast(total_deaths AS INT)) AS 'TotalDeaths'
FROM     portfolio.dbo.coviddeaths
WHERE    continent IS NULL
GROUP BY location
ORDER BY totaldeaths DESC
-- Using continents with highest death per populationSELECT   continent,
         Max(Cast(total_deaths AS INT)) AS 'TotalDeaths'
FROM     portfolio.dbo.coviddeaths
WHERE    continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeaths DESC
-- Selecting all data from both tables using joins from two columns within the tablesSELECT *
FROM   portfolio.dbo.covidvacinations vac
JOIN   portfolio.dbo.coviddeaths dea
ON     vac.location = dea.location
AND    vac.date = dea.date
-- Comparing total vaccinated people and total populationSELECT   dea.continent,
         dea.location,
         dea.date,
         dea.population,
         vac.new_vaccinations
FROM     portfolio.dbo.covidvacinations vac
JOIN     portfolio.dbo.coviddeaths dea
ON       vac.location = dea.location
AND      vac.date = dea.date
WHERE    dea.continent IS NOT NULL
ORDER BY 2,
         3
-- Finding the rolling count of new vaccinationsSELECT   dea.continent,
         dea.location,
         dea.date,
         dea.population,
         vac.new_vaccinations,
         Sum(Cast(vac.new_vaccinations AS BIGINT)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
FROM     portfolio.dbo.covidvacinations vac
JOIN     portfolio.dbo.coviddeaths dea
ON       vac.location = dea.location
AND      vac.date = dea.date
WHERE    dea.continent IS NOT NULL
ORDER BY 2,
         3
-- Using CTE allows you to use alias columns in your queries
with popvsvac
      (
            continent,
            location,
            date,
            population,
            new_vaccinations,
            rollingpeoplevaccinated
      )
      AS
      (
               SELECT   dea.continent,
                        dea.location,
                        dea.date,
                        dea.population,
                        vac.new_vaccinations,
                        sum(cast(vac.new_vaccinations AS bigint)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
               FROM     portfolio.dbo.covidvacinations vac
               JOIN     portfolio.dbo.coviddeaths dea
               ON       vac.location = dea.location
               AND      vac.date = dea.date
               WHERE    dea.continent IS NOT NULL
      )SELECT *,
       (rollingpeoplevaccinated/population)*100 AS RollingPercentVaccinated
FROM   popvsvac