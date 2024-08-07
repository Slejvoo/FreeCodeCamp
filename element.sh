get_element_info() {
  ...
}
#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
if [[ $? -ne 0 ]]; then
  echo "Database query failed."
  exit 1
fi
fi

# Determine if the input is an atomic number, symbol, or name
if [[ $1 =~ ^[0-9]+$ ]]; then
  QUERY="SELECT elements.atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius 
         FROM elements 
         JOIN properties ON elements.atomic_number=properties.atomic_number 
         JOIN types ON properties.type_id=types.type_id 
         WHERE elements.atomic_number=$1"
else
  QUERY="SELECT elements.atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius 
         FROM elements 
         JOIN properties ON elements.atomic_number=properties.atomic_number 
         JOIN types ON properties.type_id=types.type_id 
         WHERE symbol='$1' OR name='$1'"
fi

ELEMENT_INFO=$($PSQL "$QUERY" 2>/dev/null)

if [[ -z $ELEMENT_INFO ]]; then
  echo "I could not find that element in the database."
else
  echo "$ELEMENT_INFO" | while IFS="|" read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING_POINT BOILING_POINT
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
fi
# This script provides information about elements
