#!/bin/bash

# Configuration variables
INTERVAL=${1:-60} # Measure interval in minutes, default is 60
LOG_FILE="/var/log/swap_usage.log"
TEMP_FILE="/var/log/swap_usage_temp.log"

# Function to log swap usage
log_swap_usage() {
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> $TEMP_FILE
    any_swap_usage=false
    for pid in $(ps -e -o pid --no-headers); do
        swap=$(grep VmSwap /proc/$pid/status 2>/dev/null | awk '{ print $2 }')
        if [ "$swap" != "" ] && [ "$swap" -gt 0 ]; then
            cmd=$(ps -p $pid -o comm=)
            echo "PID: $pid - Swap: ${swap}KB - Command: $cmd" >> $TEMP_FILE
            any_swap_usage=true
        fi
    done
    if [ "$any_swap_usage" = false ]; then
        echo "No processes using swap at this time." >> $TEMP_FILE
    fi
    echo "CPU Time managing swap: $(vmstat -s | grep 'swap in')" >> $TEMP_FILE
    echo "------------------------" >> $TEMP_FILE
}

# Function to rotate log and keep only the last 24 hours
rotate_log() {
    # Get current timestamp
    current_time=$(date +%s)
    # Define 24 hours in seconds
    time_limit=$((24 * 3600))
    
    if [ -f $LOG_FILE ]; then
        while read -r line; do
            if [[ $line == Timestamp:* ]]; then
                log_time=$(echo $line | awk '{print $2, $3}')
                log_timestamp=$(date -d "$log_time" +%s)
                if ((current_time - log_timestamp > time_limit)); then
                    sed -i "/$log_time/d" $LOG_FILE
                fi
            fi
        done < $LOG_FILE
    fi
}

# Rotate the log file
rotate_log

# Log current swap usage
log_swap_usage

# Append temp log to main log file and clear temp log
cat $TEMP_FILE >> $LOG_FILE
rm $TEMP_FILE
