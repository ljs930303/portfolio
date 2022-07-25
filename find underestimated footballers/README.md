# Find underestimated footballers

Let's say you are the owner or the manager of a small/mid-size football club in Europe.

Your club can't afford to splash plenty of cash to sign famous top-class players, so you need to find affordable and underestimated players who are in a weaker team, excellent in record, yet not super famous in media.

This project helps you find those underestimated players by finding the players who performed the best when encountered with stronger teams, that is, when his team were an underdog. To be more precise, it works like this:
1. get the underdog team for each fixture in season 2021
2. get the best performing player of the underdog team and his rating for each fixture
3. count how many times each player has been the best performing player of the underdog team ("num_best_underdog" column) and get the average of his ratings for the fixtures where he was the best performing player of the underdog team ("avg_rating" column)
4. sort the rows in a descending order by the aforementioned "num_best_underdog" and "avg_rating" columns

By doing so, you can find the best players of weaker teams on the top of the result table because, in order for a player to be the best performing player of the underdog team many times, his team needs to be underdog in many fixtures too.

# Programs used

This project uses Python for API data extraction and Microsoft SQL Server for analysis.

