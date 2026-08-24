#!/bin/bash

# Auto-detect battery device (e.g. BAT1, BAT0)
BAT_DIR=$(find /sys/class/power_supply/ -maxdepth 1 -name "BAT*" | head -n 1)

if [[ -z "$BAT_DIR" || ! -d "$BAT_DIR" ]]; then
  echo "Error: No battery found in /sys/class/power_supply/" >&2
  exit 1
fi

counter=0
logfile="$HOME/battery.log"
counterfile="$HOME/counter"
result=0

if [[ -f "$counterfile" ]]; then
  counter=$(cat "$counterfile")
fi

get_capacity() {
  if [[ -f "$BAT_DIR/capacity" ]]; then
    cat "$BAT_DIR/capacity"
  elif [[ -f "$BAT_DIR/charge_now" && -f "$BAT_DIR/charge_full" ]]; then
    local now full
    now=$(cat "$BAT_DIR/charge_now")
    full=$(cat "$BAT_DIR/charge_full")
    if (( full > 0 )); then
      echo $(( (now * 100) / full ))
    else
      echo 0
    fi
  else
    echo 0
  fi
}

old_charge_percentage=$(get_capacity)

while true; do
  charge_percentage=$(get_capacity)

  # Check if battery charge dropped more than 5% within 1 minute
  if (( old_charge_percentage > 0 && (old_charge_percentage - charge_percentage) > 5 )); then
    notify-send -u critical "Battery charge has dropped significantly!" "Dropped from ${old_charge_percentage}% to ${charge_percentage}%"
    exit 88
  fi

  # Log timestamp and percentage
  date | tee -a "$logfile"
  echo "$charge_percentage%" | tee -a "$logfile"

  # Notification at key battery percentage milestones
  if [[ "$charge_percentage" == "80" || "$charge_percentage" == "60" || "$charge_percentage" == "40" || "$charge_percentage" == "20" || "$charge_percentage" == "10" ]]; then
    notify-send "Battery is at ${charge_percentage}%."
    echo "Running on battery for $counter minutes with the screen on." | tee -a "$logfile"
  fi

  # Increment counter and save state
  counter=$((counter + 1))
  echo "$counter" > "$counterfile"
  old_charge_percentage=$charge_percentage

  sleep 60
done
