Select *
From PortofolioProject..CovidDeaths
Order by 3,4


--Select *
--From PortofolioProject..CovidDeaths
--Order by 3,4

-- Select the Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at Total Cases vs Total Deaths in the United States of America
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2


-- Looking at Total Cases vs Total Deaths in Cote d'Ivoire
-- Shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where location like '%ivoire%'
Order by 1,2



-- Looking at Total Cases vs Population in the United States of America
-- Shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From PortofolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2


-- Looking at Total Cases vs Population 
-- Shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortofolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at Countries with Highest Infectoin Rate compared to Population 

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortofolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortofolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- Let's break things down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortofolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- Let's break things down by continent with continent null

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortofolioProject..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc


-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortofolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc 



-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage 
From PortofolioProject..CovidDeaths
Where continent is not null
-- Group by continent
Order by 1,2 


--Join tables 
select *
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =  vac.date


	--Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =  vac.date
Where dea.continent is not null
order by 1,2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100 
 from PortofolioProject..CovidDeaths dea 
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =  vac.date
Where dea.continent is not null
order by 2,3

-- Use CTE
With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100 
 from PortofolioProject..CovidDeaths dea 
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =  vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100   
from PopVsVac



-- Create Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100 
 from PortofolioProject..CovidDeaths dea 
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =  vac.date
-- Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100   
from #PercentPopulationVaccinated


-- Creating View toStore data for later visualisations

Create View PercentPopulationVaccinated1 as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100 
 from PortofolioProject..CovidDeaths dea 
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =  vac.date
Where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated1

Create View CovidDeaths as 
Select *
From PortofolioProject..CovidDeaths
--Order by 3,4

Create View CovidVaccinations as
Select *
From PortofolioProject..CovidVaccinations

Create View CovidDeaths_DataUsed as
Select location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
Where continent is not null


Create View DeathPercentage as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where continent is not null


Create View DeathPercentageUSA as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2



Create View DeathPercentageCoteDIvoire as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where location like '%ivoire%'
Order by 1,2



Create View CasesPercentageUSA as
Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From PortofolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2



Create View PercentPopulationInfected as
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortofolioProject..CovidDeaths
Where continent is not null
Order by 1,2



Create View PercentPopulationInfectedMax as
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortofolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc


Create View TotalDeathCount as
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortofolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc



Create View TotalDeathCountContinent as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortofolioProject..CovidDeaths
Where continent is not null
Group by continent
--Order by TotalDeathCount desc


Create View Join as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =  vac.date
Where dea.continent is not null

select *
from DeathPercentageCoteDIvoire