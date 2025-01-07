#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# get username
echo "Enter your username:"
read USERNAME

#get username
USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

# get user_id
USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# user not found
if [[ -z $USERNAME_RESULT ]]
then
  # insert new user
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  # get user's games info
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN users USING(user_id) WHERE username = '$USERNAME'")
  BEST_GAMES=$($PSQL "SELECT MIN(number_of_guesses) FROM games LEFT JOIN users USING(user_id) WHERE username = '$USERNAME'")

  # echo result
  echo -e "\nWelcome back, $USERNAME_RESULT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAMES guesses."
fi


# generate random number between 1 and 1000
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

# variable to store the number off guesses
GUESS_COUNT=0

# first guess
echo -e "\nGuess the secret number between 1 and 1000:"
read USER_GUESS

# loop untill correct answer
until [[ $USER_GUESS =~ $SECRET_NUMBER ]]
do

# check guess is valid
  if [[ ! $USER_GUESS =~ [0-9]+$ ]]
  then
    # ask valid guess
    echo -e "\nThat is not an integer, guess again:"
    read USER_GUESS
  
    # update count
    ((GUESS_COUNT++))

  # if valid guess
  else
    # check differences and give a hint
    if [[ $USER_GUESS < $SECRET_NUMBER ]]
    then
      # if guess < secret number
      echo -e "\nIt's lower than that, guess again:"
      read USER_GUESS

      # update count
      ((GUESS_COUNT++))
    else
      # if guess > secret number
      echo -e "\nIt's higher than that, guess again:"
      read USER_GUESS

      # update count
      ((GUESS_COUNT++))
    fi
  fi

done

# correct guess, update count
((GUESS_COUNT++))

# get user id
USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# add result to db
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_guesses, secret_number) VALUES($USER_ID_RESULT, $GUESS_COUNT, $SECRET_NUMBER)")

# winning message
echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"