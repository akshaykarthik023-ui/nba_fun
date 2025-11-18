SELECT player_name
FROM all_seasons2
ORDER BY team_abbreviation
LIMIT 20;

#Ranking players in each season by points
SELECT season,player_name,pts,
RANK() OVER(PARTITION BY season ORDER BY pts DESC) AS player_rank
FROM all_seasons2;

#Ranking players in each season by rebounds
SELECT season,player_name,reb,
RANK() OVER(PARTITION BY season ORDER BY reb DESC) AS player_rank
FROM all_seasons2;

#Ranking players in each season by assists
SELECT season,player_name,ast,
RANK() OVER(PARTITION BY season ORDER BY ast DESC) AS player_rank
FROM all_seasons2;



#segmenting and aggregating to know whether volume scorers sacrifice efficiency.
SELECT Usage_tier,AVG(ts_pct)
FROM 
(
SELECT player_name,usg_pct,ts_pct,
CASE
	WHEN usg_pct >= .250 THEN 'high volume'
    WHEN usg_pct >= .120 THEN 'medium volume'
    ELSE 'low volume'
END AS Usage_tier,

CASE 
	WHEN ts_pct >= .8 THEN 'high efficiency'
    WHEN ts_pct >= .4 THEN 'medium effieciency'
    ELSE 'low efficiency'
END AS Ts_tier
FROM all_seasons2) AS T
GROUP BY Usage_tier;


#only one guy has high volume and high efficiency
#most of the players are in medium volume and medium efficiency
#almost all high volume scorers have medium efficiency
#while extremely high volume slightly hurts efficiency compared to medium volume/n
#the largest difference is between the Medium/High tiers and the Low tier.

#most improved players across seasons(points,rebound,assists)
SELECT player_name,team_abbreviation,season,pts,(pts - previous_pts) AS improvement
FROM (
SELECT player_name,season,pts,team_abbreviation,
LAG(pts,1) OVER(PARTITION BY player_name ORDER BY season ASC) AS previous_pts
FROM all_Seasons2
) AS T
WHERE previous_pts IS NOT NULL
ORDER BY 
        improvement DESC
        LIMIT 5;

#Marshon brooks points improved a 15.6 points than previous year,thats the most points improved for a player.

SELECT player_name,season,team_abbreviation,reb,(reb-previous_reb) AS improvement
FROM
(
SELECT player_name,reb,season,team_abbreviation,
LAG(reb) OVER(PARTITION BY player_name ORDER BY season DESC) AS previous_reb
FROM all_seasons2
)AS T
WHERE previous_reb IS NOT NULL
ORDER BY improvement DESC
LIMIT 5;

#Hassan whiteside improved the most in rebounds: 6.6

SELECT player_name,season,ast,(ast-previous_ast) AS improvement
FROM(
SELECT player_name,season,ast,
LAG(ast) OVER(PARTITION BY player_name) AS previous_ast
FROM all_seasons2
)AS T
WHERE previous_ast IS NOT NULL
ORDER BY improvement DESC; 

#Rod strickland improved the most in assists: 4.9

#Comparing average player size across decades

SELECT (starting_year - (starting_year % 10)) AS starting_decade,ROUND(AVG(player_height),2) AS av_height,ROUND(AVG(player_weight),2) AS av_weight
FROM (
SELECT season,player_height,player_weight,
		CAST(SUBSTRING(season,1,4)AS SIGNED) AS starting_year
FROM all_seasons2
)AS T
GROUP BY STARTING_DECADE;

#IN THE 1990'S height : 200.86,weight: 100.54
#In the 2000's height : 201.04,weight: 101.36
#In the 2010's height : 200.6, weight: 100.01
#In the 2020's height : 198.82, weight: 97.78

#Identifying which teams consistently produce high performing players

#defining a top performer : (points + rebounds + assists / Games_played) + net_rating
#using nested sub query to get rank(),make new temporary tables and filter from that to 
#get the top players producing team.
SELECT team_abbreviation,COUNT(*) AS count_best_team
FROM(
SELECT season,team_abbreviation,COUNT(*) AS best_team
FROM (
SELECT season,player_name,team_abbreviation,top_player,
RANK() OVER(PARTITION BY season ORDER BY top_player desc) AS tps
FROM(
SELECT season,player_name,team_abbreviation,ROUND(((pts + reb + ast * 0.1 / gp) + net_rating),2) AS top_player
FROM all_seasons2) AS P
) AS T
WHERE tps <= 25
GROUP BY season,team_abbreviation
) AS S
GROUP BY team_abbreviation
ORDER BY count_best_team desc;

#So the team that produced the most top performers are SAS(23),LAL(22),POR(20),UTA(19),HOU(19),DAL(19)

#Looking at rookies vs veterans - how do their contributions differ?
#defining rookies,veterans and amateurs.
SELECT season,player_definition,ROUND(AVG(usg_pct),2) AS useful,ROUND(AVG(ast_pct),2) AS ast ,ROUND(AVG(net_rating),2)AS net_rating
FROM (
	SELECT player_name,draft_year,season,usg_pct,ast_pct,net_rating,
    CASE 
		WHEN draft_year = CAST(SUBSTRING(season,1,4) AS SIGNED) THEN 'ROOKIE'
        WHEN CAST(SUBSTRING(season,1,4) AS SIGNED) - draft_year >=5 THEN 'VETERAN'
        ELSE 'AMATEUR'
	END AS player_definition
    FROM all_seasons2
) AS T
WHERE player_definition != 'AMATEUR'
GROUP BY season,player_definition
ORDER BY ast DESC;

#the usage_pct is better in rookie as the first 9 best useful are rookies.
#but assist and net_rating are better in veteran players.


#using a weighted index to find the mvp for a given season.
#i am going to give 40% to points,30% to rebound + assist,30% to true shooting
# the equation is : (0.40 * pts / gp) + (0.30 * reb+ast / gp) + (0.30 * ts%)
#dividing py games played to normalize and give equal oppurtunity for all players.

WITH ranked_players AS(
SELECT season,player_name,((0.40 * pts / gp) + (0.30 * reb+ast / gp) + (0.30 * ts_pct)) AS total_points,
RANK() OVER(PARTITION BY season ORDER BY ((0.40 * pts / gp) + (0.30 * reb+ast / gp) + (0.30 * ts_pct)) DESC)
AS MVP_RANK
FROM all_seasons2
WHERE gp >= 50
)

SELECT season,player_name,total_points,MVP_RANK
FROM ranked_players
WHERE MVP_RANK = 1
ORDER BY season;
