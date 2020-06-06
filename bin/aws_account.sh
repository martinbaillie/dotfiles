#!/usr/bin/env bash
function _aws_account {
    if [ ! -f ~/.aws/credentials ] || [ ! -s ~/.aws/credentials ]; then
        return
    fi
    local expiration=$(awk -F '=' '{if (! ($0 ~ /^;/) && $0 ~ /expiration/) print $2}' ~/.aws/credentials | tr -d ' ')
    local expiration_time=$(date -j -f "%Y-%m-%d%H:%M:%S%zUTC" "${expiration}" +%s)
    local now_time=$(date -j +%s)
    local time_left=$(( ($expiration_time - $now_time) / 60 ))
    local str="☁ ${time_left}m"
    local space="             "

    if [ -n "${INSIDE_EMACS}" ]; then
        if [ "$time_left" -gt 0 ] && [ "$time_left" -lt 60 ]; then
         if [ "$time_left" -gt 30 ]; then
            echo -e ":white_sun_small_cloud: ${time_left}m"
         elif [ "$time_left" -gt 20 ]; then
            echo -e ":partly-sunny: ${time_left}m"
         elif [ "$time_left" -gt 10 ]; then
            echo -e ":cloud: ${time_left}m"
         else
            echo -e ":cloud-lightning: ${time_left}m"
         fi
        fi
        return
    fi

    if [ "$time_left" -gt 20 ]; then
        if [ "$1" = "blank" ]; then
            printf "%s\\n" "${space:${#str}}"   
        else
            echo -e "#[fg=colour2]${str}"
        fi
    elif [ "$time_left" -gt 0 ]; then
        if [ "$1" = "blank" ]; then
            printf "%s\\n" "${space:${#str}}"   
        else
            echo -e "#[fg=colour1]${str}"
        fi
    fi
}
_aws_account "$1"
