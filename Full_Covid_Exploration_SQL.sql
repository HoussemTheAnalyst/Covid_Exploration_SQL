-- Checking Data in Table 1
SELECT * 
FROM portfolio..CovidDeaths
ORDER BY 3, 4;

SELECT COUNT(*)
FROM portfolio..CovidDeaths;

-- Checking Data in Table 2
SELECT * 
FROM portfolio..CovidDeaths
ORDER BY 3, 4;

SELECT COUNT(*)
FROM portfolio..CovidDeaths;

-- Total Cases per Continents
SELECT 
    continent, 
    SUM(new_cases) AS total_cases
FROM 
    portfolio..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent;

-- Total Cases per Country
SELECT 
    location, 
    SUM(new_cases) AS total_cases
FROM 
    portfolio..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    location
HAVING 
    SUM(new_cases) IS NOT NULL
ORDER BY 
    SUM(new_cases) DESC;

-- Checking most recent date for Algeria
SELECT 
    location, 
    MAX(date) AS most_recent_date
FROM 
    portfolio..CovidDeaths
WHERE 
    location = 'Algeria'
GROUP BY 
    location;

-- Checking my country Algeria most recent date
SELECT *
FROM portfolio..CovidDeaths
WHERE location = 'Algeria' AND date = '2023-11-09';

-- Total number of cases worldwide
SELECT 
    SUM(cast(total_cases as bigint)) AS Total_Covid_Cases_Worldwide
FROM (
    SELECT 
        MAX(date) AS most_recent_date, 
        location
    FROM 
        portfolio..CovidDeaths
    WHERE 
        continent IS NOT NULL 
    GROUP BY  
        location
) AS maxd
JOIN 
    Portfolio..CovidDeaths AS cd ON maxd.most_recent_date = cd.date AND maxd.location = cd.location;

-- Checking the most recent new cases, total cases, total deaths, and death percentages by countries
SELECT 
    most_recent_date, 
    cd.location, 
    new_cases, 
    CAST(total_cases AS INT) AS total_cases, 
    total_deaths,
    CAST(total_deaths AS DECIMAL) / CAST(total_cases AS DECIMAL) * 100 AS death_percentage
FROM (
    SELECT 
        MAX(date) AS most_recent_date, 
        location
    FROM 
        portfolio..CovidDeaths
    WHERE 
        continent IS NOT NULL 
    GROUP BY  
        location
) AS maxd
JOIN 
    Portfolio..CovidDeaths AS cd ON maxd.most_recent_date = cd.date AND maxd.location = cd.location
ORDER BY 
    CAST(total_cases AS INT) DESC;

-- Creating a view View_1
CREATE VIEW view_1 AS 
SELECT 
    most_recent_date, 
    cd.location, 
    new_cases, 
    CAST(total_cases AS INT) AS total_cases, 
    total_deaths,
    CAST(total_deaths AS DECIMAL) / CAST(total_cases AS DECIMAL) * 100 AS death_percentage
FROM (
    SELECT 
        MAX(date) AS most_recent_date, 
        location
    FROM 
        portfolio..CovidDeaths
    WHERE 
        continent IS NOT NULL 
    GROUP BY  
        location
) AS maxd
JOIN 
    Portfolio..CovidDeaths AS cd ON maxd.most_recent_date = cd.date AND maxd.location = cd.location;

-- Testing the View_1
SELECT *
FROM view_1
ORDER BY total_cases DESC;

-- Calculating Total cases, Total deaths, and average death percentage worldwide
SELECT 
    sum(cast(total_cases as bigint)) AS Total_Cases,
    sum(cast(total_deaths as bigint)) AS Total_Deaths,
    AVG(death_percentage) AS Average_Death_Percentage
FROM view_1;

-- Total Cases by countries before 2022-01-01
SELECT *
FROM portfolio..CovidDeaths
WHERE date <= '2022-01-01' AND continent IS NOT NULL
ORDER BY 2,3 ASC;

-- Rolling new cases by countries
SELECT 
    Location, 
    date, 
    sum(new_cases) OVER(partition by location order by date) AS rolling_new_cases
FROM portfolio..CovidDeaths
WHERE continent IS NOT NULL;

-- The total of new cases for the current year by country by date
SELECT 
    date,
    location,
    SUM(new_cases) AS cases_per_day_per_country
FROM 
    Portfolio..CovidDeaths
WHERE 
    date BETWEEN '2023-01-01' AND '2023-12-31' 
    AND continent IS NOT NULL
GROUP BY 
    date, location
ORDER BY 
    date, location;

-- Total cases by continent
SELECT 
    continent,
    Max(cast(total_cases as bigint)) AS Total_Cases
FROM Portfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Max(cast(total_cases as bigint)) DESC;

-- Total population VS Vaccination
SELECT 
    dea.date,
    dea.continent, 
    dea.location, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS Rolling_New_Vaccinations,
    vac.people_vaccinated,
    vac.people_fully_vaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 3;

-- Creating Temp Table
DROP TABLE IF EXISTS VaccinatedPopulation;
CREATE TABLE VaccinatedPopulation (
    date datetime,
    continent nvarchar(255),
    location nvarchar(255),
    population bigint,
    new_vaccinations numeric,
    Rolling_New_Vaccinations bigint,
    people_vaccinated bigint,
    people_fully_vaccinated bigint
);

INSERT INTO VaccinatedPopulation (date, continent, location, population, new_vaccinations, Rolling_New_Vaccinations, people_vaccinated, people_fully_vaccinated)
SELECT
    dea.date,
    dea.continent, 
    dea.location, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS Rolling_New_Vaccinations,
    vac.people_vaccinated,
    vac.people_fully_vaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Calculation of percentage of people vaccinated
SELECT 
    *, 
    (CAST(Rolling_New_Vaccinations AS decimal) / CAST(population AS decimal)) * 100 AS percentage_people_vaccinated
FROM VaccinatedPopulation;


-- Checking Vaccinations Table for Correct Percentages
SELECT *
FROM Portfolio..CovidVaccinations;

-- Checking Total New Vaccinations for China
SELECT 
    SUM(CAST(new_vaccinations AS bigint))
FROM 
    portfolio..CovidVaccinations
WHERE 
    location = 'China';

-- Calculation of Correct Percentages for most recent date
SELECT 
    location, 
    MAX((CAST(people_fully_vaccinated AS decimal) / CAST(population AS decimal))) * 100 AS percentage_people_vaccinated
FROM 
    VaccinatedPopulation
GROUP BY 
    location
ORDER BY 
    1;
