🏀 NBA Player Performance Analysis (1996 - 2023)
        
📘 Project Overview

        Using MYSQL I have analysed 12844 records of nba players from season 1996 to 2023.
		
🎯 Objectives

		1.Player Performance Analysis

			1. Rank players in each season by points, rebounds, assists per game.

			2. Compare efficiency stats (TS% vs usage%) - do volume scorers sacrifice efficiency?

			3. Identify most improved players across seasons (biggest jump in points/rebounds/assists).
			
		2.Era & Team Comparisons

			4. Compare average player size (height/weight) between 1990s, 2000s, 2010s, and 2020s.

			5. Identify which teams consistently produce top-performing players.

			6. Look at rookies vs veterans - how do their contributions differ?

		3.MVP & Dream Team

			7. Use a weighted index (e.g., 40% points, 30% rebounds/assists, 30% efficiency) to find an MVP for a given season.

			8. Build your dream starting 5 (PG, SG, SF, PF, C) using stats across all seasons.
			
🧠 Tools Used

		1.MySQL Workbench
		2.Excel (Only used excel to remove undrafted player rows from the data.)

🧠 Skills Demonstrated

		1.Data inspection and cleaning
		2.Window functions (RANK, LAG, PARTITION BY,ROW_NUMBER)
		3.CTEs and subqueries
		4.segmentation and aggregation
		5.Comparative analysis
		6.Trend analysis
		7.Time series analysis

		
📈 Key Insights

	1.  Rank players in each season by points, rebounds, assists per game.
	
		1.Most points ever scored in a single season is by James Harden(36.1 points) Followed by Kobe Bryant(35.4)
		2.Most rebounds : Danny Fortson(16.3) Followed by Dennis Rodman(16.1)
		3.Most assists : Rajon Rando and Russel WestBrook both 11.7 each.
		
	2. 	Compare efficiency stats (TS% vs usage%) - do volume scorers sacrifice efficiency?

		1.10209 players are in medium volume-medium efficiency
		2.Majority of high volume scorers have medium efficiency
		3.only 0.05% of players are in high volume-high efficiency category
		4.79.48% are in medium volume-medium efficiency category
		5.5.71% are in high volume-medium efficiency category
		
		Conclusion: Volume does sacrifices efficiency but not that much,majority are in medium volume-medium efficiency range.

	3. Identify most improved players across seasons (biggest jump in points/rebounds/assists).

	   1.Marshon brooks points improved a 15.60 points than previous year,thats the most points improved for a player
	   2.Louis King scored an impressive 15.5 improvement score and Jakkar sampson who scored 15.3.
	   3.Hassan whiteside improved the most in rebounds: 6.6,second is Earl Barron : 7.4
	   4.Rod strickland improved the most in assists: 4.9,second is Robert Pack: 7.4

	4. Compare average player size (height/weight) between 1990s, 2000s, 2010s, and 2020s.

	   1.IN THE 1990'S height : 200.86,weight: 100.54
	   2.In the 2000's height : 201.04,weight: 101.36
	   3.In the 2010's height : 200.6, weight: 100.01
	   4.In the 2020's height : 198.82, weight: 97.78
	   
	   Conclusion: players average height and weight decreased in 2020.

	5.  Identify which teams consistently produce top-performing players.
	
	   1.Teams that produced the most top performers are 
	   SAS(23),
	   LAL(22),
	   POR(20),
	   UTA(19),
	   HOU(19),
	   DAL(19)
	   
	   Conclusion: Some teams does produce more great players than majority of other teams.

    6. Look at rookies vs veterans - how do their contributions differ?

	  1. Veterans average in points is 8.25 and rookies is 5.68, theres a big difference there
	  2. Average rebounds of veterans are 3.59 and for rookies are 2.59
	  3. Assist is 0.14 for veterans and 0.12 for rookies.
	  
	  Conclusion: Experience does make a difference.

	7. Use a weighted index (e.g., 40% points, 30% rebounds/assists, 30% efficiency) to find an MVP for a given season.

	  1.steph curry : 4 MVP's 
	  2.shaquilee O'Neal : 2 times
	  3.Lebron James : 3 times

	8. Build your dream starting 5 (PG, SG, SF, PF, C) using stats across all seasons.

	  1. Steve Nash as point gaurd
      2. James Harden as shooting gaurd
      3. Stephen curry as small forward 
	  4. Dennis rodman as power forward
      5. Rudy gobert as center
	

	

