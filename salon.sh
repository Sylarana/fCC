#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
# Welcome header
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you? \n"
#main menu function
MAIN_MENU(){
  #prints the argument of main_menu when the function is called later in the program with a message
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  #prints services the salon offers
  OFFERED_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$OFFERED_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  #reading the service selected
  read SERVICE_ID_SELECTED
  #find the service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  #if the service doesn't exist, send to main menu
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    #get customer's info with phone as a key
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    #in case the customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
     #get new customer's name
     echo -e "\nI don't have a record for that phone number, what's your name?"
     read CUSTOMER_NAME
     #add new customer to the customers table
     NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    #get customer's id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #prompt customer to select appointment time
    echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
    read SERVICE_TIME
    #create an appointment
    NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
