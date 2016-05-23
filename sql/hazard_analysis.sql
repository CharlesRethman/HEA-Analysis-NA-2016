-- Remove old index
DROP INDEX IF EXISTS nam.buffer_20160515_gidx;
DROP INDEX IF EXISTS nam.demog_eas_gidx;
-- Recreate it
CREATE INDEX buffer_20160515_gidx ON nam.buffer_20160515 USING GIST(the_geom);
CREATE INDEX demog_eas_gidx ON nam.demog_eas USING GIST(the_geom);


-- Remove any old table of affected small areas
DROP TABLE IF EXISTS nam.eas_outcome_2016;
-- create a new table of affected small areas, with pop_size, lz_code, lz_abbrev and lz_name columns
CREATE TABLE nam.eas_outcome_2016 (
	gid SERIAL PRIMARY KEY,
	the_geom GEOMETRY(MULTIPOLYGON, 300000),
	ea_code INTEGER,
	region_cod VARCHAR(50),
	constituen VARCHAR(50),
	constitue1 VARCHAR(50),
	region_nam VARCHAR(50),
	-- population
	pop_size INTEGER,
	pop_curr NUMERIC,
	hh_curr NUMERIC,
	-- livelihood zone code
	lz_code INTEGER,
	-- livelihood zone name
	lz_name VARCHAR(254),
	-- livelihood zone abbrev
	lz_abbrev VARCHAR(5),
	hazard VARCHAR(20),
	wg VARCHAR(10),
	soc_sec INTEGER,
	pc_pop NUMERIC,
	lhood_def NUMERIC,
	surv_def NUMERIC
	);


-- insert the data where the hazard has been worst
SELECT 'Add in all the hazard data in the worst-case affected area'::text;

INSERT INTO nam.eas_outcome_2016 (
	the_geom,
	ea_code,
	region_cod,
	constituen,
	constitue1,
	region_nam,
	pop_size,
	pop_curr,
	hh_curr,
	lz_code,
	lz_name,
	lz_abbrev,
	hazard,
	wg,
	soc_sec,
	pc_pop,
	lhood_def,
	surv_def
	)
	-- data comes from nested query combining SAs, SPI data, rural and urban livelihoods tables
	SELECT
		g.the_geom,
		g.ea_code,
		g.region_cod,
		constituen,
		constitue1,
		region_nam,
		g.pop_size,
		g.pop_curr,
		g.hh_curr,
		g.lz_code,
		g.lz_name,
		lz_abbrev,
		hazard,
		wg,
		soc_sec,
		pc_pop,
		lhood_def,
		surv_def
	FROM
		nam.tbl_outcomes,
		(
		SELECT
			the_geom
		FROM
			nam.buffer_20160515
		) AS f,
		(
		SELECT
			the_geom,
			ea_code,
			nam.demog_eas.region_cod,
			constituen,
			constitue1,
			region_nam,
			nam.demog_eas.pop_size,
			nam.demog_eas.pop_size * pop_2016 / nam.tbl_pop_proj.pop_size AS pop_curr,
			nam.demog_eas.hh_size * pop_2016 / nam.tbl_pop_proj.pop_size  AS hh_curr,
			nam.demog_eas.lz_code AS lz_code,
			h.lz_name,
			h.lz_abbrev
		FROM
			nam.tbl_pop_proj,
			nam.demog_eas,
			(
				SELECT lz_code, lz_name, lz_abbrev FROM nam.livezones
			) AS h
		WHERE
			nam.demog_eas.lz_code = h.lz_code
		AND
			nam.demog_eas.lz_code < 56800
		AND
			nam.demog_eas.region_cod = nam.tbl_pop_proj.region_cod
--		AND (
--			nam.demog_eas.lz_code < 56800
--			)
		) AS g
--			(nam.demog_eas.lz_code >= 56200 AND nam.demog_eas.lz_code < 56250) OR
--			(nam.demog_eas.lz_code >= 56300 AND nam.demog_eas.lz_code < 56350))
	WHERE
		ST_Intersects (g.the_geom, f.the_geom)
	AND
		g.lz_code = nam.tbl_outcomes.lz_code
	AND
		hazard = 'Affected'

;


-- insert the data where the hazard is lighter
SELECT 'Add in all the hazard data in the less-affected area'::text;

