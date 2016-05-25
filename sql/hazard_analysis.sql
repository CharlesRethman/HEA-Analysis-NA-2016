-- Purpose: to construct a table of outcomes that can be mapped an from which
-- total numbers of affected people and their deficits can be calculated.

-- Index transaction: to speed up the the main insert query
BEGIN;

-- Remove old indexes
DROP INDEX IF EXISTS nam.buffer_20160515_gidx;

DROP INDEX IF EXISTS nam.demog_eas_gidx;

-- Recreate them or create new ones
CREATE INDEX buffer_20160515_gidx ON nam.buffer_20160515 USING GIST(the_geom);

CREATE INDEX demog_eas_gidx ON nam.demog_eas USING GIST(the_geom);

-- Done.
COMMIT;



-- Main transaction. Create an output table and populate it with the analysis.
BEGIN;

-- Remove any old table of affected small areas
DROP TABLE IF EXISTS nam.eas_outcome_2016;

-- create a new table with the key outcome information for all affected
-- enumeration areas, with admin, livelihood zone, wealth group definition
-- social security, hazard and outcome information
CREATE TABLE nam.eas_outcome_2016 (
	gid SERIAL PRIMARY KEY,
	the_geom GEOMETRY(MULTIPOLYGON, 300000),
	ea_code INTEGER,
	region_cod VARCHAR(50),
	region_nam VARCHAR(50),
	constituen VARCHAR(50),
	constitue1 VARCHAR(50),
	-- population
	pop_size INTEGER,
	pop_curr NUMERIC,
	hh_curr NUMERIC,
	-- livelihood zones: code, abbrev, name and wealth group
	lz_code INTEGER,
	lz_abbrev VARCHAR(5),
	lz_name VARCHAR(254),
	wg VARCHAR(10),
	-- Whether they have social security (soc_sec) and the hazards they're
	-- affected by
	soc_sec INTEGER,
	hazard VARCHAR(20),
	-- outcomes, percent population affected (pc_pop), livelihood deficit
	-- (lhood_def) and survival deficit (surv_def)
	pc_pop NUMERIC,
	lhood_def NUMERIC,
	surv_def NUMERIC
	)
;

-- insert the data where the hazard has been worst
SELECT 'Add in all the hazard data in the worst-case affected area'::text;

INSERT INTO nam.eas_outcome_2016 (
	the_geom,
	ea_code,
	region_cod,
	region_nam,
	constituen,
	constitue1,
	pop_size,
	pop_curr,
	hh_curr,
	lz_code,
	lz_abbrev,
	lz_name,
	wg,
	soc_sec,
	hazard,
	pc_pop,
	lhood_def,
	surv_def
	)
	-- data comes from nested query combining SAs, SPI data, rural and urban livelihoods tables
	SELECT
			g.the_geom,
			g.ea_code,
			g.region_cod,
			region_nam,
			constituen,
			constitue1,
			g.pop_size,
			g.pop_curr,
			g.hh_curr,
			g.lz_code,
			lz_abbrev,
			g.lz_name,
			wg,
			soc_sec,
			hazard,
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
				) AS g
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
	-- data comes from nested query combining EAs, hazard area, livelihoods and
	-- analysis tables
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
				) AS g
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

COMMIT;



--Transaction to present the data in a file and on StdOut
BEGIN;

-- Output the table to a CSV file for spreadsheet input
COPY (
	SELECT
			ea_code,
			region_cod AS region_code,
			region_nam AS region,
			constituen AS const_code,
			constitue1 AS constituency,
			lz_code || ': ' || lz_name || ' (' || lz_abbrev || ')' AS lz,
			hazard,
			nam.eas_outcome_2016.wg,
			soc_sec,
			pop_size,
			pop_curr,
			round(pop_curr * pc_pop * CAST( surv_def > 0.005 AS INTEGER), 0) AS pop_surv,
			round(pop_curr * pc_pop * CAST( lhood_def > 0.005 AS INTEGER), 0) AS pop_lhood,
			round(pop_curr * pc_pop * surv_def * 2100 / 3360.0 / 1000, 4) AS maize_eq,
			round(hh_curr * pc_pop * lhood_def, 0) AS lhood_nad
		FROM
			nam.eas_outcome_2016,
			(VALUES (1, 'very poor'), (2, 'poor'), (3, 'middle'), (4, 'rich'), (4, 'better off'), (4, 'better-off')) AS f (ordnum,wg)
		WHERE
			lower(nam.eas_outcome_2016.wg) = f.wg
	ORDER BY
		ea_code,
		hazard,
		soc_sec,
		f.ordnum
	)
TO
	'/Users/Charles/Documents/hea_analysis/namibia/2016.05/pop/outcome.csv'
WITH (
	FORMAT CSV, DELIMITER ',', HEADER TRUE
	)
;

