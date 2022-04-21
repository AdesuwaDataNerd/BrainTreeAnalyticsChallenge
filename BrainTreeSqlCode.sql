create database Continent;
use Continent;

update continent_map
set country_code=null where country_code='';


#question one
select 
	coalesce(country_code,'FOO') 
from 
		continent_map
group by country_code having count(*)>1
order by country_code;

#question two
#growth percent of country whic falls between 10-12 position by continent
select 
   f.rnk, f.continent_name,
   f.country_code, f.country_name, concat(growth_percent, '%') as growth_percent
from
   (select
        a.continent_name,
        a.country_code,
        a.country_name,
        round((b.gdp_2012 - a.gdp_2011)/a.gdp_2011 * 100,1) as growth_percent,
        rank() over(partition by a.continent_name order by round((b.gdp_2012 - a.gdp_2011)/a.gdp_2011 *100,1) desc) rnk
from 
    (select
        co.continent_name,
        c.country_code,
        c.country_name,
        pc.year,
         pc.gdp_per_capita AS gdp_2011
from continents co
join continent_map cm on cm.continent_code = co.continent_code 
join countries c on c.country_code = cm.country_code
join per_capital pc on pc.country_code = c.country_code
where pc.year = 2011
group by 1,2) a
    inner join
(select 
  co.continent_name,
  c.country_code,
  c.country_name,
  pc.year,
  pc.gdp_per_capita AS gdp_2012
from continents co
join continent_map cm on cm.continent_code = co.continent_code 
join countries c on c.country_code = cm.country_code
join per_capital pc on pc.country_code = c.country_code
where pc.year = 2012
group by 1,2)B on a.country_code = b.country_code) as f
where f.rnk in(10,11,12)
order by 2;

#question 3
select
	concat(a.Asia, '%') as Asia,
    concat(a.Europe,'%') as Europe,
    concat(a.Rest_Of_World,'%') as Rest_Of_World
from
	(select
		round((sum(case when co.continent_name ='Asia' then (pc.gdp_per_capita)  end)/sum(pc.gdp_per_capita))*100,1) as Asia,
        round((sum(case when co.continent_name ='Europe' then (pc.gdp_per_capita)  end)/sum(pc.gdp_per_capita))*100,1) as Europe,
        round((sum(case when co.continent_name in ('Africa','North America','Oceania','South America','Antartica') then (pc.gdp_per_capita) end)/sum(pc.gdp_per_capita))*100,1) as
        Rest_Of_World
from
	continents co
	join continent_map cm on cm.continent_code = co.continent_code 
	join countries c on c.country_code = cm.country_code
	join per_capital pc on pc.country_code = c.country_code
where pc.year= 2012) as a;
        
#question 4
# What is the count of countries and sum of their related gdp_per_capita values for the year 2007 where the string 'an' (case insensitive) appears anywhere in the country name?
select
        count(c.country_name),
        sum(pc.gdp_per_capita)
from continents co
join continent_map cm on cm.continent_code = co.continent_code 
join countries c on c.country_code = cm.country_code
join per_capital pc on pc.country_code = c.country_code
where pc.year = '2007' and  c.country_name regexp 'an';
#4(b)
select
        count(c.country_name),
        sum(pc.gdp_per_capita)
from continents co
join continent_map cm on cm.continent_code = co.continent_code 
join countries c on c.country_code = cm.country_code
join per_capital pc on pc.country_code = c.country_code
where pc.year = '2007' and  c.country_name = BINARY 'AN';


#question 5
#5(i)
select
		pc.year,
        count(c.country_name) as country_count,
        sum(pc.gdp_per_capita) as total
from continents co
join continent_map cm on cm.continent_code = co.continent_code 
join countries c on c.country_code = cm.country_code
join per_capital pc on pc.country_code = c.country_code
where pc.year < 2012 and gdp_per_capita is not null
group  by pc.year ;
#5(ii)
select
		pc.year,
        count(c.country_name) as country_count,
        sum(pc.gdp_per_capita) as total
from continents co
join continent_map cm on cm.continent_code = co.continent_code 
join countries c on c.country_code = cm.country_code
join per_capital pc on pc.country_code = c.country_code
where pc.year =2012 and gdp_per_capita is  null
group by pc.year;

#question 6
select
        c.country_code,
        c.country_name,
        co.continent_name,
        pc.gdp_per_capita,
        sum(pc.gdp_per_capita) over (order by pc.gdp_per_capita)	running_total	
from continents co
join continent_map cm on cm.continent_code = co.continent_code 
join countries c on c.country_code = cm.country_code
join per_capital pc on pc.country_code = c.country_code
where pc.year = '2009' and pc.gdp_per_capita >= '70000'
order by co.continent_name asc , substr(c.country_name,2,4);


#question 7
select 
	a.rnk,
    a.continent_name,
        a.country_code,
        a.country_name,
        concat ('$',a.avg_gdp_per_capital) as avg_gdp
        from
        (
select
		dense_rank() over(partition by co.continent_name order by round(avg(pc.gdp_per_capita),2) ) as rnk,
        co.continent_name,
        c.country_code,
        c.country_name,       
       round( avg(pc.gdp_per_capita),2) as avg_gdp_per_capital		
from continents co
join continent_map cm on cm.continent_code = co.continent_code 
join countries c on c.country_code = cm.country_code
join per_capital pc on pc.country_code = c.country_code
) as a;

select 
	a.rnk,
    a.continent_name,
        a.country_code,
        a.country_name,
        concat ('$',a.avg_gdp_per_capital) as avg_gdp
        from
        (
select
		co.continent_name,
        c.country_code,
        c.country_name,       
       round( avg(pc.gdp_per_capita),2) as avg_gdp_per_capital,		
       dense_rank() over(partition by co.continent_name order by round(avg(pc.gdp_per_capita),2)) as rnk
from continents co
join continent_map cm on cm.continent_code = co.continent_code 
join countries c on c.country_code = cm.country_code
join per_capital pc on pc.country_code = c.country_code
group by 1,2) as a
where a.rnk=1;