INSERT INTO nam.eas_outcome_2016 (
	the_geom,
	ea_code,
	region_cod,
	constituen,
	constitue1,
	region_nam,
	pop_size,
	pop_curr,
	hh_curr,
	lz_code,
	lz_name,
	lz_abbrev,
	hazard,
	wg,
	soc_sec,
	pc_pop,
	lhood_def,
	surv_def
	)
	-- data comes from nested query combining SAs, SPI data, rural and urban livelihoods tables
	SELECT
		g.the_geom,
		g.ea_code,
		g.region_cod,
		constituen,
		constitue1,
		region_nam,
		g.pop_size,
		g.pop_curr,
		g.hh_curr,
		g.lz_code,
		g.lz_name,
		lz_abbrev,
		hazard,
		wg,
		soc_sec,
		pc_pop,
		lhood_def,
		surv_def
	FROM
		nam.tbl_outcomes,
		(
		SELECT
			the_geom,
			ea_code,
			nam.demog_eas.region_cod,
			constituen,
			constitue1,
			region_nam,
			nam.demog_eas.pop_size,
			nam.demog_eas.pop_size * pop_2016 / nam.tbl_pop_proj.pop_size AS pop_curr,
			nam.demog_eas.hh_size * pop_2016 / nam.tbl_pop_proj.pop_size  AS hh_curr,
			nam.demog_eas.lz_code AS lz_code,
			h.lz_name,
			h.lz_abbrev
		FROM
			nam.tbl_pop_proj,
			nam.demog_eas,
			(
				SELECT lz_code, lz_name, lz_abbrev FROM nam.livezones
			) AS h
		WHERE
			nam.demog_eas.lz_code = h.lz_code
		AND
			nam.demog_eas.lz_code < 56800
		AND
			nam.demog_eas.region_cod = nam.tbl_pop_proj.region_cod
--		AND (
--			nam.demog_eas.lz_code < 56800
--			)
		) AS g
--			(nam.demog_eas.lz_code >= 56200 AND nam.demog_eas.lz_code < 56250) OR
--			(nam.demog_eas.lz_code >= 56300 AND nam.demog_eas.lz_code < 56350))
	WHERE
		ea_code NOT IN (
			SELECT
				ea_code
			FROM
				nam.demog_eas,
				nam.buffer_20160515
			WHERE
				ST_Intersects(nam.demog_eas.the_geom, nam.buffer_20160515.the_geom)
		)
	AND
		g.lz_code = nam.tbl_outcomes.lz_code
	AND
		hazard = 'Not affected'

;

COPY (
	SELECT
		ea_code,
		region_cod AS region_code,
		region_nam AS region,
		constituen AS const_code,
		constitue1 AS constituency,
		lz_code || ': ' || lz_name || ' (' || lz_abbrev || ')' AS lz,
		hazard,
		wg,
		soc_sec,
		pop_size,
		pop_curr,
		round(pop_curr * pc_pop * CAST( surv_def > 0.005 AS INTEGER), 0) AS pop_surv,
		round(pop_curr * pc_pop * CAST( lhood_def > 0.005 AS INTEGER), 0) AS pop_lhood,
		round(pop_curr * pc_pop * surv_def * 2100 / 3360.0 / 1000, 4) AS maize_eq,
		round(hh_curr * pc_pop * lhood_def, 0) AS lhood_nad
	FROM
		nam.eas_outcome_2016)
TO
	'/Users/Charles/Documents/hea_analysis/namibia/2016.05/pop/outcome.csv'
WITH (
	FORMAT CSV, DELIMITER ','
	)
;


SELECT DISTINCT
	ea_code,
--	region_cod,
--	constituen,
	constitue1 AS constituency,
	region_nam AS region,
	lz_code  AS lz, --|| ': ' || lz_abbrev || ' - ' || lz_name AS lz,
	hazard,
	wg,
	soc_sec,
	pop_size,
	pop_curr,
	round(pop_curr * pc_pop * CAST( surv_def > 0.005 AS INTEGER), 0) AS pop_surv,
	round(pop_curr * pc_pop * CAST( lhood_def > 0.005 AS INTEGER), 0) AS pop_lhood,
	round(pop_curr * pc_pop * surv_def * 2100 / 3360.0 / 1000, 4) AS maize_eq,
	round(hh_curr * pc_pop * lhood_def, 0) AS lhood_nad
FROM
	nam.eas_outcome_2016
ORDER BY
	ea_code, lz, hazard, soc_sec, wg
;
