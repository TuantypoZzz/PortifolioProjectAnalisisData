Select *
From PortofolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortofolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
Where continent is not null
Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contact covid by location country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPersentage
From PortofolioProject..CovidDeaths
Where location like 'Indonesia'
and continent is not null
Order By 1,2

-- looking at Total Cases vs population
-- Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as CasePopulationPersentage
From PortofolioProject..CovidDeaths
Where location like 'Indonesia'
Order By 1,2

--Looking at countries with highest Infection rate compare to Population
Select Location, MAX(total_cases) as HightInfectionCount, population, MAX((total_cases/population))*100 as PersentPopulationInfected
From PortofolioProject..CovidDeaths
--Where location like 'Indonesia'
Group by Location,population
Order By PersentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
--Where location like 'Indonesia'
Where continent is not null
Group by Location
Order By TotalDeathCount desc

-- BREAKDOWN BY CONTINENT

-- Showing contintents with the hightest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
--Where location like 'Indonesia'
Where continent is not null
Group by continent
Order By TotalDeathCount desc

--Global Numbers
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPersentage
From PortofolioProject..CovidDeaths
--Where location like 'Indonesia'
where continent is not null
--group by date
Order By 1,2

Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100

From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like 'albania'
Order By 2,3 

-- use CTE

With PopulationvsVaccinated (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100

From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.location like 'albania'
--Order By 2,3 
)
Select *, (RollingPeopleVaccinated/population)*100 as PercenPeopleVccinated
From PopulationvsVaccinated


-- Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.location like 'Indonesia'
--Order By 2,3 
Select *, (RollingPeopleVaccinated/population)*100 as PercenPeopleVccinated
From #PercentPopulationVaccinated



-- Creating View to store data for later visualization
Create View PercentPopulationVaccinated as
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like 'Indonesia'
--Order By 2,3 

Select * 
From PercentPopulationVaccinated