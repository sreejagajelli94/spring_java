FROM ubuntu:18.04
RUN apt-get update -y && \
    apt-get install -y apache2
EXPOSE 80
