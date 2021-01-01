#! /bin/sh

HUYA_ROOM_URL="https://www.huya.com/${HUYA_ROOM_ID}"

CHECK_INTERVAL=300

while true
do
    if ! ping -c 1 www.baidu.com >/dev/null; then
        echo "网络不通"
        sleep "${CHECK_INTERVAL}"
    else
        html=$(curl -fsSL "${HUYA_ROOM_URL}")
        if echo "${html}" | grep -F "上次开播" >/dev/null; then
            echo "未开播"
            sleep "${CHECK_INTERVAL}"
        elif echo "${html}" | grep -F "正在整改中" >/dev/null; then
            echo "被踢下播"
            sleep "${CHECK_INTERVAL}"
        else
            python3 main2.py "${HUYA_ROOM_URL}" >> "/data/$(date "+%Y%m%d%H%M%S")-danmu.txt"
        fi
    fi
done
