# About `secrets.yaml`

For obvious reasons, this file does not exist in this repo.

It should contain the following items:

````
# Custom
geo_lat:  NN.NNNN
geo_long: NN.NNNN

# Telegram notifier
telegram_api_key: NNNN:XXXXXX
# Messenger
telegram_chat_id: NNNN
# Mojore Messenger
telegram_mojore_chat_id: NNNN
  
# Recorder database
recorder_db: postgresql://hass@dbserver.squirrel.nl/hass

# IMAP accounts
imap_server: XXX.XXXXXX.XXX
imap_johanvromans: XXXXXXXXXXX
imap_mojore: XXXXXXXXXXXX

# CalDAV
caldav_account: XXX
caldav_password: XXXXXX
caldav_url: https://davical.squirrel.nl/caldav.php/
````
