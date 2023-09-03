Select * 
From PorfolioProjects..[Covid Deaths]
Order by 3,4

--Select * 
--From PorfolioProjects..[Covid Vaccinations]
--Order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases,	new_cases, total_deaths, population
From PorfolioProjects..[Covid Deaths]
Where continent is not null
order by 1,2

--Looking at the Total Cases vs Total Deaths 

Select location, date, total_cases, total_deaths, 
(convert(float,total_deaths)/nullif(CONVERT(float,total_cases),0))*100 as DeathPercentage
From PorfolioProjects..[Covid Deaths]
Where continent is not null
--Where location like '%state%'
order by 1,2


-- Total Cases vs Population
-- Show what percentage of population got covid

Select location, date, population, total_cases,  
(convert(float,total_cases)/nullif(CONVERT(float,population),0))*100 as PercentPopulationInfected
From PorfolioProjects..[Covid Deaths]
Where continent is not null
--Where location like '%state%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount,  
Max((convert(float,total_cases)/nullif(CONVERT(float,population),0)))*100 as PercentPopulationInfected
From PorfolioProjects..[Covid Deaths]
Where continent is not null
Group by location, population
--Where location like '%state%'
order by PercentPopulationInfected desc

-- Showing the Country with Highest Death Count per Population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProjects..[Covid Deaths]
Where continent is not null
Group by location 
 --Where location like '%state%'
order by TotalDeathCount desc

-- LET'S BREAK THIS DOWN BY COUNTINENT 

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProjects..[Covid Deaths]
Where continent is not null
Group by continent 
 --Where location like '%state%'
order by TotalDeathCount desc

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProjects..[Covid Deaths]
Where continent is null
Group by location 
 --Where location like '%state%'
order by TotalDeathCount desc



-- Showing the Continent with the Highest Death Counts per Population


Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProjects..[Covid Deaths]
Where continent is not null
Group by continent 
 --Where location like '%state%'
order by TotalDeathCount desc

--Global Numbers 

Select Sum(new_cases) as Total_cases, Sum(new_deaths) as Total_deaths, Sum(new_deaths)/Nullif(Sum(new_cases),0)*100 as DeathPercentage--(convert(float,total_deaths)/nullif(CONVERT(float,total_cases),0))*100 as DeathPercentage
From PorfolioProjects..[Covid Deaths]
Where continent is not null
--Where location like '%state%'
--group by date
order by 1,2


-- Total Populaltion vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
From PorfolioProjects..[Covid Deaths] dea
Join PorfolioProjects..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null 
Order by 2,3

-- Add up with Partition 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
From PorfolioProjects..[Covid Deaths] dea
Join PorfolioProjects..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null 
Order by 2,3



-- USE CTE	


With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)

as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PorfolioProjects..[Covid Deaths] dea
Join PorfolioProjects..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null 
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PorfolioProjects..[Covid Deaths] dea
Join PorfolioProjects..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null 
--Order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating view to store data for later visualization 

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PorfolioProjects..[Covid Deaths] dea
Join PorfolioProjects..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null 
--Order by 2,3

Select *
From PercentPopulationVaccinated

Drop view PercentPopulationVaccinated

