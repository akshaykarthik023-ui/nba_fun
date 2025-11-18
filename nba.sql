SELECT COUNT(*)
FROM all_seasons2; -- 12844

 -- Ranking players in each season by points 
 
SELECT season,
	player_name,
    pts,
    player_rank
FROM (SELECT season,
			player_name,
            pts,
	RANK() OVER(PARTITION BY season ORDER BY pts DESC) AS player_rank
    FROM all_seasons2) AS T
	WHERE player_rank <=5
    ORDER BY pts DESC;
   

 -- Ranking players in each season by rebounds 
 
SELECT season,
	player_name,
	reb,
    player_rank
FROM(SELECT season,
			player_name,
            reb,
	RANK() OVER(PARTITION BY season ORDER BY reb DESC) AS player_rank
FROM all_seasons2)AS T
WHERE player_rank <=5
ORDER BY reb DESC;

-- Ranking players in each season by assists 

SELECT season,
	player_name,
	ast,
    player_rank
FROM(SELECT season,
				player_name,
                ast,
	RANK() OVER(PARTITION BY season ORDER BY ast DESC) AS player_rank
FROM all_seasons2)AS T
WHERE player_rank <= 5
ORDER BY ast DESC;




-- segmenting and aggregating to know whether volume scorers sacrifice efficiency. 

SELECT COUNT(player_name) AS number_of_players,
	Usage_tier,
	Round(AVG(ts_pct),2) AS average_efficiency,
	Ts_tier
FROM 
(
SELECT player_name,
	usg_pct,
    ts_pct,
CASE
	WHEN usg_pct >= .270 THEN 'high volume'
    WHEN usg_pct >= .120 THEN 'medium volume'
    ELSE 'low volume'
END AS Usage_tier,

CASE 
	WHEN ts_pct >= .8 THEN 'high efficiency'
    WHEN ts_pct >= .4 THEN 'medium effieciency'
    ELSE 'low efficiency'
END AS Ts_tier
FROM all_seasons2) AS T
GROUP BY Usage_tier,Ts_tier
ORDER BY number_of_players DESC;


/* 
10209 players are of medium volume and medium efficiency,
majority of high volume scorers have medium efficiency,
There are only 6 high volume and high efficiency players,
majority of high efficiency players have low to medium volume.
so we can conclude that since only 0.05% of players are in high volume high efficiency category,
79.48% are in medium volume medium efficiency category,5.71% are in high volume medium efficiency category,
there is a trade off between high volume and high efficiency.

*/

-- Biggest improvement in points.

SELECT player_name,
	team_abbreviation,
	season,
	pts,
	(pts - previous_pts) AS improvement
FROM (
SELECT player_name,
	season,
    pts,
    team_abbreviation,
	LAG(pts,1) OVER(PARTITION BY player_name ORDER BY season ASC) AS previous_pts
FROM all_Seasons2
) AS T
WHERE previous_pts IS NOT NULL
ORDER BY 
        improvement DESC
        LIMIT 5;

/* Marshon brooks points improved a 15.60 points than previous year,thats the most points improved for a player,
  Louis King scored an impressive 15.5 improvement score and Jakkar sampson who scored 15.3.*/

-- Biggest improvement in rebounds.

SELECT player_name,
	season,
	team_abbreviation,
	reb,
	(reb-previous_reb) AS improvement
FROM
(
SELECT player_name,
	reb,
	season,
    team_abbreviation,
	LAG(reb) OVER(PARTITION BY player_name ORDER BY season DESC) AS previous_reb
FROM all_seasons2
)AS T
WHERE previous_reb IS NOT NULL
ORDER BY improvement DESC
LIMIT 5;

-- Hassan whiteside improved the most in rebounds: 6.6,second is Earl Barron : 7.4

-- Biggest improvement in assists.

SELECT player_name,
	season,
	ast,
	(ast - previous_ast) AS improvement
FROM(
SELECT player_name,
	season,
    ast,
	LAG(ast) OVER(PARTITION BY player_name) AS previous_ast
FROM all_seasons2
)AS T
WHERE previous_ast IS NOT NULL
ORDER BY improvement DESC; 

-- Rod strickland improved the most in assists: 4.9,second is Robert Pack: 7.4



-- Comparing average player size across decades

SELECT (starting_year - (starting_year % 10)) AS starting_decade,
       ROUND(AVG(player_height),2) AS av_height,
	   ROUND(AVG(player_weight),2) AS av_weight
FROM (
SELECT season,player_height,player_weight,
		CAST(SUBSTRING(season,1,4)AS SIGNED) AS starting_year
FROM all_seasons2
)AS T
GROUP BY STARTING_DECADE;

/* IN THE 1990'S height : 200.86,weight: 100.54
In the 2000's height : 201.04,weight: 101.36
In the 2010's height : 200.6, weight: 100.01
In the 2020's height : 198.82, weight: 97.78 */

-- Identifying which teams consistently produce high performing players

/* defining a top performer : (points/gp + rebounds/gp + assists / gp) + net_rating
using nested sub query to get rank(),make new temporary tables and filter from that to 
get the top most player producing team.*/

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

