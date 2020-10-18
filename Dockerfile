FROM alpine

RUN \
apk add --no-cache ffmpeg python3 python3-dev py3-pip musl-dev gcc jq supervisor tzdata curl && \
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
pip3 install aiohttp protobuf pycryptodome

COPY real-url /real-url

COPY huya-video-record.sh /usr/local/bin/
COPY huya-danmu-record.sh /usr/local/bin/
COPY supervisord.conf /etc/

# 虎牙房间号
ENV HUYA_ROOM_ID=22793939

# 输出目录
VOLUME /data

CMD /usr/bin/supervisord -c /etc/supervisord.conf
