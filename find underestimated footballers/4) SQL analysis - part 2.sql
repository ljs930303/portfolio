-- final result: age and transfer data added to the end result of SQL analysis part 1

CREATE VIEW final_2021_temp AS (
	SELECT t.team_id, t.team_name, t.league_id, t.league_name,
		u.num_best_underdog, u.avg_rating, u.player_id, u.player_name, u.position,
		age2021.age, tf2021."date" transfer_date, tf2021."type" transfer_type, tf2021.new_team_id, tf2021.new_team_name,
		ROW_NUMBER() OVER (PARTITION BY u.player_id, u.position, t.league_id ORDER BY u.player_id) rn
		/* "rn" column to delete duplicate rows */
	FROM (
		SELECT underdog_id, team_name, count(max_rating) num_best_underdog, avg(max_rating) avg_rating, 
			player_id, player_name, position
		FROM best_underdog_each_match
		GROUP BY underdog_id, team_name, player_id, player_name, position) u
	LEFT JOIN team_list t
	ON u.underdog_id = t.team_id
	LEFT JOIN portfoliopjt2..transfer_season_2021 tf2021
	ON u.player_id = tf2021.player_id
	LEFT JOIN portfoliopjt2..age_season_2021 age2021
	ON u.player_id = age2021.player_id)
GO

SELECT *
INTO final_2021
FROM final_2021_temp

DELETE FROM final_2021 WHERE rn > 1

ALTER TABLE final_2021
DROP COLUMN rn

-- add standings data

SELECT f.team_id, f.team_name, f.league_name, s."rank", f.num_best_underdog, f.avg_rating, f.player_id, f.player_name, f.position, f.age,
	f.transfer_date, f.transfer_type, f.new_team_id, f.new_team_name, t.league_name new_team_league, s1."rank" new_team_rank
FROM final_2021 f
LEFT JOIN portfoliopjt2..standings_season_2021 s
ON f.team_id = s.team_id
LEFT JOIN portfoliopjt2..standings_season_2021 s1
ON f.new_team_id = s1.team_id
LEFT JOIN team_list t
ON f.new_team_id = t.team_id
ORDER BY num_best_underdog DESC, avg_rating DESC
