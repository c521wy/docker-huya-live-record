#! /bin/sh

set -x

HUYA_ROOM_URL="https://www.huya.com/${HUYA_ROOM_ID}"

while true
do
    if ! ping -c 1 www.baidu.com || curl -fsSL "${HUYA_ROOM_URL}" | grep "上次开播"; then # 暂未开播
        sleep 300
    else
        urls=$(python3 huya2.py "${HUYA_ROOM_ID}")
        if echo "${urls}" | grep False; then # 获取url失败
            sleep 10
            continue
        else
            bd_url=$(echo "${urls}" | sed "s/\'/\"/g" | jq -r ".bd")
            ffmpeg \
              -user_agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36" \
              -i "${bd_url}" \
              -timeout 5000 \
              -c copy "/data/$(date "+%Y%m%d%H%M%S")-video.ts"
        fi
    fi
done
