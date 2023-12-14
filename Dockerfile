FROM php:8.1-apache
LABEL maintainer="Jan Hajek <hajek.j@hotmail.com>"
SHELL ["/bin/bash", "-c"]
ENV PHP_VERSION 8.1

RUN a2enmod rewrite expires include deflate remoteip headers

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    curl \
    net-tools \
    dnsutils \
    tcpdump \
    tcptraceroute \
    iproute2 \
    nano \
    # For SSH to work
    openssh-client \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

## FROM https://github.com/microsoft/Oryx/blob/01392f90eeeb9dbeb9c78c14b0ef443ed274abb6/images/runtime/php/runbase.Dockerfile
# TODO: If part of this fails, there's not proper error message since the code continues to execute for some reason
RUN set -eux; \
    apt-mark hold msodbcsql18 odbcinst1debian2 odbcinst unixodbc unixodbc-dev \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    xz-utils \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libpq-dev \
    libldap2-dev \
    libldb-dev \
    libicu-dev \
    libgmp-dev \
    libmagickwand-dev \
    libc-client-dev \
    libtidy-dev \
    libkrb5-dev \
    libxslt-dev \
    openssh-server \
    vim \
    wget \
    tcptraceroute \
    mariadb-client \
    openssl \
    libedit-dev \
    libsodium-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libldap2-dev \
    zlib1g-dev \
    apache2-dev \
    libsqlite3-dev \
    ; \
    # FROM https://github.com/microsoft/Oryx/blob/01392f90eeeb9dbeb9c78c14b0ef443ed274abb6/images/runtime/php/template.base.Dockerfile
    if [[ $PHP_VERSION == 7.4* || $PHP_VERSION == 8.0* || $PHP_VERSION == 8.1* || $PHP_VERSION == 8.2* ]]; then \
    docker-php-ext-configure gd --with-freetype --with-jpeg \
    && PHP_OPENSSL=yes docker-php-ext-configure imap --with-kerberos --with-imap-ssl ; \
    else \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl ; \
    fi \
    ; \
    apt-get install -y --no-install-recommends \
    gnupg2 \
    apt-transport-https \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 msodbcsql18 odbcinst1debian2 odbcinst unixodbc unixodbc-dev \
    ; \
    docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
    && docker-php-ext-install gd \
    mysqli \
    opcache \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    ldap \
    intl \
    gmp \
    zip \
    bcmath \
    mbstring \
    pcntl \
    calendar \
    exif \
    gettext \
    imap \
    tidy \
    shmop \
    soap \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm \
    pdo_odbc \
    # deprecated from 7.4, so should be avoided in general template for all php versions
    #       wddx \
    #       xmlrpc \
    xsl \
    ; \
    if [[ $PHP_VERSION != 5.* ]]; then \
    pecl install redis && docker-php-ext-enable redis; \
    fi \
    ; \
    pecl install imagick && docker-php-ext-enable imagick \
    ; \
    if [[ $PHP_VERSION != 5.* && $PHP_VERSION != 7.0.* ]]; then \
    echo "pecl/mongodb requires PHP (version >= 7.1.0, version <= 7.99.99)"; \
    pecl install mongodb && docker-php-ext-enable mongodb; \
    fi \
    ; \
    if [[ $PHP_VERSION == 7.2 || $PHP_VERSION == 7.3 || $PHP_VERSION == 7.4 ]]; then \
    echo "pecl/mysqlnd_azure requires PHP (version >= 7.2.*, version <= 7.99.99)"; \
    pecl install mysqlnd_azure \
    && docker-php-ext-enable mysqlnd_azure; \
    fi \
    ;\
    if [[ $PHP_VERSION == 8.* ]]; then \
    pecl install sqlsrv pdo_sqlsrv \
    && echo extension=pdo_sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini \
    && echo extension=sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini; \
    fi \
    ; \
    rm -rf /var/lib/apt/lists/*

COPY tcpping /usr/bin/tcpping
RUN chmod 755 /usr/bin/tcpping

COPY init_container.sh /bin/
COPY hostingstart.html /home/site/wwwroot/hostingstart.html

RUN if [[ "$PHP_VERSION" == "5.6" || "$PHP_VERSION" == "7.0" ]] ; then \
    apt-get install -y libmcrypt-dev && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install mcrypt; \
    fi

RUN chmod 755 /bin/init_container.sh \
    && mkdir -p /home/LogFiles/ \ 
    && echo "root:Docker!" | chpasswd \
    && echo "cd /home" >> /root/.bashrc \
    && ln -s /home/site/wwwroot /var/www/html \
    && mkdir -p /opt/startup

# configure startup
COPY sshd_config /etc/ssh/
COPY ssh_setup.sh /tmp
RUN mkdir -p /opt/startup \
    && chmod -R +x /opt/startup \
    && chmod -R +x /tmp/ssh_setup.sh \
    && (sleep 1;/tmp/ssh_setup.sh 2>&1 > /dev/null) \
    && rm -rf /tmp/*

COPY startssh.sh /opt/startup
RUN chmod +x /opt/startup/startssh.sh
COPY startup.sh /opt/startup/
RUN chmod +x /opt/startup/startup.sh

ENV PORT 80
ENV SSH_PORT 2222
EXPOSE 2222 80
COPY sshd_config /etc/ssh/

ENV WEBSITE_ROLE_INSTANCE_ID localRoleInstance
ENV WEBSITE_INSTANCE_ID localInstance
ENV PATH ${PATH}:/home/site/wwwroot

RUN sed -i 's!ErrorLog ${APACHE_LOG_DIR}/error.log!ErrorLog /dev/stderr!g' /etc/apache2/apache2.conf 
RUN sed -i 's!User ${APACHE_RUN_USER}!User www-data!g' /etc/apache2/apache2.conf 
RUN sed -i 's!User ${APACHE_RUN_GROUP}!Group www-data!g' /etc/apache2/apache2.conf 

# Enable access to the /home/site/wwwroot otherwise you get AH01630 error
RUN sed -i '/<Directory \/var\/www\/>/s/\/var\/www\//\/home\/site\/wwwroot/g' /etc/apache2/apache2.conf
# Enable using custom .htaccess
RUN sed -i '/<Directory \/home\/site\/wwwroot>/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Disable Apache2 server signature - https://github.com/microsoft/Oryx/blob/01392f90eeeb9dbeb9c78c14b0ef443ed274abb6/images/runtime/php/template.base.Dockerfile#L19C1-L21C61
RUN echo -e 'ServerSignature Off' >> /etc/apache2/apache2.conf
RUN echo -e 'ServerTokens Prod' >> /etc/apache2/apache2.conf

RUN { \
    echo 'DocumentRoot /home/site/wwwroot'; \
    echo 'DirectoryIndex default.htm default.html index.htm index.html index.php hostingstart.html'; \
    echo 'CustomLog /dev/null combined'; \
    echo '<FilesMatch "\.(?i:ph([[p]?[0-9]*|tm[l]?))$">'; \
    echo '   SetHandler application/x-httpd-php'; \
    echo '</FilesMatch>'; \
    echo '<DirectoryMatch "^/.*/\.git/">'; \
    echo '   Order deny,allow'; \
    echo '   Deny from all'; \
    echo '</DirectoryMatch>'; \
    echo 'EnableMMAP Off'; \
    echo 'RemoteIPHeader X-Forwarded-For'; \
    echo 'EnableSendfile Off'; \
    } >> /etc/apache2/apache2.conf

RUN rm -f /usr/local/etc/php/conf.d/php.ini \
    && { \
    echo 'error_log=/dev/stderr'; \
    echo 'display_errors=Off'; \
    echo 'log_errors=On'; \
    echo 'display_startup_errors=Off'; \
    echo 'date.timezone=UTC'; \
    echo 'session.save_path=/home/data/session'; \
    } > /usr/local/etc/php/conf.d/php.ini

RUN rm -f /etc/apache2/conf-enabled/other-vhosts-access-log.conf
RUN rm /etc/apache2/sites-enabled/000-default.conf

COPY mpm_prefork.conf /etc/apache2/mods-available/mpm_prefork.conf

WORKDIR /home/site/wwwroot

ENTRYPOINT ["/bin/init_container.sh"]