#!/bin/bash

# Define the PSQL command to interact with the PostgreSQL database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for the username
echo "Enter your username:"
read USERNAME

# Check if the username exists in the database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  # If the username does not exist, welcome the user and add them to the database
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # If the username exists, fetch the number of games played and the best game performance
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")

  # If there are no games played yet, set BEST_GAME to 'N/A'
  if [[ -z $BEST_GAME ]]
  then
    BEST_GAME="N/A"
  fi

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate a random secret number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0

# Prompt the user to guess the number
echo "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS

  # Check if the input is a valid integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Increment the guess count
  ((GUESS_COUNT++))

  # Check if the guess is correct
  if (( GUESS == SECRET_NUMBER ))
  then
    # Print the success message and insert the game record into the database
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESS_COUNT)")
    break
  elif (( GUESS > SECRET_NUMBER ))
  then
    # Inform the user if the guess is too high
    echo "It's lower than that, guess again:"
  else
    # Inform the user if the guess is too low
    echo "It's higher than that, guess again:"
  fi
done
