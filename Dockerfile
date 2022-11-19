FROM ubuntu:22.04
LABEL "Creador"="Alexis Montenegro amontenegro.sistemas@gmail.com"

# Actualizamos
RUN apt-get update

# Instalamos Systemctl
RUN apt-get install systemctl -y

# Instalamos apache2
RUN apt-get install apache2 -y
RUN systemctl start apache2

# Instalamos WGET
RUN apt-get install wget nano -y

# Instalamos Git
RUN apt-get install git -y

# Necesario para mantener el modo no interactivo en la instalación de PHP
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Instalamos PHP
RUN apt-get install php8.0 -y
RUN apt-get install libapache2-mod-php8.0 -y

# Instalamos Extensiones de PHP necesárias para Laravel
RUN apt-get install php-xml php-mbstring php-curl php-bcmath php-json php-tokenizer -y

# Instalamos Zip y Unzip
RUN apt-get install zip unzip -y

# Instalamos Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# Instalamos Laravel
WORKDIR /var/www/html
RUN composer create-project laravel/laravel:9.3.11 app
RUN chmod -R 777 app/storage
RUN chmod -R 777 app/bootstrap/cache

# Configuramos el Virtual Host
WORKDIR /etc/apache2/sites-available
COPY virtual_host.conf .
RUN mv 000-default.conf old-default.conf
RUN mv virtual_host.conf 000-default.conf
RUN systemctl restart apache2

EXPOSE 80
CMD apachectl -D FOREGROUND