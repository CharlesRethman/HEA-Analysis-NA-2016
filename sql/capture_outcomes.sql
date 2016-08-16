DROP TABLE IF EXISTS nam.tbl_outcomes;

CREATE TABLE nam.tbl_outcomes (
  id SERIAL PRIMARY KEY,
  "month" VARCHAR(9),
  "year" INTEGER,
  lz_name VARCHAR(255),
  lz_code INTEGER,
  hazard VARCHAR(50),
  soc_sec SMALLINT,
  wg  VARCHAR(20),
  pc_pop NUMERIC,
  lhood_def NUMERIC,
  surv_def NUMERIC
  )
;


COPY nam.tbl_outcomes (
  "month",
  "year",
  lz_name,
  lz_code,
  hazard,
  soc_sec,
  wg,
  pc_pop,
  lhood_def,
  surv_def
  )
FROM
  '/Users/Charles/Documents/hea_analysis/namibia/2016.05/pop/summary_deficit.csv'
WITH (
  FORMAT CSV,
  DELIMITER ',',
  HEADER TRUE
  )
;

SELECT * FROM nam.tbl_outcomes;
