-- DATA EXPLORATION
/* 
Data sourced from https://ourworldindata.org/covid-deaths 
CSV split into two separate Excel sheets COVIDDeaths & COVIDVaccinations
Data Imported to MSSMS via SQL Sever Import / Export Wizard into project directory

Data Cleaning Observations:
1. some data types are nvarchar and can cause unexpected results when aggregate functions are used - Solution was to recast the data type
2. Location and Continent columns have innacuracy which is not helpful in some circumstances. for example Asia, South america and Europe are in the contienent column with Null location data int he original table. Solution: ues "IS NOT NULL"
*/ 

--SELECT * 
--FROM PortfolioProject..COVIDVaccinations
--WHERE continent IS NOT NULL
--ORDER BY 3,4

--SELECT Data we will be using for Analysis

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..COVIDDeaths
--WHERE continent IS NOT NULL
--ORDER BY 1,2 -- Based on loctaion and date


---- Total cases vs total deaths in a given country
---- Liklihood of dying if you contract COVID as a rough estimate.
--SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
--FROM PortfolioProject..COVIDDeaths
--WHERE location LIKE '%pines%' 
--AND WHERE continent IS NOT NULL
--ORDER BY 1,2 -- Death percentage can give us some indication of the chance of dying. If you live in the Philippines for example you have a  1.725% chance of death
---- If you catch covid 2021-08-24 in IRAN 2.173% UK 2.00% USA- 1.656%

---- Look at total cases VS. Population
----What percentage of the population got COVID?
--SELECT location, date, population, total_cases, (total_cases / population)*100 AS PercentOfPopulationInfected
--FROM PortfolioProject..COVIDDeaths
--WHERE location LIKE '%pines%' 
--AND WHERE continent IS NOT NULL
--ORDER BY 1,2 


--Looking at Countries with the highest infection rate compared to population

--SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases / population)*100 AS PercentOfPopulationInfected
--FROM PortfolioProject..COVIDDeaths
--WHERE continent IS NOT NULL
--GROUP BY population,location
--ORDER BY PercentOfPopulationInfected DESC

-- Showing the cuntries with the highest death count per population
--SELECT location,MAX(cast(Total_deaths AS INT))AS TotaLDeathCount -- Cast to change nvarchar to int because of unexpected results.
--FROM PortfolioProject..COVIDDeaths
--WHERE continent IS NOT NULL
--GROUP BY location --some entire continents skew data slightly see data cleaning item 2.
--ORDER BY TotaLDeathCount DESC


---- Showing the contients with the highest death count
--SELECT location, MAX(cast(Total_deaths AS INT))AS TotaLDeathCount -- Cast to change nvarchar to int because of unexpected results.
--FROM PortfolioProject..COVIDDeaths
--WHERE continent IS NULL -- See data cleaning item 2
--GROUP BY location 
--ORDER BY TotaLDeathCount DESC

---- Showing the contients with the highest death count
---- we can change the aforementioned group by locations to continent as wel for a better drill down viz

--SELECT location, MAX(cast(Total_deaths AS INT))AS TotaLDeathCount -- Cast to change nvarchar to int because of unexpected results.
--FROM PortfolioProject..COVIDDeaths
--WHERE continent IS NULL -- See data cleaning item 2
--GROUP BY location 
--ORDER BY TotaLDeathCount DESC

---- Global numbers per day
--SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS GlobalDeathPercentage
--FROM PortfolioProject..COVIDDeaths
--WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1,2 -- Based on loctaion and date

----Global Cases TOTAL 
--SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS GlobalDeathPercentage
--FROM PortfolioProject..COVIDDeaths
--WHERE continent IS NOT NULL
--ORDER BY 1,2 -- Based on loctaion and date


--JOIN Tables 

-- Total Population vs vacination (total people vaccinated) Cumilative vaccination Calculates based on location(s)
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,SUM(CONVERT( int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumilativeVaccinations
--, (CumilativeVacinations/population) *100 
--FROM PortfolioProject..COVIDDeaths AS dea
--JOIN PortfolioProject..COVIDVaccinations AS vac
-- 	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--AND dea.location LIKE '%pines%'
--ORDER BY 2,3

----- CTE METHOD

--WITH PopVsVac (continent, location, date, population, new_vaccinations,CumilativeVaccinations)
--AS 
--( 
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumilativeVaccinations
----, (CumilativeVacinations/population) *100 
--FROM PortfolioProject..COVIDDeaths AS dea
--JOIN PortfolioProject..COVIDVaccinations AS vac
-- 	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--AND dea.location LIKE '%pines%'
--)
--SELECT *, (CumilativeVaccinations/population)*100
--FROM PopVsVac

--TEMP TABLE Method
--DROP TABLE IF EXISTS #PercentPopulationVaccinated
--CREATE TABLE #PercentPopulationVaccinated
--(
--continent nvarchar(255),
--location nvarchar(255),
--date datetime,
--population numeric,
--new_vaccinations numeric,
--CumilativeVaccinations numeric
--)

--INSERT INTO #PercentPopulationVaccinated
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumilativeVaccinations
--FROM PortfolioProject..COVIDDeaths AS dea
--JOIN PortfolioProject..COVIDVaccinations AS vac
-- 	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--AND dea.location LIKE '%pines%'
--SELECT *, (CumilativeVaccinations/population)*100
--FROM #PercentPopulationVaccinated


--CREATING VIEWS TO STORE DATA FOR VISUALISATION
--VIS relates to the Philippines only

CREATE VIEW PercentPopulationVaccinatedPhilippines AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumilativeVaccinations
FROM PortfolioProject..COVIDDeaths AS dea
JOIN PortfolioProject..COVIDVaccinations AS vac
 	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND dea.location LIKE '%pines%'

SELECT *
FROM PercentPopulationVaccinatedPhilippines