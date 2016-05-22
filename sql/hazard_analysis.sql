-- Remove old index
DROP INDEX IF EXISTS zaf.hazard_spi_gidx;
-- Recreate it
CREATE INDEX hazard_spi_gidx ON zaf.hazard_spi_2015 USING GIST(the_geom);

-- Remove any old table of affected small areas
DROP TABLE IF EXISTS zaf.sas_affected_2015;
-- create a new table of affected small areas, with pop, lz_code, lz_abbrev and lz_name columns
CREATE TABLE zaf.sas_affected_2015 (
	gid SERIAL PRIMARY KEY,
	the_geom GEOMETRY(MULTIPOLYGON, 201100),
	sa_code INTEGER,
	sp_name VARCHAR(254),
	mp_name VARCHAR(254),
	mn_name VARCHAR(254),
	dc_name VARCHAR(254),
	pr_name VARCHAR(254),
	-- population
	pop INTEGER,
	-- livelihood zone code
	lz_code INTEGER,
	-- livelihood zone name
	lz_name VARCHAR(254),
	-- livelihood zone abbrev
	lz_abbrev VARCHAR(5)
	);
-- insert data into this newly created table
INSERT INTO zaf.sas_affected_2015 (
	the_geom,
	sa_code,
	sp_name,
	mp_name,
	mn_name,
	dc_name,
	pr_name,
	pop,
	lz_code,
	lz_name,
	lz_abbrev)
	-- data comes from nested query combining SAs, SPI data, rural and urban livelihoods tables
	SELECT
		g.the_geom,
		g.sa_code,
		sp_name,
		mp_name,
		mn_name,
		dc_name,
		pr_name,
		total,
		lz_code,
		lz_name,
		lz_abbrev
	FROM (
		SELECT
			*
		FROM
			zaf.hazard_spi_2015
		WHERE
			spi01 < -1
		) AS f,
		( 
		SELECT
			the_geom,
			zaf.demog_sas.sa_code,
			sp_name,
			mp_name,
			mn_name,
			dc_name,
			pr_name,
			total,
			zaf.demog_sas.lz_code AS lz_code,
			h.lz_name,
			h.lz_abbrev
		FROM 
			zaf.demog_sas,
			zaf.tbl_pop_age_gender,
			(
			SELECT i.lz_code, i.lz_name, i.lz_abbrev FROM (
				SELECT lz_code, lz_name, lz_abbrev FROM zaf.livezones_rural 
				UNION SELECT lz_code, lz_name, lz_abbrev FROM zaf.livezones_urban
				) AS i
			GROUP BY lz_code, lz_name, lz_abbrev
			) AS h
		WHERE
			zaf.demog_sas.sa_code = zaf.tbl_pop_age_gender.sa_code AND zaf.demog_sas.lz_code = h.lz_code
		AND (
			zaf.demog_sas.lz_code < 59150 OR
			(zaf.demog_sas.lz_code >= 59200 AND zaf.demog_sas.lz_code < 59250) OR 
			(zaf.demog_sas.lz_code >= 59300 AND zaf.demog_sas.lz_code < 59350))
		) 
		AS g
	WHERE
		ST_Intersects (g.the_geom, ST_Transform(f.the_geom, 201100))
;


SELECT DISTINCT
	sa_code, 
	sp_name, 
	mp_name, 
	mn_name, 
	dc_name, 
	pr_name, 
	lz_code || ': ' || lz_abbrev || ' - ' || lz_name AS lz, 
	pop, 
	round(pop * 0.4,0) AS pop_affected 
FROM 
	zaf.sas_affected_2015 
ORDER BY 
	sa_code
;