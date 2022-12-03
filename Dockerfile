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
RUN apt-get install wget nano vim -y

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

# Instalamos la extensión de PHP-Mysql
RUN apt-get install php-mysql -y

# Instalamos Zip y Unzip
RUN apt-get install zip unzip -y

# Instalamos Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# Creamos el volumen para compartir la carpeta
ADD container /var/www/html
VOLUME ["/var/www/html"]

# Instalamos Laravel
WORKDIR /var/www/html
RUN composer create-project laravel/laravel:9.3.11 laravel
RUN chmod -R 777 laravel/storage
RUN chmod -R 777 laravel/bootstrap/cache

# Configuramos el Virtual Host
WORKDIR /etc/apache2/sites-available
COPY virtual_host.conf .
RUN mv 000-default.conf old-default.conf
RUN mv virtual_host.conf 000-default.conf
RUN systemctl restart apache2

# Adiciona os programas para Setar os Locales
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN update-locale LANGUAGE=en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8
RUN a2enmod rewrite
RUN systemctl restart apache2

WORKDIR /var/www/html/laravel

EXPOSE 80
CMD apachectl -D FOREGROUND
