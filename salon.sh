#! /bin/bash

PSQL="psql --username=postgres --dbname=salon -t --no-align -c"
echo -e "\n"~~~~~~~~~~ MY SALON ~~~~~~~~~~~~~ "\n"

MAIN_MENU (){
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")

  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do 
  echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo -e "\nWelcome to my salon, how may I help you?"
  read SERVICE_ID_SELECTED

  SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  if [[ -z $SELECTED_SERVICE ]]
  then
    MAIN_MENU "Please enter a valid option."
  else
    echo -e "What's your phone number?\n"
    read CUSTOMER_PHONE
    KNOWN_CUSTOMER=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    if [[ -z $KNOWN_CUSTOMER ]]
    then 
      echo -e "I don't have a record for that phone number, what's your name?\n"
      read CUSTOMER_NAME

      NEW_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      echo -e "What time would you like your $SELECTED_SERVICE, $CUSTOMER_NAME?\n"
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, name, service_id, time) VALUES ($CUSTOMER_ID, '$CUSTOMER_NAME', $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo -e "I have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME.\n"
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      #SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

      echo -e "What time would you like your $SELECTED_SERVICE, $CUSTOMER_NAME?\n"
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, name, service_id, time) VALUES ($CUSTOMER_ID, '$CUSTOMER_NAME', $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "I have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME.\n"
    fi
  fi
}

MAIN_MENU
