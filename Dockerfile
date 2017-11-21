FROM ubuntu:latest
MAINTAINER GeometryFactory <maxime.gimeno@geometryfactory.com>

RUN set -x; 

# Install Shinken, Nagios plugins and supervisord
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    python \
    python-pip \
    python-pycurl \
    python-cherrypy3 \
    nagios-plugins* cpanminus \
    snmp \  
    snmpd \
    openssh-server \
    mongodb \
    lsb-release \
    libsys-statistics-linux-perl \
    nginx \
    ntp \
    libssl-dev \
    python-crypto \
    inotify-tools \
    supervisor && \
    apt-get -y autoremove && \
    apt-get clean

RUN echo "    IdentityFile /home/shinken/.ssh/id_rsa" >> /etc/ssh/ssh_config \
    && cpanm Net::SNMP \
    && cpanm Time::HiRes \
    && cpanm DBI

RUN pip install --upgrade pip \

    && useradd --create-home shinken \
    && pip install setuptools \
    && pip install shinken \
    && pip install pymongo>=3.0.3 requests arrow bottle==0.12.8 \
    && update-rc.d -f shinken remove

# Install shinken modules from shinken.io
RUN su - shinken -c 'shinken --init' && \
    su - shinken -c 'shinken install webui2' && \
    su - shinken -c 'shinken install auth-htpasswd' && \
    su - shinken -c 'shinken install sqlitedb' && \
    su - shinken -c 'shinken install pickle-retention-file-scheduler'&& \
    su - shinken -c 'shinken install booster-nrpe'

# Install check_nrpe plugin
ADD nrpe-2.15.tar.gz /usr/src/
RUN cd /usr/src/nrpe-2.15/ && \
    ./configure --with-nagios-user=shinken --with-nagios-group=shinken --with-nrpe-user=shinken --with-nrpe-group=shinken --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu && \
    make all && \
    make install-plugin && \
    mv /usr/local/nagios/libexec/check_nrpe /usr/lib/nagios/plugins/check_nrpe && \
    cd / && \
    rm -rf /usr/src/nrpe-2.15

# Configure nginx
ADD shinken/shinken_nginx.conf /etc/nginx/sites-available/shinken_nginx.conf
RUN mkdir -p /var/log/nginx && \
    rm -f /etc/nginx/sites-enabled/default && \
    ln -sf /etc/nginx/sites-available/shinken_nginx.conf /etc/nginx/sites-enabled/shinken_nginx.conf && \
    update-rc.d -f nginx remove && \
    echo "daemon off;" >> /etc/nginx/nginx.conf

# Configure Shinken modules
ADD shinken/shinken.cfg /etc/shinken/shinken.cfg
ADD shinken/broker-master.cfg /etc/shinken/brokers/broker-master.cfg
ADD shinken/poller-master.cfg /etc/shinken/pollers/poller-master.cfg
ADD shinken/scheduler-master.cfg /etc/shinken/schedulers/scheduler-master.cfg
COPY shinken/webui2.cfg /etc/shinken/modules/webui2.cfg
COPY shinken/webui2_worldmap.cfg /var/lib/shinken/modules/webui2/plugins/worldmap/plugin.cfg
RUN  mkdir -p /etc/shinken/custom_configs /usr/local/custom_plugins && \
       ln -sf /etc/shinken/custom_configs/htpasswd.users /etc/shinken/htpasswd.users

# Add shinken config watcher to restart arbiter, when changes happen
ADD shinken/watch_shinken_config.sh /usr/bin/watch_shinken_config.sh
RUN chmod 755 /usr/bin/watch_shinken_config.sh
   
# Copy extra NRPE plugins and fix permissions
ADD extra_plugins/* /usr/lib/nagios/plugins/
RUN cd /usr/lib/nagios/plugins/ && \
      chmod a+x * && \
      chmod u+s check_apt restart_service check_ping check_icmp check_fping apt_update

# configure supervisor
ADD supervisor/conf.d/* /etc/supervisor/conf.d/

COPY script_checks /home/shinken/script_checks
COPY commands /etc/shinken/commands
COPY hosts /etc/shinken/hosts
COPY services /etc/shinken/services
COPY brokers /etc/shinken/brokers
COPY resource.d /etc/shinken/resource.d

# Expose port 80 (nginx)
EXPOSE 80

# Default docker process
COPY entrypoint.sh /tmp/entrypoint.sh
RUN chmod +x /tmp/entrypoint.sh
CMD bash /tmp/entrypoint.sh