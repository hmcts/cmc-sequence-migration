#!/usr/bin/env sh

echo
set -e
set -u
echo "* Starting migration..."
echo

if [ "$#" -ne 11 ]; then
    echo "* Illegal number of arguments."
    echo "* Usage: $0 [old_host] [old_port] [old_username] [old_password] [old_db] [referenceType] [new_host] [new_port] [new_username] [new_password] [new_db]"
    echo
    echo "* Exiting"
    echo
    exit 1
fi

OLD_HOST="$1"
OLD_PORT="$2"
OLD_USERNAME="$3"
OLD_PASSWORD="$4"
OLD_DB="$5"
REFERENCETYPE="$6"
NEW_HOST="$7"
NEW_PORT="$8"
NEW_USERNAME="$9"
NEW_PASSWORD="${10}"
NEW_DB="${11}"

echo "* OLD DB hostname: $OLD_HOST"
echo "* OLD DB port: $OLD_PORT"
echo "* OLD DB username: $OLD_USERNAME"
echo "* OLD DB password: $OLD_PASSWORD"
echo "* OLD DB name: $OLD_DB"

echo "* SELECTED REFERENCE TYPE: $REFERENCETYPE"

echo "* NEW DB hostname: $NEW_HOST"
echo "* NEW DB port: $NEW_PORT"
echo "* NEW DB username: $NEW_USERNAME"
echo "* NEW DB password: $NEW_PASSWORD"
echo "* NEW DB name: $NEW_DB"
echo

OLD_CONN_STR="host=$OLD_HOST port=$OLD_PORT dbname=$OLD_DB user=$OLD_USERNAME password=$OLD_PASSWORD sslmode=require"
NEW_CONN_STR="host=$NEW_HOST port=$NEW_PORT dbname=$NEW_DB user=$NEW_USERNAME password=$NEW_PASSWORD sslmode=require"

LAST_VAL_SQL="SELECT last_value from claim_reference_number_seq"
LAST_VAL_LEGAL_SQL="SELECT last_value from claim_legal_rep_reference_number_seq"

if [ "$REFERENCETYPE" == "legal" ]; then
    LAST_VAL_SQL=$LAST_VAL_LEGAL_SQL
fi

LAST_VAL=$(psql "${OLD_CONN_STR}" \
    -t \
    -c "${LAST_VAL_SQL}" \
    --set ON_ERROR_ROLLBACK=on \
    --set ON_ERROR_STOP=off
    )

echo "LAST SEQUENCE VALUE FROM OLD DB: $LAST_VAL"

SEQ_VAL_BEFORE_UPDATE=$(psql "${NEW_CONN_STR}" \
    -t \
    -c "${LAST_VAL_SQL}" \
    --set ON_ERROR_ROLLBACK=on \
    --set ON_ERROR_STOP=off
    )

echo "SEQUENCE VALUE IN NEW DB BEFORE UPDATE: $SEQ_VAL_BEFORE_UPDATE"

UPDATE_VAL_SQL="SELECT setval('claim_reference_number_seq', $LAST_VAL)"
UPDATE_LEGAL_SQL="SELECT setval('claim_legal_rep_reference_number_seq', $LAST_VAL)"

if [ "$REFERENCETYPE" == "legal" ]; then
    UPDATE_VAL_SQL=$UPDATE_LEGAL_SQL
fi

UPDATE_NEW_DB=$(psql "${NEW_CONN_STR}" \
    -t \
    -c "${UPDATE_VAL_SQL}" \
    --set ON_ERROR_ROLLBACK=on \
    --set ON_ERROR_STOP=off
    )

echo "UPDATE SEQUENCE VALUE ON NEW DB: $UPDATE_NEW_DB"

SEQ_VAL_AFTER_UPDATE=$(psql "${NEW_CONN_STR}" \
    -t \
    -c "${LAST_VAL_SQL}" \
    --set ON_ERROR_ROLLBACK=on \
    --set ON_ERROR_STOP=off
    )

echo "SEQUENCE VALUE IN NEW DB AFTER UPDATE: $SEQ_VAL_AFTER_UPDATE"

echo "* Migration finished"
echo
exit 0


