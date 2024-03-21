Select *
From [Portfolio project]..CovidDeaths
Order by 3,4

--Select *
--From [Portfolio project]..CovidVaccinations
--Order by 3,4

-- select data that will be used
Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio project]..CovidDeaths
where continent is not null
Order by 1,2

--Looking at Total cases vs Total death

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths
where location = 'sudan'
Order by 1,2

--Looking at Total cases vs Population
--Shows what percentage of people got covid
Select location, date, population,total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio project]..CovidDeaths
where location = 'sudan'
Order by 1,2

--Looking at countries with highest infection rate compared to population
Select location, population,MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio project]..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

-- Showing countries with highest death count per population
Select location,MAX(CAST(total_deaths as int)) as TotalDeathCount
From [Portfolio project]..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc

--Lets break things down by continent

--Showing continents with  the highest death count per population
Select continent,MAX(CAST(total_deaths as int)) as TotalDeathCount
From [Portfolio project]..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global numbers 
-- BY DAY
Select date, SUM(new_cases) as TotalCases,SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths
where continent is not null
Group by date
Order by 1,2

--TOTAL
Select SUM(new_cases) as TotalCases,SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths
where continent is not null
Order by 1,2



-- Looking at Total populations vs vaccination
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) OVER(partition by dea.location
Order by dea.location, dea.date) as RollinPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) OVER(partition by dea.location
Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) OVER(partition by dea.location
Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) OVER(partition by dea.location
Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *
From PercentPopulationVaccinated

