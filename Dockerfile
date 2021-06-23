FROM ubuntu:18.04
RUN apt-get update -y && \
    apt-get install -y apache2
COPY index.html /var/www/html/index.html
ENTRYPOINT ["httpd", "-D", "FOREGROUND"]
EXPOSE 80
