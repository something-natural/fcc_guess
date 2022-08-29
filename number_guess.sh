#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c "

check_user(){
  echo "Enter your username:"
  read username
  user_id=$($PSQL "select user_id from users where username='$username'") 
  if [[ -z $user_id ]]
    then
    echo "Welcome, $username! It looks like this is your first time here."    
    status='newbie'
    insert_uses=$($PSQL "insert into users(username) values ('$username')")
    user_id=$($PSQL "select user_id from users where username='$username'") 
  else
    username=$($PSQL "select username from users where user_id=$user_id") 
    games_played=$($PSQL "select count(*) from games group by user_id having user_id=$user_id") 
    best_game=$($PSQL "select min(guess_count) from games group by user_id having user_id=$user_id") 
    echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
    status='oldbie'
  fi
  start_game
}

start_game(){
  echo "Guess the secret number between 1 and 1000:"
  secret_number=$(( RANDOM % 1000 + 1 ))
  echo $secret_number
  number_of_guesses=0  
  check_guess
}

check_guess(){
  read guess  
  number_of_guesses=$(( $number_of_guesses + 1))
  if [[ ! $guess =~ ^[0-9]+$ ]]
    then
    echo "That is not an integer, guess again:"    
    check_guess
  else
    if [[ $guess -gt $secret_number ]]
      then      
      echo "It's lower than that, guess again:"      
      check_guess
    elif [[ $guess -lt $secret_number ]]
      then      
      echo "It's higher than that, guess again:"      
      check_guess
    else
      echo "You guessed it in $number_of_guesses tries. The secret number was $secret_number. Nice job!"            
      insert_games=$($PSQL "insert into games(user_id, guess_count) values($user_id,$number_of_guesses)")          
    fi
  fi
}
check_user