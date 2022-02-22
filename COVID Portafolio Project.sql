SELECT *
FROM PortafolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortafolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortafolioProject..CovidDeaths
Where location like '%mexico%'
and continent is not null
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what porcentage of population got Covid in your country
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortafolioProject..CovidDeaths
Where location like '%mexico%'
and continent is not null
Order by 1,2

-- Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
From PortafolioProject..CovidDeaths
Where continent is not null
Group By location, population
Order By PercentPopulationInfected DESC

-- Showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortafolioProject..CovidDeaths
Where continent is not null
Group By location
Order By TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortafolioProject..CovidDeaths
Where continent is null and location != 'Upper middle income' and location != 'High income' and location != 'Lower middle income'
	and location != 'Low income' and location != 'International' and location != 'European Union' and location != 'World'
Group By location
Order By TotalDeathCount DESC

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortafolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2

-- by day
Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortafolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortafolioProject..CovidDeaths as dea
Join PortafolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortafolioProject..CovidDeaths as dea
Join PortafolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select location, MAX((RollingPeopleVaccinated/population)*100) as PeopleVaccinated
From PopvsVac
Where continent is not null
Group by location
Order by PeopleVaccinated desc


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations bigint,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortafolioProject..CovidDeaths as dea
Join PortafolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select location, MAX((RollingPeopleVaccinated/population)*100) as PeopleVaccinated
From #PercentPopulationVaccinated
Where continent is not null
Group by location
Order by PeopleVaccinated desc


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortafolioProject..CovidDeaths as dea
Join PortafolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null