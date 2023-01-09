#!/bin/bash
SQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"

#check if there is an argument passed to the script
if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
else
  #check if there is a number, symbol or name in elements
  COUNT=0
  AT_NUM=0
  SYM=''
  EL_NAME=''
  CHECK=$($SQL "select atomic_number, symbol, name from elements;")
  while read -r ATOMIC_NUMBER BAR SYMBOL BAR NAME
  do
    if [ $1 = $ATOMIC_NUMBER ] || [ $1 = $SYMBOL ] || [ $1 = $NAME ]
    then
      COUNT=1
      AT_NUM=$ATOMIC_NUMBER
      SYM=$SYMBOL
      EL_NAME=$NAME
    fi
  done < <(echo "$CHECK")
  if [[ $COUNT == 0 ]]
    then  
      echo -e "I could not find that element in the database."
  fi
  if [[ $COUNT == 1 ]]
  then
    #getting the rest of element info
    INFO=$($SQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, types.type from properties FULL JOIN types ON properties.type_id = types.type_id WHERE atomic_number=$AT_NUM;")
    echo $INFO | while read ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT BAR TYPE
    do
      echo -e "The element with atomic number $AT_NUM is $EL_NAME ($SYM). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $EL_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done  
  fi
fi
