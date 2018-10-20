#!/usr/bin/env bash
function _aws_account {
    if [ ! -f ~/.aws/credentials ] || [ ! -s ~/.aws/credentials ]; then
        return
    fi

    #local app_name=$(awk -F '=' '{if (! ($0 ~ /^;/) && $0 ~ /aws_account_name/) print $2}' ~/.aws/credentials | cut -d ' ' -f2)
    #local app_name="$(grep aws_account_name ~/.aws/credentials|sed -n -e '/^[^(]*(\([^)]*\)).*/s//\1/p')"
    #local role_name=$(awk -F '=' '{if (! ($0 ~ /^;/) && $0 ~ /role_name/) print $2}' ~/.aws/credentials | tr -d ' ')
    local expiration=$(awk -F '=' '{if (! ($0 ~ /^;/) && $0 ~ /expiration/) print $2}' ~/.aws/credentials | tr -d ' ')
    local expiration_time=$(date -j -f "%Y-%m-%d%H:%M:%S%zUTC" "${expiration}" +%s)
    local now_time=$(date -j +%s)
    local time_left=$(( ($expiration_time - $now_time) / 60 ))

    local str="☁ ${time_left}m"
    local space="             "
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
