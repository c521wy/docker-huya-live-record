#! /bin/sh

set -x

HUYA_ROOM_URL="https://www.huya.com/${HUYA_ROOM_ID}"

while true
do
    if curl -fsSL "${HUYA_ROOM_URL}" | grep "上次开播"; then # 暂未开播
        sleep 300
    else
        python3 main2.py "${HUYA_ROOM_URL}" >> "/data/$(date "+%Y%m%d%H%M%S")-danmu.txt"
    fi
done