-- So the team that produced the most top performers are SAS(23),LAL(22),POR(20),UTA(19),HOU(19),DAL(19)



-- Looking at rookies vs veterans - how do their contributions differ?

-- defining rookies,veterans and amateurs.
SELECT 
    player_definition,
    ROUND(AVG(usg_pct), 2) AS useful,
    ROUND(AVG(ast_pct), 2) AS ast,
    ROUND(AVG(net_rating), 2) AS net_rating,
    ROUND(AVG(pts),2) AS average_points,
    ROUND(AVG(reb),2) AS average_rebounds
FROM (
	SELECT player_name,
		draft_year,
        season,
        usg_pct,
        ast_pct,
        net_rating,
        pts,
        reb,
		CASE 
			WHEN draft_year = CAST(SUBSTRING(season,1,4) AS SIGNED) THEN 'ROOKIE'
			WHEN CAST(SUBSTRING(season,1,4) AS SIGNED) - draft_year >=5 THEN 'VETERAN'
			ELSE 'AMATEUR'
		END AS player_definition
    FROM all_seasons2
) AS T
WHERE player_definition != 'AMATEUR'
GROUP BY player_definition
ORDER BY average_points DESC;

/* Veterans average in points is 8.25 and rookies is 5.68, theres a big difference there,
	then the average rebounds of veterans are 3.59 and for rookies are 2.59, also
    the assist is 0.14 for veterans and 0.12 for rookies.So expereince does make a differenece.*/



-- using a weighted index to find the mvp for a given season.


WITH ranked_players AS(
SELECT season,
	player_name,
    ((0.50 * pts / gp) + (0.20 * reb/ gp) + (0.20 * ast/ gp) + (net_rating * 0.05) + (0.05* (ts_pct * 50))) AS total_points,
	RANK() OVER(PARTITION BY season ORDER BY ((0.50 * pts / gp) + (0.20 * reb/ gp) + (0.20 * ast/ gp) + (net_rating * 0.05) + (0.05* (ts_pct* 50))) DESC)
	AS MVP_RANK
FROM all_seasons2
WHERE gp >= 50
)

SELECT season,
	player_name,
    total_points,
    MVP_RANK
FROM ranked_players
WHERE MVP_RANK = 1
ORDER BY season;



-- Build your dream starting 5 (PG, SG, SF, PF, C) using stats across all seasons.

-- Each position demands better skills for specific areas, so those specific skills should get more importance.
WITH position_points AS(

SELECT player_name,
	((ast/gp * 3.0 ) + ((ast_pct * 100) * 1.5) + (pts/gp) + (ts_pct * 75) + net_rating) AS pg,
	((pts/gp * 5.0) + ((usg_pct * 100) * 2.0) + (ts_pct * 75))AS sg,
	((pts/gp) * 2.0) + ((reb/gp) * 1.5) + ((ast/gp) * 1.5) +  (ts_pct * 75) +  (net_rating * 1.5) AS sf,
	((reb/gp) * 2.5 + (ast/gp) + ((dreb_pct * 100) * 2.0)+ (pts/gp* 1.5) + (net_rating * 2.0)) AS pf,
	((pts/gp) * 5.0) + ((reb/gp) * 1.5) + (oreb_pct * 100 * 1.0) + (dreb_pct * 100 * 1.0) +  (ts_pct * 100) AS c
FROM all_seasons2
WHERE gp >= 50
),
#assigning  1st rank to highest score for each position
ranked_players AS (
SELECT player_name,
	pg,
    sg,
    sf,
    pf,
    c,
	ROW_NUMBER() OVER(ORDER BY pg DESC) AS pg_rank,
	ROW_NUMBER() OVER(ORDER BY sg DESC)AS sg_rank,
	ROW_NUMBER() OVER(ORDER BY sf DESC)AS sf_rank,
	ROW_NUMBER() OVER(ORDER BY pf DESC)AS pf_rank,
	ROW_NUMBER() OVER(ORDER BY c DESC)AS c_rank
FROM position_points
)

#selecting player with rank 1 for each position
SELECT 'Point Guard' AS position,
	player_name,
    pg AS score
FROM ranked_players
WHERE pg_rank = 1 
UNION ALL #Combining results of multiple select statements.


SELECT 'Shooting Guard' AS position,
	player_name,
    sg AS score
FROM ranked_players
WHERE sg_rank = 1
UNION ALL

SELECT 'Small Forward' AS position,
	player_name,
    sf AS score
FROM ranked_players
WHERE sf_rank = 1
UNION ALL

SELECT 'Power Forward' AS position,
	player_name,
    pf AS score
FROM ranked_players
WHERE pf_rank = 1
UNION ALL

SELECT 'Center' AS position,
	player_name,
    c AS score
FROM ranked_players
WHERE c_rank = 1;

/*STEVE NASH as point gaurd,
James Harden as shooting gaurd,
stephen curry as small forward,
dennis rodman as power forward,
rudy gobert as center.*/
