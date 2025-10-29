-- Netflix Project -- 

Drop table if exists netflix;
create table netflix(
		show_id varchar(10),
		type varchar(10),
		title varchar(200),
		director varchar(220),
		casts varchar(1000), 
		country varchar(150),
		date_added varchar(50),
		release_year int,
		rating varchar(10),
		duration varchar(15),
		listed_in varchar(100),
		description varchar(250)
);

select * from netflix

select count(*) as total_content from netflix

select distinct type from netflix

-- Questions and solutions 

-- Ques1 -: Count the number of movies and TV shows?

select type ,count(*) as total_shows 
from netflix
group by type

-- Ques2 -:  Find the most comman rating for movies and tv shows?

select type , rating	
from(
	select type , rating ,count(*) ,
		rank() over(partition by type order by count(*) desc) as ranking
	from netflix 
	group by 1,2
) as t1
where ranking =1

-- Ques3 -: List all movies released in a specific year (eg - 2020) ?

select * from netflix
where type = 'Movie' and release_year = 2020

-- Ques4 -: Find the top 5 countries with the most content on Netflix?

Select unnest(string_to_array(country ,',')) , count(show_id) as totol_content
from netflix
group by 1
order by 2 desc
limit 5

-- Ques5 -: Identify the longest moive?

select title,  substring(duration, 1,position ('m' in duration)-1)::int duration
from Netflix
where type = 'Movie' and duration is not null
order by 2 desc

-- Ques6 -:Find content added in the last 5 years?

Select * from netflix
where to_date(date_added , 'month dd , yyyy') >= current_date - interval '5 years'


-- Ques7 -: Find all the movies / tv showsby director 'Rajiv Chalika' ?

select * from netflix 
where director ilike '%Rajiv Chilaka%'


-- Ques8 -: List all tv shows with more than 5 seasons

select * from netflix
where type = 'TV Show' and 
			 split_part(duration , ' ' , 1 ):: numeric > 5 


-- Ques9 -: count the number of content items in each genre?

select unnest(string_to_array (listed_in, ',')) as genre,
	   count(show_id )as total_content
from netflix
group by 1

-- Ques10 -: find each year and the average number of content release by India on Netflix , return top 5 year with highest avg content release ?

select extract(year from to_date(date_added , 'month dd , yyyy'))as year,
count(*),
round(count(*)::numeric/(select count(*) from netflix where country = 'India')*100 ,2)as avg_content_per_year
from netflix
where country = 'India'
group by 1 

-- Ques11 -: list all movies which are documentries

select * from netflix
where listed_in ilike '%documentaries%'


-- Ques12 -: Find all content without a director??

select * from netflix
where director is null

-- Ques13 -: Find how many moives actor 'Salman khan ' appeared in last 10 years ??

select * from netflix
where casts ilike '%salman khan%' and release_year > extract (year from current_date) - 10

--Ques14 -:Find the top 10 actor who appeared in the highest number of movies produced in india??

select 
	unnest (string_to_Array(casts ,','))as actors,
	count(*) as total_content
from netflix
where country ilike '%india%'
group by 1
order by 2 desc
limit 10

-- Ques15 -: categorize the content based on the presence of the keyword 'kill' and 'voilence' in the discription field. label content containing this keyword as 'Bad' and all other
--           content as 'good' . count how many itme fall in each category??


with new_table
as
(
Select * , 
		case 
		when description ilike '%kill%' or description ilike '%voilence%' then 'bad_content'
		else 'good_content'
		end category 
from netflix
)
select category , count(*) as total_content 
from new_table
group by 1