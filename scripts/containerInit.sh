#!/bin/bash
set -e

mkdir -p /tmp/postgresData

# Setup the postgres database if required
if [ -z "$(ls -A /tmp/postgresData)" ]; then
	echo "Setting up PostgreSQL"
	chown -R postgres:postgres /tmp/postgresData && \
	su postgres -c "/usr/lib/postgresql/$(ls /usr/lib/postgresql)/bin/pg_ctl initdb -D /tmp/postgresData"
	rm -f /var/run/postgresql/*.pid
	/etc/init.d/postgresql start && \
	su postgres -c "psql -f /tmp/setupPostgres.sql"
else
    /etc/init.d/postgresql start
fi

if [ $do_msfupdate = "true"  ]; then
	echo "Checking for updates..." && msfupdate && echo "done"
fi

/bin/bash
