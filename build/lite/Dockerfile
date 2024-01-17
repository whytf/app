FROM ubuntu:22.04@sha256:e6173d4dc55e76b87c4af8db8821b1feae4146dd47341e4d431118c7dd060a74

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y wget && apt clean && apt autoremove -y && rm -rf /**var**/lib/apt/lists/*

WORKDIR /app

COPY src src
#RUN dos2unix src/*
RUN cp /app/src/install.sh /usr/bin/install
#RUN echo -e "#\!/bin/bash \n echo \"$(lsb_release -a)\"" > /usr/bin/lsb_release
#RUN echo -e "#\!/bin/bash \n echo \"$(hostnamectl)\"" > /usr/bin/hostnamectl
RUN chmod a+x /usr/bin/install
#RUN chmod a+x /usr/bin/hostnamectl /usr/bin/lsb_release

RUN bash /app/src/setup.sh && rm -r /app/src

VOLUME [ "/etc/earnapp" ]

CMD ["install"]