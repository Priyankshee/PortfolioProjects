select *
from PortfolioProject..CovidDeaths
where continent is not null and continent <> ''

select *
from PortfolioProject..CovidVaccinationsnew

--SELECT DATA THAT WE ARE GOING TO BE USING

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null and continent <> ''

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

select location, date, total_cases, total_deaths, (cast(total_deaths as float) / nullif(cast(total_cases as float), 0)) * 100 as deathpercentage
from PortfolioProject..CovidDeaths
where location='india' and continent is not null and continent <> ''

--LOOKING AT THE TOTAL CASES VS PERCENTAGE
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

select location, date,  cast(population AS bigint) as population, total_cases, (cast(total_cases as float) / nullif(cast(population as bigint), 0)) * 100 as covidpercentage
from PortfolioProject..CovidDeaths
--where location='india'
where continent is not null and continent <> ''

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

select location, cast(population AS bigint) as population, max(total_cases) as highestinfectioncount, max((cast(total_cases as float) / nullif(cast(population as bigint), 0))) * 100 as covidpercentage
from PortfolioProject..CovidDeaths
--where location='india'
where continent is not null and continent <> ''
group by location, population
order by covidpercentage desc

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

select location, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location='india'
where continent is not null and continent <> ''
group by location
order by totaldeathcount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location='india'
where continent is not null and continent <> ''
group by continent
order by totaldeathcount desc

--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location='india'
where continent is not null and continent <> ''
group by continent
order by totaldeathcount desc

--GLOBAL NUMBERS

select sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as float)) / nullif(sum(cast(new_cases as float)), 0)) * 100 as deathpercentage
from PortfolioProject..CovidDeaths
--where location='india' 
where continent is not null and continent <> ''
--group by date
--order by date, total_cases

select *
from PortfolioProject..CovidVaccinationsnew

--LOOKING AT TOTAL POPULATION VS VACCINATIONS

select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinationsnew vac
  on dea.location = vac.location
  and dea. date = vac.date
where dea.continent is not null and dea.continent <> ''
order by 2,3

--USE CTE

with popvsvac(continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinationsnew vac
  on dea.location = vac.location
  and dea. date = vac.date
where dea.continent is not null and dea.continent <> ''
--order by 2,3
)
select *, (rollingpeoplevaccinated/NULLIF(population, 0)) *100
from popvsvac


--TEMP TABLE

create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent, dea. location, cast(dea.date as date), dea.population, cast(vac.new_vaccinations as int)
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,cast(dea.date as date)) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinationsnew vac
  on dea.location = vac.location
  and cast(dea.date as date) = cast(vac.date as date)
where dea.continent is not null and dea.continent <> ''
--order by 2,3

select *, (rollingpeoplevaccinated/nullif(population, 0)) *100
from #percentpopulationvaccinated


select column_name, data_type
from information_schema.columns
where table_name = 'CovidDeaths' and column_name = 'date';

select date
from PortfolioProject..CovidDeaths
where try_cast(date as date) is null;


