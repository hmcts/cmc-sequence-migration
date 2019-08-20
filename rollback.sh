#!/bin/sh

echo
set -e
set -u

echo "* Starting migration..."
echo

if [ "$#" -ne 5 ]; then
    echo "* Illegal number of arguments."
    echo "* Usage: $0 [new_host] [new_port] [new_username] [new_db] [referenceType]"
    echo
    echo "* Exiting"
    echo
    exit 1
fi

NEW_HOST="$1"
NEW_PORT="$2"
NEW_USERNAME="$3"
NEW_DB="$4"
REFERENCETYPE="$5"


echo "* NEW DB hostname: $NEW_HOST"
echo "* NEW DB port: $NEW_PORT"
echo "* NEW DB username: $NEW_USERNAME"
echo "* NEW DB name: $NEW_DB"
echo "* SELECTED REFERENCE TYPE: $REFERENCETYPE"
echo

NEW_CONN_STR="host=$NEW_HOST port=$NEW_PORT dbname=$NEW_DB user=$NEW_USERNAME sslmode=require"

DROP_REFERENCE_SQL=""
DROP_LEGAL_REFERENCE_SQL=""

if [ "$REFERENCETYPE" == "legal" ]; then
    DROP_REFERENCE_SQL=$DROP_LEGAL_REFERENCE_SQL
fi

DROPPED_REF=$(psql "${NEW_CONN_STR}" \
    -t \
    -c "${DROP_REFERENCE_SQL}" \
    --set ON_ERROR_ROLLBACK=on \
    --set ON_ERROR_STOP=off
    )

echo "REFERENCE DROPPED FROM NEW DB: $DROPPED_REF"


DROP_FUNCTION_SQL=""
DROP_LEGAL_FUNCTION_SQL=""

if [ "$REFERENCETYPE" == "legal" ]; then
    DROP_FUNCTION_SQL=$DROP_LEGAL_FUNCTION_SQL
fi

DROPPED_FUNCTION=$(psql "${NEW_CONN_STR}" \
    -t \
    -c "${DROP_FUNCTION_SQL}" \
    --set ON_ERROR_ROLLBACK=on \
    --set ON_ERROR_STOP=off
    )

echo "DROPPED FUNCTION ON NEW DB: $DROPPED_FUNCTION"

echo "* Migration finished"
echo
exit 0
