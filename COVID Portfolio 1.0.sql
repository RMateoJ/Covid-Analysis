SELECT *
FROM PortfolioProject..['CovidDeaths']
WHERE continent is not NULL
ORDER BY 3,4 


--SELECT *
--FROM PortfolioProject..['CovidVaccinations']
--ORDER BY 3,4

-- Select data going to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['CovidDeaths']
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Displays likelihood of dying if contracted in country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..['CovidDeaths']
Where location like '%states%'
ORDER BY 1,2


-- Observe total cases vs population
-- Displays population % contracted COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..['CovidDeaths']
Where location like '%states%'
ORDER BY 1,2


--Look at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..['CovidDeaths']
--Where location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Displaying countries with higest death rates per population

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..['CovidDeaths']
--Where location like '%states%'
WHERE continent is not NULL	
GROUP BY location
ORDER BY TotalDeathCount desc


-- Breaking down by continent

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..['CovidDeaths']
--Where location like '%states%'
WHERE continent is NULL	
GROUP BY location
ORDER BY TotalDeathCount desc


-- Displaying continents with highest death count per population

SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..['CovidDeaths']
--Where location like '%states%'
WHERE continent is not NULL	
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global #'s

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..['CovidDeaths']
--Where location like '%states%'
where continent is not null
--GROUP BY date
ORDER BY 1,2


--Observing TotalPpopulation vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating view to store data for later visualizations 

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated