#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
# insert teams table
 if [[ $WINNER != "winner" ]]
  then

    # get team_id
    TEAM1_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # if not found
    if [[ -z $TEAM1_ID ]]
    then
      # insert team name
      INSERT_TEAM1_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM1_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
      # get new team_id
      TEAM1_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # get team_id
    TEAM2_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if not found
    if [[ -z $TEAM2_ID ]]
    then
      # insert team name
      INSERT_TEAM2_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM2_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
      # get new team_id
      TEAM2_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

# insert games table
  # get game_id
    GAME_ID=$($PSQL "SELECT * FROM games LEFT JOIN teams ON teams.team_id=games.opponent_id WHERE year=$YEAR AND winner_id=$TEAM1_ID AND opponent_id=$TEAM2_ID")
    # if not found
    if [[ -z $GAME_ID ]]
    then
      # insert year, round, winner_id, opponent_id, winner_goals, opponent_goals
      INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR,'$ROUND', $TEAM1_ID, $TEAM2_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      if [[ $INSERT_GAME == "INSERT 0 1" ]]
      then
        echo Inserted into games, $YEAR, $ROUND, $TEAM, $TEAM, $WINNER_GOALS, $OPPONENT_GOALS
      fi
     
       # get new game_id
       GAME_ID=$($PSQL "SELECT game_id FROM games INNER JOIN teams ON teams.team_id=games.opponent_id WHERE year='$YEAR' AND winner_id=$TEAM1_ID AND opponent_id=$TEAM2_ID")
fi
fi
done
