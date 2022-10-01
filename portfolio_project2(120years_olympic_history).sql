/* PORTFOLIO PROJECT
   
   Dataset Name:120 years of Olympic history: athletes and results
           This is a historical dataset on the modern Olympic Games, including all the Games from Athens 1896 to Rio 2016.
   Dataset source: Kaggle
   link: https://www.kaggle.com/datasets/heesoo37/120-years-of-olympic-history-athletes-and-results?select=athlete_events.csv
   
   Schema: portfolio_project
   table1: athlete_events
   |  Column name  |  type  |
   +---------------+--------+
   |    ID         |  int   |
   |    Name       | varchar|
   |    Sex        | varchar|
   |    Age        | varchar|
   |    Height	   | varchar|
   |    Weight     | varchar|
   |    Team 	   | varchar|
   |    NOC  	   | varchar|
   |	Games 	   | varchar|
   |	Year 	   |  int   |
   |	Season     | varchar|
   |	City  	   | varchar|
   |	Sport      | varchar|
   |	Event 	   | varchar|
   |	Medal 	   | varchar|
   +---------------+--------+
   
   table2: noc_region
   |  Column name  |  type  |
   +---------------+--------+
   |   NOC         | varchar|
   |  region       | varchar|
   |  notes        | varchar|
   +---------------+--------+  */
   
   
select count(*)from athlete_events; -- gives total number of rows in aathlete_events
select top(10)*from athlete_events; -- gives structure of table and first 10 rows
   
select count(*)from noc_regions;  -- gives total number of rows in noc_regions
select top(10)*from noc_regions;  -- gives structure of table and first 10 rows
   

-- Question1: Write an SQL query to find the total number of Olympic Games held as per the dataset.
select count(distinct games) as total_olympic_games
from athlete_events;


-- Question2: Write an SQL query to list down all the Olympic Games held so far.
select distinct(games),city
from athlete_events;


-- Question3: write an SQL query to fetch total no of countries participated in each olympic games.
Select Games,Count(Distinct NOC) as number_of_countries_paricipated
From athlete_events
Group By Games Order By Games;


-- Question4: Write an SQL query to return the Olympic Games which had the highest participating countries and
--            the lowest participating countries.
with cte_countries (games,total_countries)as
(Select Games,Count(Distinct NOC)
From athlete_events
Group By Games)
select distinct
      concat(first_value(games) over(order by total_countries asc)
      , ' - ', first_value(total_countries) over(order by total_countries asc)) as Lowest_Country_paricipation,
      concat(first_value(games) over(order by total_countries desc)
      , ' - ',first_value(total_countries) over(order by total_countries desc)) as Highest_Country_paricipation
      from cte_countries
      order by Lowest_Country_paricipation;


-- Question5: write an SQL query to return the list of countries who have been part of every Olympics games.
Select nr.Region,Count(Distinct Games) as num_of_olympics_games
From athlete_events ae
Join noc_regions nr ON ae.NOC = nr.NOC
Group By nr.Region
Having Count(Distinct Games) = (Select Count(Distinct Games) From athlete_events)
Order By Count(Distinct Games) Desc;


-- Question6: Write an SQL query to fetch the list of all sports which have been part of every summer olympics.
with cte_games As
	(Select Distinct Sport,Games
	 From athlete_events 
	 Where Season = 'Summer')
Select sport,count(games) as no_of_olympics_games 
From cte_games 
group by Sport
having count(games)=(Select count(Distinct Games)From athlete_events Where Season = 'Summer')
order by Sport;


-- Question7: Write an SQL query to identify the sports which were just played once in any of olympics.
with cte_sports (sports, num_played) as
	(Select Sport,Count(Distinct Games) 
	 From athlete_events
	 Group By Sport
	 Having Count(Distinct Games) = 1),
cte_games (games,sports2)as
	(Select Distinct Games,Sport 
	 From athlete_events)
select s.sports, g.games
from cte_sports s
join cte_games g
on s.sports=g.sports2
order by sports;


-- Question8: Write an SQL query to fetch the total no of sports played in each olympics.
select distinct games, count(distinct sport) as num_of_sports_played
from athlete_events
group by games
order by num_of_sports_played desc;


-- Question9: Write an SQL query to fetch the top 5 athletes who have won the most gold medals.
with cte_table1 as
	(select name,count(name) as gold_medels
	 from athlete_events
	 where medal='Gold'
	 group by name),
cte_table2 as
	(select*,
	 DENSE_RANK() over (order by gold_medels desc) as rank
	 from cte_table1)
select*from cte_table2 where rank <= 5;


-- Question10: Write an SQL Query to fetch the top 5 athletes who have won the most medals (Medals include gold, silver and bronze).
with cte_table1 as
	(select name,count(name) as medels
	 from athlete_events
	 where medal!='NA'
	 group by name),
cte_table2 as
	(select*,
	 DENSE_RANK() over (order by medels desc) as rank
	 from cte_table1)
select*from cte_table2 where rank <= 5;


-- Question11: Write a SQL query to fetch the top 5 countries by the number of medals won in olympics.
with cte_table1 as
	(select nr.region, count(1) as total_medals
	 from athlete_events ae
	 join noc_regions nr on nr.noc = ae.noc
	 where medal != 'NA'
	 group by nr.region),
cte_table2 as
	(select *, dense_rank() over(order by total_medals desc) as rank
	 from cte_table1)
select *
from cte_table2 where rank <= 5;


-- Question12: Write an SQL query to list down the  total gold, silver and bronze medals won by each country.
Select nr.Region as country,
	sum(case when medal='Gold' then 1 else 0 end) as gold_medals,
	sum(case when medal='Silver' then 1 else 0 end) as silver_medals,
	sum(case when medal='Bronze' then 1 else 0 end) as bronze_medals
from athlete_events ae
Join noc_regions nr On nr.NOC = ae.NOC
Group by nr.Region
Order By gold_medals Desc


-- Question13: Write an SQL Query to fetch details of countries which have never won a gold medal.
with cte_table (country,gold_medals) as
	(Select nr.Region,
	 sum(case when medal='Gold' then 1 else 0 end)
	 from athlete_events ae
	 Join noc_regions nr On nr.NOC = ae.NOC
	 Group by nr.Region)
select*from cte_table 
where gold_medals=0;


-- Question14: Write an SQL Query to return the sport in which India has won the highest no of medals.
with cte_table1 as(
	select sport,count(distinct Games) as medals 
	from athlete_events 
	where team='india' and medal<>'NA'
	group by sport),
cte_table2 as(
	select *,rank() over(order by medals desc) as rank 
	from cte_table1)
select sport,medals from cte_table2 where rank=1