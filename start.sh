#!/bin/sh

INITIAL_CONF="/etc/minidlna.conf"
PERSISTENT_CONF="/cache/minidlna.conf"
TEMP_CONF="/tmp/minidlna.conf"
PID_FILE="/run/minidlna.pid"

## Copying initial config file to persistent storage
if [ ! -f "$PERSISTENT_CONF" ]; then
  cat "$INITIAL_CONF" > "$PERSISTENT_CONF"
fi

## Copying persistent config file to the temp config file
cat "$PERSISTENT_CONF" > "$TEMP_CONF"

## Updating temp config file with parameters from Docker ENV
echo "port=${TCP_PORT}" >> "$TEMP_CONF"
echo "friendly_name=${FRIENDLY_NAME}" >> "$TEMP_CONF"
echo "serial=${SERIAL}" >> "$TEMP_CONF"

# Helper function for media directories
add_media_dirs() {
  local prefix="$1"   # e.g. ALL_MEDIA, VIDEO, AUDIO, PICTURES
  local type="$2"     # e.g. "", "V,", "A,", "P,"

  for i in $(seq 1 9); do
    var="${prefix}_DIR${i}"
    val=$(eval echo "\$$var")
    [ -n "$val" ] && echo "media_dir=${type}${val}" >> "$TEMP_CONF"
  done
}

# Add media directories
add_media_dirs "ALL_MEDIA" ""
add_media_dirs "VIDEO" "V,"
add_media_dirs "AUDIO" "A,"
add_media_dirs "PICTURES" "P,"

## Sometimes PID file can exist after restart. Cleaning.
if [ -f "$PID_FILE" ]; then
  pid=$(cat "$PID_FILE")
  if [ -n "$(ps -p $pid -o pid=)" ]; then
    echo "Another MiniDLNA instance is running: $pid. Exiting..."
    exit 1
  else
    echo "Removing uncleaned pid file: $PID_FILE"
    rm -f "$PID_FILE"
  fi
fi

## Start MiniDLNA
exec /usr/sbin/minidlnad -P "$PID_FILE" -f "$TEMP_CONF" -S -r