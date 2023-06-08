SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4 

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4 

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2

-- Looking at the toatal cases vs the total deaths
-- Shows the likelihood of dying if you contract covid in your country

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases Float;


ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths Float;


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'Death Percentage'
FROM PortfolioProject..CovidDeaths
WHERE location like '%Kingdom%'
and continent is not null
ORDER BY 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'Death Percentage'
FROM PortfolioProject..CovidDeaths
WHERE location like '%ireland%' 
and continent is not null
ORDER BY 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'Death Percentage'
FROM PortfolioProject..CovidDeaths
WHERE location like '%south korea%' 
and continent is not null
ORDER BY 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'Death Percentage'
FROM PortfolioProject..CovidDeaths
WHERE location like '%australia%' 
and continent is not null
ORDER BY 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'Death Percentage'
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' 
and continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- displays the percentage of the population that contracted covid

Select Location, date, population, total_cases, (total_cases/population)*100 AS 'Infected Percentage'
FROM PortfolioProject..CovidDeaths
WHERE location like '%kingdom%' 
and continent is not null
ORDER BY 1,2

-- Looking at countries with the highest infection rate compared to population

Select Location, population, MAX(total_cases) AS 'Highest Infection Count', MAX((total_cases/population))*100 AS 'Infected Percentage'
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%' 
where continent is not null
GROUP BY Location, population
ORDER BY 'Infected Percentage' desc


-- Showing countries with the highest death count per population


Select Location, MAX(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%' 
where continent is not null
GROUP BY Location, population
ORDER BY totaldeathcount desc


-- Let's break things down by continent


--This query has more accurate numbers for the death toll within eact continent (e.g. including canada to north america)
Select location, MAX(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%' 
where continent is null
GROUP BY location
ORDER BY totaldeathcount desc

-- Showing continent's with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%' 
where continent is not null
GROUP BY continent
ORDER BY totaldeathcount desc

-- Global Numbers

SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;
Select date, SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths, SUM(new_deaths)/SUM(new_cases) * 100 AS 'Death Percentage'
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kingdom%'
where continent is not null
group by date
ORDER BY 1,2


--total cases

--SET ARITHABORT OFF;
--SET ANSI_WARNINGS OFF;
Select SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths, SUM(new_deaths)/SUM(new_cases) * 100 AS 'Death Percentage'
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kingdom%'
where continent is not null
--group by date
ORDER BY 1,2

-- Looking at the Total Population vs Vaccination


-- Use CTE as we want to use the created column for a arithmetic function


with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as percentagevaccinated
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
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 
SELECT *, (RollingPeopleVaccinated/Population)*100 as percentagevaccinated
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualisation

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

SELECT * 
FROM PercentPopulationVaccinated