-- TABLE league_list: create league_list and change Russian Premier League's name in it because it's the same as the English one

CREATE TABLE league_list (
	id INTEGER,
	"name" VARCHAR(100),
	"type" VARCHAR(100),
	country_name VARCHAR(100),
	country_code VARCHAR(100),
)

INSERT INTO league_list (id, "name", "type", country_name, country_code)
SELECT *
FROM portfoliopjt2..leagues

UPDATE league_list
SET "name" = 'Premier League (RU)'
WHERE id = 235
GO

-- VIEW prediction_and_result: combine basic fixture information including goals (fixtures_goal.csv) and prediction data (fixtures_prediction.csv)

CREATE VIEW prediction_and_result AS (
	SELECT g.fixture_id, g.home_id, g.home_name, g.home_goals,
  		   h.form home_form, h.att home_att, h.def home_def, h.poisson_distribution home_poisson,
		   h.h2h home_h2h, h.goals home_goal_pred, h.total home_total_pred,
		   g.away_id, g.away_name, g.away_goals,
		   a.form away_form, a.att away_att, a.def away_def, a.poisson_distribution away_poisson,
		   a.h2h away_h2h, a.goals away_goal_pred, a.total away_total_pred
	FROM portfoliopjt2..fixtures_goal g
	LEFT JOIN portfoliopjt2..prediction as h
	ON g.fixture_id = h.fixture_id AND g.home_id = h.team_id
	LEFT JOIN portfoliopjt2..prediction as a
	ON g.fixture_id = a.fixture_id AND g.away_id = a.team_id)
GO


-- VIEW underdog_and_upset: take VIEW prediction_and_result and create a view that shows the prediction data, results and also which team was the underdog for each game

CREATE VIEW underdog_and_upset AS (
	SELECT fixture_id, home_id, home_name, FORMAT(CAST(left(home_total_pred,len(home_total_pred) - 1) as float) * .01, 'P') home_total_pred,
		   CAST(home_goals as int) home_goals, away_id, away_name, away_total_pred, CAST(away_goals as int) away_goals,
		   CASE WHEN home_total_pred < away_total_pred THEN home_id WHEN home_total_pred > away_total_pred THEN away_id END AS underdog_id,
		   CASE WHEN (home_total_pred < away_total_pred and home_goals > away_goals) or (home_total_pred > away_total_pred and home_goals < away_goals) THEN 1 END AS upset
	FROM prediction_and_result)
GO

-- VIEW team_list: create a list of all the teams that are within the scope of this analysis

CREATE TABLE team_list_temp (
	team_id INTEGER)

INSERT INTO team_list_temp (team_id)
SELECT DISTINCT home_id
FROM portfoliopjt2..fixtures_goal

INSERT INTO team_list_temp (team_id)
SELECT DISTINCT away_id
FROM portfoliopjt2..fixtures_goal
GO

CREATE VIEW team_list AS (
	SELECT DISTINCT t.team_id, g.home_name team_name, g.league_id, l."name" league_name
	FROM team_list_temp t
	LEFT JOIN portfoliopjt2..fixtures_goal g
	ON t.team_id = g.home_id
	LEFT JOIN league_list l
	ON g.league_id = l.id
	WHERE (g.home_name != 'Auxerre' or l."name" != 'Ligue 1') and (g.home_name != 'Hamburger SV' or l."name" != 'Bundesliga 1'))
	-- Auxerre and Hamburger SV, who were in 2nd tier league, had also 1st tier league data because they had promotion play-offs
GO


-- VIEW underdog_summary: number of times being underdogs, number of upsets and upset rate per team

CREATE VIEW underdog_summary AS (
	SELECT u.underdog_id, t.team_name team_name, t.league_id, t.league_name, count(*) num_being_underdog, sum(u.upset) AS num_upset, 
		   convert(decimal(5,2), sum(u.upset))/convert(decimal(5,2), count(*))*100 upset_rate
	FROM underdog_and_upset u
	JOIN team_list t
	ON u.underdog_id = t.team_id
	GROUP BY u.underdog_id, t.team_name, t.league_id, t.league_name)
GO

-- VIEW best_underdog_each_match: underdog team's best performer(s) for each match

CREATE VIEW best_underdog_each_match AS (
	SELECT a.*, t.player_id, t.player_name, t.position
	FROM (
		SELECT u.fixture_id, u.underdog_id, t.team_name, t.league_id, t.league_name,
			CASE WHEN u.underdog_id = u.home_id THEN u.away_name 
			WHEN u.underdog_id = u.away_id THEN u.home_name
			ELSE NULL END AS against,
			u.upset,
			cast(max(s.rating) as float) max_rating
		FROM underdog_and_upset u
		LEFT JOIN team_list t
		ON u.underdog_id = t.team_id
		LEFT JOIN portfoliopjt2..player_stats_total s
		ON u.underdog_id = s.team_id and u.fixture_id = s.fixture_id
		GROUP BY u.fixture_id, u.underdog_id, t.team_name, t.league_id, t.league_name, u.home_id, u.away_id, u.away_name, u.home_name, u.upset
		HAVING u.underdog_id IS NOT NULL) a
	LEFT JOIN portfoliopjt2..player_stats_total t
	ON a.fixture_id = t.fixture_id and a.underdog_id = t.team_id and a.max_rating = t.rating)
GO

ALTER TABLE portfoliopjt2..standings_season_2021
ALTER COLUMN "rank" int
GO

-- Ananlysis result
-- 1) number of times each player was the best player when his team was an underdog
-- 2) and the average of his ratings in the matches where his team was an underdog and he was the best player of his team
-- make sure to save it as csv under the name 'best_underdog_players_season_xxxx.csv' so that it can be used for Python api data extraction part 2

SELECT t.team_id, t.team_name, t.league_id, t.league_name,
	u.num_best_underdog, u.avg_rating, u.player_id, u.player_name, u.position
FROM (
	SELECT underdog_id, team_name, count(max_rating) num_best_underdog, avg(max_rating) avg_rating, 
		player_id, player_name, position
	FROM best_underdog_each_match
	GROUP BY underdog_id, team_name, player_id, player_name, position) u
LEFT JOIN team_list t
ON u.underdog_id = t.team_id
ORDER BY u.num_best_underdog DESC, u.avg_rating DESC
