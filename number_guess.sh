#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

NUMBER_TO_GUESS=$((1 + RANDOM % 1000))

echo "Enter your username:"
read USERNAME

FIND_USER_RESULT=$($PSQL "SELECT * FROM users WHERE users.name='$USERNAME';")

if [[ -z $FIND_USER_RESULT ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  IFS='|' read USER_ID GAMES_PLAYED BEST_GAME NAME <<< "$FIND_USER_RESULT"
  echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS_NUMBER
NUMBER_OF_GUESSES=1

while [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESS_NUMBER
done

while [[ $GUESS_NUMBER -ne $NUMBER_TO_GUESS ]] 
do
  while [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS_NUMBER
  done
  
  if (( GUESS_NUMBER < NUMBER_TO_GUESS ))
  then
    echo "It's higher than that, guess again:"
  fi

  if (( GUESS_NUMBER > NUMBER_TO_GUESS ))
  then
    echo "It's lower than that, guess again:"
  fi

  read GUESS_NUMBER
  (( NUMBER_OF_GUESSES++ ))
done

(( GAMES_PLAYED++ ))
if [[ $BEST_GAME -eq 0 || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  BEST_GAME=$NUMBER_OF_GUESSES
fi

if [[ -z $FIND_USER_RESULT ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name, games_played, best_game) VALUES('$USERNAME', 1, $NUMBER_OF_GUESSES);")
else
  UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE user_id=$USER_ID;")
fi

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
