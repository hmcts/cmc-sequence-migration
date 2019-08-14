#!/bin/sh

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

echo "* Migration finished"
echo
exit 0
