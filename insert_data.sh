#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
$PSQL "TRUNCATE games, teams RESTART IDENTITY"

tail -n +2 games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WIN_GOALS OPP_GOALS
do
     WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  WINNER_ID=$(echo $WINNER_ID | xargs)

  if [[ -z $WINNER_ID ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$WINNER')"
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    WINNER_ID=$(echo $WINNER_ID | xargs)
  fi

  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  OPPONENT_ID=$(echo $OPPONENT_ID | xargs)

  if [[ -z $OPPONENT_ID ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')"
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    OPPONENT_ID=$(echo $OPPONENT_ID | xargs)
  fi

  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
  VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WIN_GOALS, $OPP_GOALS)"

done
