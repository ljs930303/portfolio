# Find underestimated footballers

You are the owner or the manager of a small/mid-size football club in Europe.

Your club can't afford to splash plenty of cash to sign famous top-class players, so you need to find affordable and underestimated players who are in a weaker team, excellent in record, yet not super famous in media.

This project helps you find those underestimated players by finding the players who performed the best when encountered with stronger teams, that is, when his team were an underdog. To be more precise, it works like this:
1. get the underdog team for each fixture in season 2021
2. get the best performing player of the underdog team and his rating for each fixture
3. count how many times each player has been the best performing player of the underdog team ("num_best_underdog" column) and get the average of his ratings for the fixtures where he was the best performing player of the underdog team ("avg_rating" column)
4. sort the rows in a descending order by the aforementioned "num_best_underdog" and "avg_rating" columns

By doing so, you can find the best players of weaker teams on the top of the result table because, in order for a player to be the best performing player of the underdog team many times, his team needs to be underdog in many fixtures too.

The analysis scope is limited to top two leagues of top 5 countries and top league of the next 5 countries according to UEFA country coefficients 2021/2022 - total 15 leagues.

Conclusion and some exemplary findings are summarized in _<5) Analysis result.pdf>_

# Programs used

This project uses Python for API data extraction and Microsoft SQL Server for analysis.

You need to run file number 1 to 4 in an numerical order to get the right result at the end of _<4) SQL analysis - part 2.sql>_.
API data extraction process and analysis process are divided in two parts each because otherwise API data extraction process would waste too much time on gathering needless data.
That is, part 1 of API data extraction process (Python) gets data for entire population, part 1 of analysis process (SQL) keeps only the best underdogs who are worth further analysis, part 2 of API data extraction process (Python) gets additional data for the best underdogs, and part 2 of analysis process (SQL) conducts final analysis on them and display the end result.
