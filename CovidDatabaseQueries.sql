-- Total Cases vs Total Deaths in the United States
-- Probability of death from contracting Covid in United States over time
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/ CONVERT(float, total_cases)) * 100 AS DeathPercentage
FROM CovidDatabase.dbo.CovidDeaths
WHERE location like '%states%'
ORDER By 1, 2

-- Total Cases vs Population
-- Percentage of U.S. population that contacted COVID
SELECT location, date, population, total_cases, (CONVERT(float, total_cases)/ CONVERT(float, population)) * 100 AS PercentContracted
FROM CovidDatabase.dbo.CovidDeaths
WHERE location like '%states%'
ORDER By 1, 2

-- Countries with highest infection rate relative to population
SELECT location, population, MAX(convert(float, total_cases)) AS HighestContractionCount, MAX(CONVERT(float, total_cases)/ CONVERT(float, population)) * 100 AS PercentContracted
FROM CovidDatabase.dbo.CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

-- Countries with highest death count relative to poplation
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeaths
FROM CovidDatabase..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeaths DESC

-- Break down highest death count relative to population based on continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeaths
FROM CovidDatabase.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeaths DESC

-- Global Numbers
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDatabase.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Population vs Vaccinated Population
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(convert(bigint, vacc.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) AS TotalVaccinations
FROM CovidDatabase..CovidDeaths death
Join CovidDatabase..CovidVaccinations vacc
	ON death.location = vacc.location
	and death.date = vacc.date
WHERE death.continent is not null AND vacc.new_vaccinations is not null
ORDER BY 2,3

-- Total Population vs Vaccinated Population with percentage vaccinated
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinations)
as
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(convert(bigint, vacc.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) AS TotalVaccinations
FROM CovidDatabase..CovidDeaths death
Join CovidDatabase..CovidVaccinations vacc
	ON death.location = vacc.location
	and death.date = vacc.date
WHERE death.continent is not null AND vacc.new_vaccinations is not null
--ORDER BY 2,3
)
SELECT *, (TotalVaccinations/population)*100 as PercentVaccinated
FROM PopvsVac

-- View to Store Data for future visualizations
Create View PercentPopulationVaccinated as 
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(convert(bigint, vacc.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) AS TotalVaccinations
FROM CovidDatabase..CovidDeaths death
Join CovidDatabase..CovidVaccinations vacc
	ON death.location = vacc.location
	and death.date = vacc.date
WHERE death.continent is not null AND vacc.new_vaccinations is not null
