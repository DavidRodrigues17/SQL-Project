SELECT * 
FROM CovidProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4




SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidProject.dbo.CovidDeaths
ORDER bY 1,2

--- TOtal cases vs total deaths

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidProject.dbo.CovidDeaths
WHERE location = 'India'
ORDER bY 1,2

--- Total cases vs population

SELECT location,date,population,total_cases,(total_cases/population)*100 as InfectedPercentage
FROM CovidProject.dbo.CovidDeaths
WHERE location = 'India'
ORDER bY 1,2


--- Countries with highest infection

SELECT location,population,MAX(total_cases)AS HighestINfectionCount,MAX((total_cases/population))*100 as InfectedPercentage
FROM CovidProject.dbo.CovidDeaths
---WHERE location = 'India'
GROUP BY location,population
ORDER bY 4 DESC

-- highest death count

SELECT location, MAX(cast (total_deaths as int))AS HighestINfectionCount
FROM CovidProject.dbo.CovidDeaths
---WHERE location = 'India'
WHERE continent is not NULL
GROUP BY location,population
ORDER bY 2 DESC



--- Deth count percentage
SELECT location,population,MAX(CAST(total_deaths AS INT))AS LargestDeathCount,MAX((total_deaths/population))*100 as DeathPercentage
FROM CovidProject.dbo.CovidDeaths
---WHERE location = 'India'
GROUP BY location,population
ORDER bY 4 DESC

--  CONTINENT with highest death count
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is null 
Group by location
order by TotalDeathCount desc

---Global 

SELECT date, SUM(new_cases) AS TotaCases, SUM(CAST (new_deaths as INT)) AS TOTALDeaths,
SUM(CAST (new_deaths as INT))/SUM(new_cases)*100 as DailyDeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL

GROUP BY date 
ORDER BY 1,2



SELECT SUM(new_cases) AS TotaCases, SUM(CAST (new_deaths as INT)) AS TOTALDeaths,
SUM(CAST (new_deaths as INT))/SUM(new_cases)*100 as DailyDeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- total population vs vaccination

SELECT dea.continent,dea.location,dea.date, dea.population, vacc.new_vaccinations,
SUM(CONVERT(INT,vacc.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS TotalNewVaccinations
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vacc
on dea.location=vacc.location
AND dea.date=vacc.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

-- new vaccination in India
SELECT dea.continent,dea.location,dea.date, dea.population, vacc.new_vaccinations
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vacc
on dea.location=vacc.location
AND dea.date=vacc.date
WHERE dea.continent IS NOT NULL 
AND dea.location = 'India'
ORDER BY 2,3


--- TEMP tables
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
, SUM(CAST(vac.new_vaccinations AS numeric)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
DROP View PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT * 
FROM PercentPopulationVaccinated
