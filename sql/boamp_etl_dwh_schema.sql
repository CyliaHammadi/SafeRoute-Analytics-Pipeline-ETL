-- =====================================================================
-- BOAMP - Mini projet ETL / DWH 
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Couche brute et staging
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ops_batch_control (
    batch_id TEXT PRIMARY KEY,
    batch_type TEXT NOT NULL,
    source_system TEXT NOT NULL,
    extraction_ts TIMESTAMPTZ NOT NULL,
    received_records INTEGER NOT NULL,
    status TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS raw_notice (
    batch_id TEXT NOT NULL,
    batch_type TEXT NOT NULL,
    source_system TEXT NOT NULL,
    extraction_ts TIMESTAMPTZ NOT NULL,
    page_no INTEGER NOT NULL,
    record_hash TEXT NOT NULL,
    payload_json JSONB NOT NULL,
    PRIMARY KEY (batch_id, page_no)
);

CREATE TABLE IF NOT EXISTS stg_raw_notice (
    batch_id TEXT NOT NULL,
    batch_type TEXT NOT NULL,
    source_system TEXT NOT NULL,
    extraction_ts TIMESTAMPTZ NOT NULL,
    record_hash TEXT NOT NULL,
    idweb TEXT,
    objet TEXT,
    dateparution_raw TEXT,
    datelimitereponse_raw TEXT,
    nomacheteur_top TEXT,
    type_marche_top TEXT,
    url_avis TEXT,
    gestion_publication_date TEXT,
    gestion_deadline_date TEXT,
    buyer_name_donnees TEXT,
    cpv_raw JSONB
);

CREATE TABLE IF NOT EXISTS stg_notice_std (
    batch_id TEXT NOT NULL,
    record_hash TEXT NOT NULL,
    idweb TEXT NOT NULL,
    objet TEXT,
    buyer_name TEXT NOT NULL,
    publication_ts TIMESTAMPTZ NOT NULL,
    deadline_ts TIMESTAMPTZ,
    response_delay_days INTEGER,
    market_type_code TEXT NOT NULL,
    url_avis TEXT,
    has_deadline_flag BOOLEAN NOT NULL,
    PRIMARY KEY (idweb, record_hash)
);

CREATE TABLE IF NOT EXISTS stg_notice_cpv (
    idweb TEXT NOT NULL,
    cpv_code TEXT NOT NULL,
    is_primary_flag BOOLEAN NOT NULL,
    PRIMARY KEY (idweb, cpv_code)
);

CREATE TABLE IF NOT EXISTS stg_reject_notice (
    batch_id TEXT NOT NULL,
    idweb TEXT,
    reject_rule TEXT NOT NULL,
    reject_reason TEXT NOT NULL,
    raw_payload_hash TEXT NOT NULL
);

-- ---------------------------------------------------------------------
-- 2. Couche transformation
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tr_notice_kpi_base (
    idweb TEXT PRIMARY KEY,
    batch_id TEXT NOT NULL,
    publication_date DATE NOT NULL,
    buyer_name TEXT NOT NULL,
    market_type_code TEXT NOT NULL,
    response_delay_days INTEGER,
    has_deadline_flag BOOLEAN NOT NULL,
    url_avis TEXT,
    objet_court TEXT,
    notice_count INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS tr_notice_cpv (
    idweb TEXT NOT NULL,
    cpv_code TEXT NOT NULL,
    is_primary_flag BOOLEAN NOT NULL,
    PRIMARY KEY (idweb, cpv_code)
);

-- ---------------------------------------------------------------------
-- 3. Data warehouse
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    day INTEGER NOT NULL,
    month_label TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_buyer (
    buyer_key INTEGER PRIMARY KEY,
    buyer_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_market_type (
    market_type_key INTEGER PRIMARY KEY,
    market_type_code TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_cpv (
    cpv_key INTEGER PRIMARY KEY,
    cpv_code TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS fact_notice_publication (
    fact_notice_key INTEGER PRIMARY KEY,
    notice_business_id TEXT NOT NULL UNIQUE,
    date_key INTEGER NOT NULL REFERENCES dim_date(date_key),
    buyer_key INTEGER NOT NULL REFERENCES dim_buyer(buyer_key),
    market_type_key INTEGER NOT NULL REFERENCES dim_market_type(market_type_key),
    notice_count INTEGER NOT NULL,
    response_delay_days INTEGER,
    has_deadline_flag BOOLEAN NOT NULL,
    batch_id TEXT NOT NULL,
    url_avis TEXT,
    objet_court TEXT
);

CREATE TABLE IF NOT EXISTS fact_notice_cpv (
    fact_notice_key INTEGER NOT NULL REFERENCES fact_notice_publication(fact_notice_key),
    notice_business_id TEXT NOT NULL,
    date_key INTEGER NOT NULL REFERENCES dim_date(date_key),
    cpv_key INTEGER NOT NULL REFERENCES dim_cpv(cpv_key),
    is_primary_flag BOOLEAN NOT NULL,
    PRIMARY KEY (fact_notice_key, cpv_key)
);

-- ---------------------------------------------------------------------
-- 4. Exploitation et monitoring
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ops_job_definition (
    job_name TEXT PRIMARY KEY,
    layer TEXT NOT NULL,
    schedule TEXT NOT NULL,
    depends_on TEXT,
    sla_target TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS ops_job_run (
    run_id TEXT PRIMARY KEY,
    job_name TEXT NOT NULL REFERENCES ops_job_definition(job_name),
    batch_id TEXT NOT NULL,
    start_ts TIMESTAMPTZ NOT NULL,
    end_ts TIMESTAMPTZ NOT NULL,
    duration_seconds INTEGER NOT NULL,
    status TEXT NOT NULL,
    retry_count INTEGER NOT NULL,
    rows_read INTEGER NOT NULL,
    rows_rejected INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS ops_job_step_run (
    run_id TEXT NOT NULL REFERENCES ops_job_run(run_id),
    step_name TEXT NOT NULL,
    status TEXT NOT NULL,
    rows_read INTEGER NOT NULL,
    rows_rejected INTEGER NOT NULL,
    PRIMARY KEY (run_id, step_name)
);

-- ---------------------------------------------------------------------
-- 5. Index utiles
-- ---------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_raw_notice_batch_id ON raw_notice(batch_id);
CREATE INDEX IF NOT EXISTS idx_stg_notice_std_idweb ON stg_notice_std(idweb);
CREATE INDEX IF NOT EXISTS idx_fact_notice_publication_date_key ON fact_notice_publication(date_key);
CREATE INDEX IF NOT EXISTS idx_fact_notice_publication_buyer_key ON fact_notice_publication(buyer_key);
CREATE INDEX IF NOT EXISTS idx_fact_notice_cpv_cpv_key ON fact_notice_cpv(cpv_key);
