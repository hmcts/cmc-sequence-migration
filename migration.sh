#!/bin/sh

echo
set -e
set -u
echo "* Starting migration..."
echo

if [ "$#" -ne 10 ]; then
    echo "* Illegal number of arguments."
    echo "* Usage: $0 [hostname] [port] [db_name] [db_username] [input.sql] [src_db_name] [src_port] [src_host] [src_user] [src_password]"
    echo
    echo "* Exiting"
    echo
    exit 1
fi

HOST="$1"
PORT="$2"
DB="$3"
USER="$4"
SQL="scripts/$5"
SRC_DB="$6"
SRC_PORT="$7"
SRC_HOST="$8"
SRC_USER="$9"
SRC_PASSWORD="${10}"

echo "* DB hostname: $HOST"
echo "* DB port: $PORT"
echo "* DB name: $DB"
echo "* DB username: $USER"
echo "* SRC_DB: $SRC_DB"
echo "* SRC_PORT: $SRC_PORT"
echo "* SRC_HOST: $SRC_HOST"
echo "* SRC_USER: $SRC_USER"
echo "* SRC_PASSWORD: $SRC_PASSWORD"
echo

SQL_FUNCTION='select migrate_claim_reference_number('\'$SRC_DB\'', '$SRC_PORT', '\'$SRC_HOST\'','\'$SRC_USER\'','\'$SRC_PASSWORD\'')'
echo "* Query to Execute function: ${SQL_FUNCTION}"

METRICS=$(psql \
    -X \
    -q \
    -h $HOST \
    -p $PORT \
    -U $USER \
    -d $DB \
    -f $SQL \
    -c "${SQL_FUNCTION}" \
    --set ON_ERROR_ROLLBACK=on \
    --set ON_ERROR_STOP=off
    )

echo "$METRICS"

echo "* Migration finished"
echo
exit 0
