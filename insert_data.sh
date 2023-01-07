#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #find the winner id, insert team into teams(name)
  if [[ $WINNER != winner ]]
  then
     WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
     if [[ -z $WINNER_ID ]]
     then
       INSERT_TEAM_WIN=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
       WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
     fi
  fi
  #find the opponent id, insert team into teams(name)
  if [[ $OPPONENT != opponent ]]
  then
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
  fi
  #insert all with year as guide
  #insert year
  if [[ $YEAR != year ]]
  then
    DATA_INS=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done
