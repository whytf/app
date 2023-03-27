FROM ubuntu:20.04

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y dos2unix wget && apt clean

WORKDIR /app

COPY src src
RUN dos2unix src/*
RUN cp /app/src/install.sh /usr/bin/install \
 && cp /app/src/hostnamectl.sh /usr/bin/hostnamectl \
 && cp /app/src/lsb_release.sh /usr/bin/lsb_release
RUN chmod a+x /usr/bin/install /usr/bin/hostnamectl /usr/bin/lsb_release

RUN bash /app/src/setup.sh && rm -r /app/src

VOLUME [ "/etc/earnapp" ]

CMD ["install"]
