select * from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3 asc , 4 asc

--select * from PortfolioProject.dbo.CovidVaccinations
--order by 3 asc , 4 asc

-- select data taht we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1 asc , 2 asc

-- Looking at total cases vs total deaths
-- Shows likelehood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where Location like '%united kingdom%'
and continent is not null
order by 1 asc , 2 asc

-- Looking at Total Cases vs Population
-- Shows what percentage of population have gotten covid / have reported (doesn't account for multiple reports?)
select Location, date, total_cases, Population, (total_cases/Population)*100 as PopulationInfectionPercentage
from PortfolioProject.dbo.CovidDeaths
where Location like '%united kingdom%'
and continent is not null
order by 1 asc , 2 asc

-- Looking at countries with highest infection rate compared to population
select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as TotalPercentOfPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by Location, population
order by TotalPercentOfPopulationInfected desc

-- Looking at countries with highest death count
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc


--CONTINENT VIEW

-- Looking at continents with highest death count
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

--
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by date
order by 1 asc , 2 asc
--
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1 asc , 2 asc


-- create CTE to do calcs on the aggregate function column
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as CumulativeVaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2 asc, 3 asc
)
Select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac

-- Using a TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as CumulativeVaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated


-- Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as CumulativeVaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated
