#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align --tuples-only -c"
#prompt user to enter username
echo -e "Enter your username: "
read USERNAME
USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
#check the presence of username in the database
if [[ -z $USER ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  ADD_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME',0,0)")
  GAMES_PLAYED=0
  BEST_GAME=1000
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
#create a random number and number of tries for the current game
NUMBER=$(($RANDOM % 1000 + 1))
TRIES=0
#main game function
MAIN() {
#increasing try counter
(( TRIES=TRIES+1 ))
#if returning from callbacks, print the message in the argument
if [[ $1 ]]
then
  echo -e "\n$1"
else
  echo -e "Guess the secret number between 1 and 1000:"
fi
#getting user's guessed number
read GUESS
#check if guessed number is an integer
if [[ ! $GUESS =~ ^[0-9]+$ ]]
then
  MAIN "That is not an integer, guess again:"
else
  #guessed number is an integer
  if [[ $GUESS == $NUMBER ]]
  then
    #guessed
    echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"
    (( GAMES_PLAYED=GAMES_PLAYED+1 ))
    UPDATE_GAME=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")
    #update best game
    if (( $BEST_GAME > $TRIES))
    then 
      UPDATE_BEST=$($PSQL "UPDATE users SET best_game = $TRIES WHERE username = '$USERNAME'")    
    fi 
  else
    #didn't guess
    if (( $GUESS < $NUMBER ))
    then
      MAIN "It's higher than that, guess again:"
    else
      MAIN "It's lower than that, guess again:"
    fi
  fi
fi
}
MAIN
