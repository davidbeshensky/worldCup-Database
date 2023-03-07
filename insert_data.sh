#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "Inserting unique team names into teams table..."
cat games.csv | awk -F, 'NR>1{print $3"\n"$4}' | sort -u | while read team
do
  $PSQL "INSERT INTO teams (name) SELECT '${team}' WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name = '${team}')"
done

echo "Done."
echo "Inserting games from games.csv into games table"
tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  WINNER_ID=`$PSQL "SELECT team_id FROM teams WHERE name = '${WINNER}'"`
  OPPONENT_ID=`$PSQL "SELECT team_id FROM teams WHERE name = '${OPPONENT}'"`
  $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES (${YEAR}, '${ROUND}', ${WINNER_ID}, ${OPPONENT_ID}, ${WINNER_GOALS}, ${OPPONENT_GOALS})"
done

echo "Done."
