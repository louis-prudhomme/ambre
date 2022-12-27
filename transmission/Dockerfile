FROM alpine:latest as download

RUN apk update && apk upgrade
RUN apk --no-cache add      \
        curl                \
        zip

RUN curl -OL https://github.com/johman10/flood-for-transmission/releases/download/latest/flood-for-transmission.zip
RUN unzip flood-for-transmission

FROM lscr.io/linuxserver/transmission:latest

COPY --from=download                \
        /flood-for-transmission     \
        /flood-for-transmission
