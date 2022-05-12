SELECT *
FROM PortfolioProject.dbo.CovidDeaths

SELECT continent, location, date, population, total_cases, new_cases, total_deaths, new_deaths
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 2,3


-- Canada's death percentage since the pandemic began by Date

SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases) * 100 AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Canada'
ORDER BY 2

-- Global death count by Location

 SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
 FROM PortfolioProject.dbo.CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY location
 ORDER BY TotalDeathCount desc

 -- Global death count and death percentage

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int)) / SUM(new_cases)*100 AS death_percentage 
FROM PortfolioProject.dbo.CovidDeaths 
WHERE continent is not null

 -- Joining two tables

 SELECT dea.continent, dea.location, dea.Date, dea.Population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location 
 ORDER BY dea.location, dea.date) AS RollingVaccinated
 FROM PortfolioProject.dbo.CovidDeaths dea
 JOIN PortfolioProject.dbo.CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent is not null
 ORDER BY 2,3
 
 -- Vaccinated count and vaccinated percentage by Location

SELECT dea.location, dea.Population, MAX(vac.total_vaccinations) as Vaccinated, 
MAX(vac.total_vaccinations)/dea.population * 100 as VaccinatedPercentage
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
GROUP BY dea.location, dea.population
ORDER BY 1

 -- USE CTE to get Vaccinated count and percentage
 
 WITH VacPop (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinated)
 as 
 ( SELECT dea.continent, dea.location,dea.date, dea.Population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location
 ORDER by dea.location, dea.date) AS RollingVaccinated
 FROM PortfolioProject.dbo.CovidDeaths dea
 JOIN PortfolioProject.dbo.CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent is not null
 ) 
 SELECT *, (RollingVaccinated/Population)*100 AS VaccinationPercentage
 FROM VacPop
 Order by 2,3

 -- TEMP Table
 Drop Table if exists PercentPopulationVaccinated
 CREATE Table PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingVaccinated numeric)
 INSERT INTO PercentPopulationVaccinated
 SELECT dea.continent, dea.location,dea.date, dea.Population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location
 ORDER by dea.location, dea.date) AS RollingVaccinated
 FROM PortfolioProject.dbo.CovidDeaths dea
 JOIN PortfolioProject.dbo.CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date

 
 SELECT *, (RollingVaccinated/Population)*100 as VaccinatedPercentage
 FROM PercentPopulationVaccinated
 ORDER BY 2,3

 -- CREATE View to store data for later

CREATE VIEW VaccinatedPercentage as
 SELECT dea.location, dea.Population, MAX(vac.total_vaccinations) AS Vaccinated,
 MAX(vac.total_vaccinations)/ dea.population * 100 AS VaccinatedPercentage
 FROM PortfolioProject.dbo.CovidDeaths dea
 JOIN PortfolioProject.dbo.CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent is not null
 GROUP BY dea.location, dea.population

 
 CREATE VIEW DeathPercentage as
 SELECT dea.location, MAX(dea.total_cases) AS Cases,MAX(dea.total_deaths) AS Deaths,
 MAX(dea.total_deaths) / MAX(dea.total_cases) * 100 AS DeathPercentage
 FROM PortfolioProject.dbo.CovidDeaths dea
 WHERE dea.continent is not null
 GROUP BY dea.location
 
 


 