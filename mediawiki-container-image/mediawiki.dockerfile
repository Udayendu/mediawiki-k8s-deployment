FROM rockylinux:8
RUN dnf install yum-utils -y
RUN yum-config-manager --enable powertools
RUN dnf install tree wget curl elinks git -y
RUN dnf module reset php
RUN dnf module enable php:7.4 -y
RUN dnf install httpd php php-mysqlnd php-gd php-xml php-mbstring php-json mod_ssl php-intl php-apcu -y
RUN systemctl enable httpd
EXPOSE 80
WORKDIR /var/www/html
RUN wget https://releases.wikimedia.org/mediawiki/1.39/mediawiki-1.39.2.tar.gz
RUN tar -xvzf mediawiki-1.39.2.tar.gz
RUN mv mediawiki-1.39.2/* .
RUN rm -rf mediawiki-1.39.2*
COPY docker-entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["systemctl", "status", "httpd"]