COPY (
	SELECT
			row_name[1] AS region,
			row_name[2] AS constituency,
			"56101: Kunene cattle and small stock (NAKCS)",
			"56102: Omusati-Omaheke-Otjozondjupa cattle ranching (NACCR)",
			"56103: Erongo-Kunene small stock and natural resources (NACSN)",
			"56105: Southern communal small stock (NACSS)",
			"56182: Central freehold cattle ranching (NAFCR)",
			"56184: Southern freehold small stock (NAFSS)",
			"56201: Northern border upland cereals and livestock (NAUCL)"
			"56202: North-central upland cereals and non-farm income (NAUCI)",
			"56203: Caprivi lowland maize and cattle (NALMC)"
		FROM
			crosstab('
				SELECT
						ARRAY[ region_nam::text, constitue1::text] AS row_name,
						lz_code,
						ROUND(SUM(pop_curr * pc_pop * CAST( surv_def > 0.005 AS INTEGER)), 0) AS pop_surv
					FROM
						nam.eas_outcome_2016
					GROUP BY
						region_nam,
						constitue1,
						lz_code
					ORDER BY
						1,
						2,
						3
				') AS ct(
					row_name text[],
					"56101: Kunene cattle and small stock (NAKCS)" NUMERIC,
					"56102: Omusati-Omaheke-Otjozondjupa cattle ranching (NACCR)" NUMERIC,
					"56103: Erongo-Kunene small stock and natural resources (NACSN)" NUMERIC,
					"56105: Southern communal small stock (NACSS)" NUMERIC,
					"56182: Central freehold cattle ranching (NAFCR)",
					"56184: Southern freehold small stock (NAFSS)",
					"56201: Northern border upland cereals and livestock (NAUCL)",
					"56202: North-central upland cereals and non-farm income (NAUCI)",
					"56203: Caprivi lowland maize and cattle (NALMC)"
				)
	)
TO
	'/Users/Charles/Documents/hea_analysis/namibia/2016.05/pop/outcome_xtab.csv'
WITH (
	FORMAT CSV, DELIMITER ',', HEADER TRUE
	)
;

SELECT
		ea_code,
		region_nam AS region,
		constitue1 AS constituency,
		lz_code || ': '  || lz_name || ' (' || lz_abbrev || ')' AS lz,
		hazard,
		nam.eas_outcome_2016.wg,
		soc_sec AS s,
--		pop_size,
		pop_curr,
		round(pop_curr * pc_pop * CAST( surv_def > 0.005 AS INTEGER), 0) AS pop_surv,
		round(pop_curr * pc_pop * CAST( lhood_def > 0.005 AS INTEGER), 0) AS pop_lhood,
		round(pop_curr * pc_pop * surv_def * 2100 / 3360.0 / 1000, 4) AS maize_eq,
		round(hh_curr * pc_pop * lhood_def, 0) AS lhood_nad
	FROM
		nam.eas_outcome_2016,
		(VALUES (1, 'very poor'), (2, 'poor'), (3, 'middle'), (4, 'rich'), (4, 'better off'), (4, 'better-off')) AS f (ordnum,wg)
	WHERE
		lower(nam.eas_outcome_2016.wg) = f.wg
	ORDER BY
		ea_code,
		hazard,
		s,
		f.ordnum
;

COMMIT;


COPY (
	SELECT
			row_name[1] AS region,
			row_name[2] AS constituency,
			"56101: Kunene cattle and small stock (NAKCS)",
			"56102: Omusati-Omaheke-Otjozondjupa cattle ranching (NACCR)",
			"56103: Erongo-Kunene small stock and natural resources (NACSN)",
			"56105: Southern communal small stock (NACSS)",
			"56182: Central freehold cattle ranching (NAFCR)",
			"56184: Southern freehold small stock (NAFSS)",
			"56201: Northern border upland cereals and livestock (NAUCL)"
			"56202: North-central upland cereals and non-farm income (NAUCI)",
			"56203: Caprivi lowland maize and cattle (NALMC)"
		FROM
			crosstab('
				SELECT
						ARRAY[ region_nam::text, constitue1::text] AS row_name,
						lz_code,
						ROUND(SUM(pop_curr * pc_pop * CAST( surv_def > 0.005 AS INTEGER)), 0) AS pop_surv
					FROM
						nam.eas_outcome_2016
					GROUP BY
						region_nam,
						constitue1,
						lz_code
					ORDER BY
						1,
						2,
						3
				') AS ct(
					row_name text[],
					"56101: Kunene cattle and small stock (NAKCS)" NUMERIC,
					"56102: Omusati-Omaheke-Otjozondjupa cattle ranching (NACCR)" NUMERIC,
					"56103: Erongo-Kunene small stock and natural resources (NACSN)" NUMERIC,
					"56105: Southern communal small stock (NACSS)" NUMERIC,
					"56182: Central freehold cattle ranching (NAFCR)",
					"56184: Southern freehold small stock (NAFSS)",
					"56201: Northern border upland cereals and livestock (NAUCL)",
					"56202: North-central upland cereals and non-farm income (NAUCI)",
					"56203: Caprivi lowland maize and cattle (NALMC)"
				)
	)
TO
	'/Users/Charles/Documents/hea_analysis/namibia/2016.05/pop/outcome_xtab.csv'
WITH (
	FORMAT CSV, DELIMITER ',', HEADER TRUE
	)
;

/*SELECT
		lz_code || ': '  || lz_name || ' (' || lz_abbrev || ')' AS lz,
	FROM
		nam.eas_outcome_2016;
