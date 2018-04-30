FROM kalilinux/kali-linux-docker

LABEL maintainer "Benjamin Stein <info@diffus.org>"

RUN apt-get -y update && apt-get install -y \
    kali-linux-full \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*


# Metasploit + PostgreSQL
RUN apt-get update \
    && apt-get install -y \
        apt-transport-https \
	ca-certificates \
	&& apt-get update \
    && apt-get install -y \
        bash \
        curl \
        gnupg \
        nasm \
        nmap \
        postgresql \
        postgresql-client \
        postgresql-contrib \
    && curl -fsSL https://apt.metasploit.com/metasploit-framework.gpg.key | apt-key add - \
    && echo "deb https://apt.metasploit.com/ sid main" >> /etc/apt/sources.list \
    && apt-get update -qq \
    && apt-get install -y metasploit-framework \
    && rm -rf /var/lib/apt/lists/*

# Execute msfupdate on container startup by default
# override via `docker run`
ENV do_msfupdate true

# PosgreSQL configuration
COPY ./scripts/setupPostgres.sql /tmp/setupPostgres.sql
COPY ./conf/database.yml /usr/share/metasploit-framework/config/

# Add startup script
COPY ./scripts/containerInit.sh /usr/local/bin/containerInit.sh

# Configuration and shared folders
VOLUME /root/.msf4/

# Modify the data folder of PostgreSQL
RUN sed -i 's|.*data_directory.*|data_directory = \x27/tmp/postgresData\x27|' /etc/postgresql/$(ls /etc/postgresql)/main/postgresql.conf

CMD ["/bin/bash", "containerInit.sh"]
