select * from [sql projects].dbo.Data1$;

select * from [sql projects].dbo.Sheet1$;

-- number of rows inn dataset

select count(*) from [sql projects]..Data1$
select count(*) from [sql projects]..Sheet1$

-- dataset for bihar & Jharkhand

select * from [sql projects]..Data1$ where State in ('Jharkhand', 'Bihar')

-- population of india

select sum(population) from [sql projects]..Sheet1$

--Average growth of state

select state, AVG(growth)*100 avg_growth from [sql projects]..Data1$ group by state

-- avg sex ratio

select state, round(AVG(sex_ratio),0) avg_sex_ratio from [sql projects]..Data1$ group by state order by avg_sex_ratio desc

--avg literacy rate

select state, round(AVG(Literacy),0) avg_literacy_ratio from [sql projects]..Data1$ 
group by state having round(avg(Literacy),0)>90 order by avg_literacy_ratio desc

--top 3 state showing highest average growth ratio

select top 3 state, avg(growth)*100 avg_growth from [sql projects]..Data1$ group by state order by avg_growth desc

--bottom 3 state showing lowest sex ratio

select top 3 state,round(avg(sex_ratio),0) avg_sex_ratio from [sql projects]..Data1$ group by state order by avg_sex_ratio asc


-- top and bottom 3 states in literacy state

drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
  topstate float

  )

insert into #topstates
select state,round(avg(literacy),0) avg_literacy_ratio from [sql projects]..Data1$
group by state order by avg_literacy_ratio desc;

select top 3 * from #topstates order by #topstates.topstate desc;

drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
  bottomstate float

  )

insert into #bottomstates
select state,round(avg(literacy),0) avg_literacy_ratio from [sql projects]..Data1$
group by state order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;

--union opertor

select * from (
select top 3 * from #topstates order by #topstates.topstate desc) a

union

select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b;


-- states starting with letter a

select distinct state from [sql projects]..Data1$ where lower(state) like 'a%' or lower(state) like 'b%'

select distinct state from [sql projects]..Data1$ where lower(state) like 'a%' and lower(state) like '%m'


-- joining both table

--total males and females

select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from [sql projects]..Data1$ a inner join [sql projects]..Sheet1$ b on a.district=b.district ) c) d
group by d.state;

-- total literacy rate


select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio,b.population from [sql projects]..Data1$ a 
inner join [sql projects]..Sheet1$ b on a.district=b.district) d) c
group by c.state

-- population in previous census


select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from [sql projects]..Data1$ a inner join [sql projects]..Sheet1$ b on a.district=b.district) d) e
group by e.state)m


-- population vs area

select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from (

select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from [sql projects]..Data1$ a inner join [sql projects]..Sheet1$ b on a.district=b.district) d) e
group by e.state)m) n) q inner join (

select '1' as keyy,z.* from (
select sum(area_km2) total_area from [sql projects]..Sheet1$)z) r on q.keyy=r.keyy)g
