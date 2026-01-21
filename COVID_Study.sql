--SELECT *
--FROM PortifolioProject..CovidVaccinations$
--ORDER BY 3,4

SELECT *
FROM PortifolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY location, date

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortifolioProject..CovidDeaths$
ORDER BY location, date

-- Looking at Total Cases vs Total Deaths in Brazil

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as "Death Percentage"
FROM PortifolioProject..CovidDeaths$
WHERE location like 'Brazil'
ORDER BY location, date

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid in Brazil

SELECT location, date, population, total_cases, (total_cases/population)*100 as "COVID Infected Percentage"
FROM PortifolioProject..CovidDeaths$
WHERE location like 'Brazil'
ORDER BY location, date

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as "Highest_Infection_Count", MAX((total_cases/population))*100 as "COVID_Percentage"
FROM PortifolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY COVID_Percentage DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, population, MAX(cast(total_deaths as int)) as "Total_Death_Count"
FROM PortifolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Total_Death_Count DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the higest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as "Total_Death_Count"
FROM PortifolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as "New_Cases", SUM(cast(new_deaths as int)) as "New_Deaths" , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as "Death Percentage"
FROM (SELECT location, date, MAX(new_cases) as "New_Cases", MAX(cast(new_deaths as int)) as "New_Deaths"
	  FROM PortifolioProject..CovidDeaths$
	  WHERE continent IS NOT NULL
	  GROUP BY location, date) d

GROUP BY date
ORDER BY date, New_Cases

-- Looking at total population VS Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location ORDER BY d.location, d.date) as "All_vaccinations"


FROM (SELECT continent, location, date, MAX(population) as population 
		FROM PortifolioProject..CovidDeaths$
		WHERE continent IS NOT NULL
		GROUP BY continent, location, date) d

JOIN PortifolioProject..CovidVaccinations$ v 
ON d.location = v.location AND d.date = v.date

WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date


--- USE of CTE

With PopvsVac (Continent, Location, date, population, New_Vaccinations, total_vaccinations) as

(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location ORDER BY d.location, d.date) as "total_vaccinations"


FROM (SELECT continent, location, date, MAX(population) as population 
		FROM PortifolioProject..CovidDeaths$
		WHERE continent IS NOT NULL
		GROUP BY continent, location, date) d

JOIN PortifolioProject..CovidVaccinations$ v 
ON d.location = v.location AND d.date = v.date

WHERE d.continent IS NOT NULL
)

SELECT *, (total_vaccinations/Population)*100 as "%_Vaccinated"
FROM PopvsVac
ORDER BY location, date

-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
total_vaccinations numeric
)

Insert into #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location ORDER BY d.location, d.date) as "total_vaccinations"


FROM (SELECT continent, location, date, MAX(population) as population 
		FROM PortifolioProject..CovidDeaths$
		WHERE continent IS NOT NULL
		GROUP BY continent, location, date) d

JOIN PortifolioProject..CovidVaccinations$ v 
ON d.location = v.location AND d.date = v.date

WHERE d.continent IS NOT NULL

SELECT *, (total_vaccinations/Population)*100 as "%_Vaccinated"
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View

PercentPopulationVaccinated as

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location ORDER BY d.location, d.date) as "total_vaccinations"


FROM (SELECT continent, location, date, MAX(population) as population 
		FROM PortifolioProject..CovidDeaths$
		WHERE continent IS NOT NULL
		GROUP BY continent, location, date) d

JOIN PortifolioProject..CovidVaccinations$ v 
ON d.location = v.location AND d.date = v.date

WHERE d.continent IS NOT NULL