This is the main shell scripts to establish the ngrok URL for ESP32 webserver for toggle GPIO,
the shell commands will perform the link to ngrok between ESP32 webserver, and get a temporary
URL, which you can access the ESP32 webserver through whatever web browser (with the login 
authentication granted).
On the other hand, the shell scripts will also compare to see whether there's any URL change
between current connection of ngrok to the previous URL, if the URL has been changed, it will
send email to notify you regarding to the latest ngrok URL in order for you to get access to, 
and will also record the change in url_change.log.
No copy right, wellcome to copy and utilze the scripts if you deem useful.
