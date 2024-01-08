FROM ubuntu:22.04@sha256:6042500cf4b44023ea1894effe7890666b0c5c7871ed83a97c36c76ae560bb9b

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y wget && apt clean && apt autoremove -y

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
