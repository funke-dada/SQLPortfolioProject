--select * from PortfolioProject..Coviddeaths$
--order by 3,4


--Covid cases by continent

SELECT Location as Continent, date, total_cases, new_cases, total_deaths, population 
   FROM PortfolioProject..Coviddeaths$
   WHERE continent is null
   AND Location NOT IN( 'World', 'European Union', 'International') 
   ORDER BY 1,2


   SELECT Location as Continent, SUM (cast(new_deaths as int)) as TotalDeathCount
   FROM PortfolioProject..Coviddeaths$
   WHERE continent is null
   AND Location NOT IN( 'World', 'European Union', 'International') 
   Group by location
   ORDER BY 2

----select Location, date, total_cases, new_cases, total_deaths, population 
----FROM PortfolioProject..Coviddeaths$
----order by 1,2


--Total cases versus total deaths

--SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--   FROM PortfolioProject.dbo.Coviddeaths$
--   WHERE Location like '%states%'
--	 ORDER BY 1, 2


--Percentage of population that has contracted COVID-19

SELECT Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
    FROM PortfolioProject.dbo.Coviddeaths$
    WHERE Location like '%states%'
    ORDER BY 1, 2

--countries with the highest infection rate
SELECT Location, population, date, MAX(total_cases)as HighestInfectionCount, (MAX(total_cases/population))*100 as CovidInfectionPercentage
   FROM PortfolioProject.dbo.Coviddeaths$
     WHERE continent IS NOT NULL
   GROUP BY Location, population, date
   ORDER BY 1,2 desc


--countries with the highest death rate per population
SELECT Location, population, MAX(cast(total_deaths as int) ) as HighestDeathCount, 
(MAX(total_deaths/population))*100 as CovidDeathsPercentage
   FROM PortfolioProject.dbo.Coviddeaths$
   WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY 1,2


--Total Death Count by Country
SELECT Location, MAX(cast(total_deaths as int) ) as CountryTotalDeathCount
 FROM PortfolioProject.dbo.Coviddeaths$
 WHERE Continent is not null
 GROUP BY location
 ORDER BY CountryTotalDeathCount desc


 

--Total Death Count by Countinent
SELECT Location, MAX(cast(total_deaths as int) ) as CountryTotalDeathCount
 FROM PortfolioProject.dbo.Coviddeaths$
 WHERE Continent is not null
 GROUP BY location
 ORDER BY CountryTotalDeathCount desc

SELECT * FROM PortfolioProject.dbo.Coviddeaths$
where continent is null


--Total Death Count by Continent
SELECT Continent, MAX(cast(total_deaths as int)) as ContinentTotalDeathCount
 FROM PortfolioProject.dbo.Coviddeaths$
 WHERE Continent is not null
 GROUP BY continent
 ORDER BY ContinentTotalDeathCount desc

 --Continents with the highest death count per population
 SELECT continent, population, MAX(cast(total_deaths as int) ) as HighestDeathCount, 
(MAX(total_deaths/population))*100 as CovidDeathsPercentage
   FROM PortfolioProject.dbo.Coviddeaths$
   WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY 1,2

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths AS int)) as TotalDeaths,
 SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
 FROM PortfolioProject.dbo.Coviddeaths$
 WHERE Continent is not null
 GROUP BY date
 ORDER BY 1,2

 SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths AS int)) as TotalDeaths,
 SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
 FROM PortfolioProject.dbo.Coviddeaths$
 WHERE Continent is not null
 ORDER BY 1,2


 --GLOBAL NUMBERS SUMMARY
 
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths AS int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
 FROM PortfolioProject.dbo.Coviddeaths$
 WHERE Continent is not null
 ORDER BY 1,2


 SELECT * from PortfolioProject..Coviddeaths$ d
   Join PortfolioProject..CovidVaccinations$ v 
   on d.location =v.location 
   AND d.date= v.date
 


 --TOTAL POPULATION VS VACCINATIONS

 WITH BaseTable (continent, location, date, population, new_vaccinations, CumulativePeopleVaccinated)
 AS
 (
  SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
  SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location order by d.location, d.date) as CumulativeVaccinations
   from PortfolioProject..Coviddeaths$ d
   Join PortfolioProject..CovidVaccinations$ v 
   on d.location =v.location 
   AND d.date= v.date
   WHERE d.continent is NOT NULL
  )

  SELECT *, (CumulativePeopleVaccinated/population)*100  as PercentageVaccinated from BaseTable
				
--USING TEMP TABLE
Drop Table if exists #PercentVaccinated
Create Table 
#PercentVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CumulativeVaccinations numeric
)
Insert into #PercentVaccinated
 SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
  SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location order by d.location, d.date) as CumulativeVaccinations
   from PortfolioProject..Coviddeaths$ d
   Join PortfolioProject..CovidVaccinations$ v 
   on d.location =v.location 
   AND d.date= v.date
   WHERE d.continent is NOT NULL
    SELECT *, (CumulativeVaccinations/population)*100  as PercentageVaccinated from #PercentVaccinated


	--create view for future data visualizations
Create view PercentPopulationVaccinated as
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
    SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location order by d.location, d.date) as CumulativeVaccinations
    from PortfolioProject..Coviddeaths$ d
    Join PortfolioProject..CovidVaccinations$ v 
    on d.location =v.location 
    AND d.date= v.date
    WHERE d.continent is NOT NULL

	SELECT * FROM PercentPopulationVaccinated