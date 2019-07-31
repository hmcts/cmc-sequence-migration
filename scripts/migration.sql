DROP TABLE IF EXISTS TESTKARIM;
CREATE TABLE TESTKARIM( name VARCHAR(100));

CREATE OR REPLACE FUNCTION migrate_claim_reference_number(src_db_name TEXT, src_port BIGINT, src_host TEXT, src_user TEXT, src_passwd TEXT)
    RETURNS void AS $$
DECLARE
    v_last_used_val BIGINT := 0;
    v_sql    TEXT;
    conn_str TEXT := 'dbname='|| $1
                         || ' port=' || $2
                         || ' host=' || $3
                         || ' user=' || $4
                         || ' password='|| $5;
BEGIN

    CREATE EXTENSION IF NOT EXISTS dblink;
    RAISE INFO 'conn_str %', conn_str;

    v_sql := 'CREATE OR REPLACE VIEW db9_seq_lastval AS '
                 || 'SELECT * FROM dblink '
                 || '( '
                 || quote_literal(conn_str)
                 ||', '
                 || quote_literal('SELECT last_value FROM claim_reference_number_seq')
                 || ') '
        || 'AS t1(last_value text)';

    EXECUTE v_sql;
    EXECUTE 'SELECT last_value FROM db9_seq_lastval' INTO v_last_used_val;

    EXECUTE 'SELECT setval(' || quote_literal('claim_reference_number_seq') || ',' || v_last_used_val || ')';
    EXECUTE 'DROP VIEW IF EXISTS db9_seq_lastval';
END
$$ LANGUAGE plpgsql;