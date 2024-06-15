#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
PSQLD="psql --username=freecodecamp --dbname=salon -c"

echo -e "\n~~~~~ My salon ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?"

MAIN_MENU() {
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi
  
  SERVICES=$($PSQLD "SELECT * FROM services")
  echo "$SERVICES" | tail -n +3 | while read service_id bar service; do
  echo "$service_id) $service"
  done
  read SERVICE_ID_SELECTED

  #Check whether service selected is available
  HAVE_SERV=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $HAVE_SERV ]]
  then
    echo -e "\n could not find that service. What would you like today?"
    echo "$SERVICES" | tail -n +3 | while read service_id bar service; do
    echo "$service_id) $service"
    done
    read SERVICE_ID_SELECTED
  fi

  #Get customer info
   echo -e "\nWhat's your phone number?"
   read CUSTOMER_PHONE

  #Check if customer exist
  HAVE_CUST=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  #If cumstomer doesn't exist
  if [[ -z $HAVE_CUST ]]
  #ask for cutomer name
  then 
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    #insert new customer
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  #get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #get appoinment time
  SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  echo -e "\nWhat time would you like your $SELECTED_SERVICE, $CUSTOMER_NAME?"
  read SERVICE_TIME

  #insert appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")

  #Closing sentence
  echo -e "\nI have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
