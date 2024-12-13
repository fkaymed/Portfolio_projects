-- to select the data to work with
select *
from Portfolioproject..CovidDeaths

select *
from Portfolioproject..CovidVaccinations

--possibility of being infected with covid per country
select location, population, sum(new_cases) as total_cases, ((sum(new_cases)/population)*100) as possibility
from Portfolioproject..CovidDeaths where new_cases is not null and continent is not null
group by location, population
order by 4 desc

--possibility of being infected with covid per continent
select location, population, sum(new_cases) as total_cases, ((sum(new_cases)/population)*100) as possibility
from Portfolioproject..CovidDeaths where continent is null
group by location, population
order by 4 desc

--possibility of infected or non infected people dying from covid per country
select location, population, (sum(new_deaths)/sum(new_cases)*100) as infectedmortality, (1-(sum(new_deaths)/sum(new_cases)*100)) as uninfectedmortality
from Portfolioproject..CovidDeaths where continent is not null and new_cases <> 0
group by location, population
order by 3,4

-- possibility of infected or non infected people dying from covid per continent
select location, population, (sum(new_deaths)/sum(new_cases)*100) as infectedmortality, (1-(sum(new_deaths)/sum(new_cases)*100)) as uninfectedmortality
from Portfolioproject..CovidDeaths where continent is null and new_cases <> 0
group by location, population
order by 3,4

-- possibility of covid case becoming critical per country 
select location, sum(convert (int, icu_patients)) as critial_cases, sum(cast (icu_patients as int))/sum(new_cases)*100 as possibility
from Portfolioproject..CovidDeaths where new_cases<> 0 and  continent is not null
group by location
order by possibility

--possibility of testing positive for covid in a country
select location, avg(cast(positive_rate as float))/population*100 as possibility
from Portfolioproject..CovidVaccinations where population<> 0 and  continent is not null
group by location, population
order by 2 desc

--effect of poverty on getting infected by covid per country
select dea.location, avg(cast(extreme_poverty as float)), sum(new_cases) as total_cases, avg(cast(extreme_poverty as float))/sum(new_cases)*100 as possibility
from Portfolioproject..CovidDeaths dea join Portfolioproject..CovidVaccinations vac on dea.date =vac.date where new_cases<>0 and dea.continent is not null
group by dea.location

-- possibilty of patients with underlying conditions suffering from covid per country
select dea.location, sum(new_cases) as total_cases, avg(cast(diabetes_prevalence as float)) as underlying_condition, avg(cast(diabetes_prevalence as float))/sum(new_cases)*100 as possibility
from Portfolioproject..CovidDeaths dea join Portfolioproject..CovidVaccinations vac on dea.date =vac.date where new_cases<>0 and dea.continent is not null
group by dea.location

--extra stuffs
select location, continent, date, population, sum(convert(float, new_vaccinations)) OVER (partition by location order by date, location) as rolling_vaccinations
from Portfolioproject..covidVaccinations
where continent is not null


with cte (location, continent, date, population, rolling_vaccinations)
as
(select location, continent, date, population, sum(convert(float, new_vaccinations)) OVER (partition by location order by date, location) as rolling_vaccinations
from Portfolioproject..covidVaccinations
where continent is not null
)
select *, (rolling_vaccinations/population)*100 as possibility
from cte


Drop table if exists #temp_table
create table #temp_table
(location nvarchar(255),
continent nvarchar (255),
date datetime,
population numeric,
rolling_vaccinations numeric)
insert into #temp_table
select location, continent, date, population, sum(convert(float, new_vaccinations)) OVER (partition by location order by date, location) as rolling_vaccinations
from Portfolioproject..covidVaccinations
where continent is not null
select *, (rolling_vaccinations/population)*100 as possibility
from #temp_table


Create view vaccines as
select location, continent, date, population, sum(convert(float, new_vaccinations)) OVER (partition by location order by date, location) as rolling_vaccinations
from Portfolioproject..covidVaccinations
where continent is not null


select *
from vaccines


create view precedence as
select dea.location, avg(cast(extreme_poverty as float)) as poverty, sum(new_cases) as total_cases, avg(cast(extreme_poverty as float))/sum(new_cases)*100 as possibility
from Portfolioproject..CovidDeaths dea join Portfolioproject..CovidVaccinations vac on dea.date =vac.date where new_cases<>0 and dea.continent is not null
group by dea.location
