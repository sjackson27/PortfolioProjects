
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

Select Location, date,total_cases,total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date,population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX (total_cases) as HighestInfectionCount, MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Group by location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(CONVERT(float, Total_deaths))*100 AS TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT



-- Showing continents with the highest death count per population

Select continent, MAX(CONVERT(float, Total_deaths))*100 AS TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date,SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(CONVERT(float, new_deaths) / NULLIF(CONVERT(float, new_cases), 0))*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group By date
order by 1,2

-- Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3

USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From Popvsvac

-- TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated
