
-- quick look our data
select *
from CovidDeathAnalysis..CovidDeaths
order by 3,4


--select *
--from CovidDeathAnalysis..[covid-vaccinations]
--order by 3,4


-- Select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeathAnalysis..CovidDeaths
order by 1,2


-- Looking at total cases vs total deaths. death/case ratio added
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_ratio
from CovidDeathAnalysis..CovidDeaths
where location = 'Turkey'
order by 1,2


-- Looking at total cases vs population
-- what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as population_infected
from CovidDeathAnalysis..CovidDeaths
where location = 'Turkey'
order by 1,2


-- Looking at countries with highest infection rate
-- nullif: it allows to handle division by zero exeption
select location, 
       population, 
       max(total_cases) as highest_infection,
       max((total_cases/nullif(population, 0)))*100 as highest_infected_location

from CovidDeathAnalysis..CovidDeaths
group by location, population
order by highest_infected_location desc


-- Showing countries with highest death count per population
select location, max(total_deaths) as TotalDeathCount
from CovidDeathAnalysis..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- New cases/ new deaths ratio per day
select date,
	   sum(new_cases) as total_cases,
	   sum(new_deaths) as total_deaths,
	   sum(new_deaths)/nullif(sum(new_cases),0) as new_death_percentage

from CovidDeathAnalysis..CovidDeaths
group by date
order by 1,2


-- Total new cases/ deaths ratio
select sum(new_cases) as total_cases,
	   sum(new_deaths) as total_deaths,
	   sum(new_deaths)/nullif(sum(new_cases),0) as new_death_percentage

from CovidDeathAnalysis..CovidDeaths
order by 1,2


-- Look vaccinations
select * from CovidDeathAnalysis..CovidVaccinations


-- join two tables on location and date
select * from CovidDeathAnalysis..CovidDeaths as dea
         join CovidDeathAnalysis..CovidVaccinations as vac
		 on dea.location = vac.location
		 and dea.date = vac.date


-- Looking at total population vs vaccinations
select dea.continent,
       dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   sum(cast(vac.new_vaccinations as float)) 
	   over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated

from CovidDeathAnalysis..CovidDeaths as dea
join CovidDeathAnalysis..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
order by 2,3


-- Use cte
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as 
(
select dea.continent,
        dea.location,
	    dea.date,
	    dea.population,
	    vac.new_vaccinations,
	    sum(cast(vac.new_vaccinations as float)) 
	    over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated

from CovidDeathAnalysis..CovidDeaths as dea
join CovidDeathAnalysis..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
)
select * from PopvsVac


-- Creating view to store data for later visualization
create view RollingPeopleVaccinated as
(select dea.continent,
        dea.location,
	    dea.date,
	    dea.population,
	    vac.new_vaccinations,
	    sum(cast(vac.new_vaccinations as float)) 
	    over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated

from CovidDeathAnalysis..CovidDeaths as dea
join CovidDeathAnalysis..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)

select * from RollingPeopleVaccinated
