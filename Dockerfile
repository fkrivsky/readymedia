FROM alpine:3
LABEL MAINTAINER="Filip Krivsky"

RUN apk add --no-cache minidlna

ENV FRIENDLY_NAME="My ReadyMedia Server"
ENV TCP_PORT="8200"
ENV SERIAL="1234567890"

COPY minidlna.conf /etc/minidlna.conf
COPY start.sh /

CMD ["/start.sh"]
