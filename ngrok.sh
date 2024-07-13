#!/bin/bash

# File paths
PREVIOUS_URL_FILE="Previous_URL.txt"
CHANGE_LOG_FILE="url_change.log"

# Email address
EMAIL="Your Email address to receive the URL change notice of ngrok"

# Ngrok command to start the tunnel with basic authentication
NGROK_CMD="/usr/local/bin/ngrok http 192.168.XX.XX:80 --basic-auth="admin:Your Password""  # Make sure to use the full path to the ngrok executable

# Function to start ngrok
start_ngrok() {
  echo "Starting ngrok..."
  eval $NGROK_CMD > ngrok.log 2>&1 &
  sleep 5  # Give ngrok some time to establish the tunnel
  if ! pgrep -f "ngrok http" > /dev/null; then
    echo "Failed to start ngrok. Check ngrok.log for details."
    exit 1
  fi
  echo "ngrok started."
}

# Function to get the current ngrok public URL
get_ngrok_url() {
  curl --silent http://localhost:4040/api/tunnels | grep -oP 'public_url":"\K[^"]*' | head -n 1
}

# Function to send an email notification
send_email() {
  local new_url=$1
  {
    echo "Subject: Ngrok URL Update"
    echo "To: $EMAIL"
    echo
    echo "The ngrok public URL has changed to: $new_url"
  } | sendmail -t
}

# Ensure the Previous_URL.txt file exists
if [ ! -f "$PREVIOUS_URL_FILE" ]; then
  touch "$PREVIOUS_URL_FILE"
fi

# Start ngrok and show connection information
start_ngrok
ngrok_info=$(curl --silent http://localhost:4040/api/tunnels)
echo "Ngrok connection information:"
echo "$ngrok_info"

# Initial read of the previous URL
PREVIOUS_URL=$(cat "$PREVIOUS_URL_FILE")

# Monitor loop
while true; do
  CURRENT_URL=$(get_ngrok_url)
  
  if [ "$CURRENT_URL" != "$PREVIOUS_URL" ]; then
    echo "URL has changed from $PREVIOUS_URL to $CURRENT_URL. Updating file and logging change."
    
    # Update the Previous_URL.txt file
    echo "$CURRENT_URL" > "$PREVIOUS_URL_FILE"
    
    # Log the change
    echo "$(date): URL changed from $PREVIOUS_URL to $CURRENT_URL" >> "$CHANGE_LOG_FILE"
    
    # Send email notification
    send_email "$CURRENT_URL"
    
    # Update the previous URL variable
    PREVIOUS_URL=$CURRENT_URL
  fi
  
  # Wait for 10 seconds before checking again
  sleep 10
done
