#! /bin/sh

HUYA_ROOM_URL="https://www.huya.com/${HUYA_ROOM_ID}"

CHECK_INTERVAL=300

# 下载hls直播流
# 参数:
#   $1: url
#   $2: 目标文件
function hls_download() {
    local m3u8_url="${1}"
    local output="${2}"

    local m3u8_url_base=$(dirname "${m3u8_url}")

    local last_m3u8_ts_file_list=""

    while true
    do
        local start_date=$(date '+%s')
        
        local m3u8_content=$(curl -fsSL --max-time 10 "${m3u8_url}")
        if [[ "${m3u8_content}" = "" ]]; then
            break
        fi
        
        local m3u8_ext_x_media_sequence=$(echo "${m3u8_content}" | grep '#EXT-X-MEDIA-SEQUENCE' | awk -F ':' '{print $2}')
        echo "m3u8_ext_x_media_sequence=${m3u8_ext_x_media_sequence}"

        local m3u8_ext_x_targetduration=$(echo "${m3u8_content}" | grep '#EXT-X-TARGETDURATION' | awk -F ':' '{print $2}')
        echo "m3u8_ext_x_targetduration=${m3u8_ext_x_targetduration}"

        local m3u8_ts_file_list=$(echo "${m3u8_content}" | grep -v '#')

        for m3u8_ts_file in ${m3u8_ts_file_list}; do
            if ! echo "${last_m3u8_ts_file_list}" | grep -F "${m3u8_ts_file}" >/dev/null; then
                local stream_url="${m3u8_url_base}/${m3u8_ts_file}"
                echo "downloading ${stream_url}"
                curl -fsSL --max-time 10 "${stream_url}" >> "${output}"
            fi
        done

        last_m3u8_ts_file_list="${m3u8_ts_file_list}"
        
        local end_date=$(date '+%s')
        
        sleep $(( ${m3u8_ext_x_targetduration} - (${end_date} - ${start_date}) ))
    done
}

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
            urls=$(python3 huya2.py "${HUYA_ROOM_ID}")
            if echo "${urls}" | grep False >/dev/null; then
                echo "获取直播URL失败"
                sleep 10
            else
                bd_url=$(echo "${urls}" | sed "s/\'/\"/g" | jq -r ".bd")
                hls_download "${bd_url}" "/data/$(date "+%Y%m%d%H%M%S")-video.ts"
            fi
        fi
    fi
done
