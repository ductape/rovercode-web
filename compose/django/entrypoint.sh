#!/bin/bash
set -e
cmd="$@"

# This entrypoint is used to play nicely with the current cookiecutter configuration.
# Since docker-compose relies heavily on environment variables itself for configuration, we'd have to define multiple
# environment variables just to support cookiecutter out of the box. That makes no sense, so this little entrypoint
# does all this for us.
export REDIS_URL=redis://redis:6379

# the official postgres image uses 'postgres' as default user if not set explictly.
if [ -z "$POSTGRES_USER" ]; then
    export POSTGRES_USER=postgres
fi
if [ -z "$POSTGRES_HOST" ]; then
    export POSTGRES_HOST=postgres
fi
if [ -z "$POSTGRES_DB" ]; then
    export POSTGRES_DB=$POSTGRES_USER
fi

apt-get install -y ca-certificates wget
wget https://s3.amazonaws.com/rds-downloads/rds-ca-2015-root.pem -P /usr/local/share/ca-certificates/
update-ca-certificates


export DATABASE_URL=postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:5432/$POSTGRES_DB


function postgres_ready(){
python << END
import sys
import psycopg2
if "$POSTGRES_USE_AWS_SSL".lower() == 'true':
    kwargs = {"sslrootcert": "rds-ca-2015-root.pem", "sslmode": "require"}
else:
    kwargs = {}
try:
    conn = psycopg2.connect(dbname="$POSTGRES_DB", user="$POSTGRES_USER", password="$POSTGRES_PASSWORD", host="$POSTGRES_HOST", **kwargs)
except psycopg2.OperationalError:
    sys.exit(-1)
sys.exit(0)
END
}

until postgres_ready; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - continuing..."
exec $cmd
