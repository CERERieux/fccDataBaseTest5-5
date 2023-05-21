#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER_GUESS=$(($RANDOM%1000+1))
GAME_ATTMPS=1
echo -e "Enter your username:"
read USERNAME
USER=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
if [[ -z $USER ]]
then
  #echo is new
  INSERT_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
else
  #echo welcome back
  $PSQL "SELECT * FROM users WHERE user_id='$USER'" | while IFS="|" read USER_ID NAME GAMES_P BEST_G
  do
    echo -e "Welcome back, $USERNAME! You have played $GAMES_P games, and your best game took $BEST_G guesses."
  done
fi
#logic game
GAME(){
  if [[ -z $1 ]]
  then
    echo -e "Guess the secret number between 1 and 1000:"
  else
    echo -e "$1"
  fi
  read USER_GUESS
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    #if not number
    ((GAME_ATTMPS++))
    GAME "That is not an integer, guess again:"
  elif [[ $NUMBER_GUESS -lt $USER_GUESS ]]
  then
    ((GAME_ATTMPS++))
    GAME "It's lower than that, guess again:"
  elif [[ $NUMBER_GUESS -gt $USER_GUESS ]]
  then
    ((GAME_ATTMPS++))
    GAME "It's higher than that, guess again:"
  else
    #equal
    EXIT
  fi
}
EXIT(){
  #Update user info
  $PSQL "SELECT * FROM users WHERE name='$USERNAME'" | while IFS="|" read USER_ID NAME GAMES_P BEST_G
  do
    if [[ -z $BEST_G ]]
    then
      UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=games_played+1, best_game=$GAME_ATTMPS WHERE name='$USERNAME'")
    else
      UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=games_played+1, best_game=LEAST(best_game,$GAME_ATTMPS) WHERE name='$USERNAME'")
    fi
  done
  echo -e "\nYou guessed it in $GAME_ATTMPS tries. The secret number was $NUMBER_GUESS. Nice job!"
}
GAME
