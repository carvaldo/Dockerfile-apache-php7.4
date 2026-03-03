FROM php:7.4-apache

# Instala dependências do sistema

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libxml2-dev \
    zlib1g-dev \
    libicu-dev \
    locales \
    zip \
    unzip \
    curl \
    nano \
    libonig-dev \
    libxslt-dev \
    libzip-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libjpeg-dev \
    libfreetype6-dev \
    librdkafka-dev \
    poppler-utils \
    ghostscript \
    gsfonts \
    iputils-ping \
    openjdk-17-jre \
    pdftk-java \
    wget \
    firebird-dev \
    git \
    unzip \
    libmagickwand-dev \
    imagemagick \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && pecl install rdkafka \
    && pecl install xdebug-3.1.6 \
    && pecl install imagick \
    && docker-php-ext-enable rdkafka \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        mbstring \
        exif \
        bcmath \
        gd \
        zip \
        intl \
        calendar \
        mysqli \
        pcntl

# RUN echo "zend_extension=\"/usr/lib/php/20190902/xdebug.so\"\n[xdebug]\nxdebug.mode=debug\nxdebug.start_with_request=yes\nxdebug.client_host=127.0.0.1\nxdebug.client_port=9003\n" >> /usr/local/etc/php/php.ini
RUN echo "extension=imagick.so" > /usr/local/etc/php/conf.d/imagick.ini

# Instala extensão interbase a partir de fork que ainda contém os arquivos
RUN apt-get install -y \
    && git clone https://github.com/FirebirdSQL/php-firebird.git /usr/src/php/ext/interbase \
    && docker-php-ext-install interbase

# Instala o Composer
RUN wget https://getcomposer.org/download/2.5.0/composer.phar && chmod +x composer.phar
RUN mv composer.phar /usr/local/bin/composer

# Instala fontes Microsoft
RUN sed -i 's/main/main contrib non-free non-free-firmware/' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       ttf-mscorefonts-installer \
       fontconfig \
    && rm -rf /var/lib/apt/lists/*

# Atualiza cache de fontes
RUN fc-cache -fv

# Instala btop
RUN wget https://github.com/aristocratos/btop/releases/download/v1.4.5/btop-x86_64-linux-musl.tbz \
    && tar -xvf btop-x86_64-linux-musl.tbz \
    && rm btop-x86_64-linux-musl.tbz \
    && cd btop \
    && make install \
    && make setcap \
    && make setuid \
    && cd .. \
    && rm -rf btop-x86_64-linux-musl.tbz btop

# Remove pacotes desnecessários
RUN apt remove -y git \
    && apt autoremove -y \
    && apt clean
    
RUN sed -i '/pt_BR.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen pt_BR.UTF-8

ENV LANG=pt_BR.UTF-8
ENV LANGUAGE=pt_BR:pt
ENV LC_ALL=pt_BR.UTF-8

# Define fuso horário para America/Campo_Grande
RUN ln -sf /usr/share/zoneinfo/America/Campo_Grande /etc/localtime

RUN a2enmod rewrite

# Copia o arquivo de configuração do PHP
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

EXPOSE 80

WORKDIR /var/www/html
