-- Remove old index
DROP INDEX IF EXISTS nam.buffer_20160515_gidx;
-- Recreate it
CREATE INDEX nam.buffer_20160515_gidx ON nam.buffer_20160515 USING GIST(the_geom);

-- Remove any old table of affected small areas
DROP TABLE IF EXISTS nam.eas_affected_2016;
-- create a new table of affected small areas, with pop_size, lz_code, lz_abbrev and lz_name columns
CREATE TABLE nam.eas_affected_2016 (
	gid SERIAL PRIMARY KEY,
	the_geom GEOMETRY(MULTIPOLYGON, 300000),
	ea_code INTEGER,
	region_cod VARCHAR(50),
	constituen VARCHAR(50),
	constitue1 VARCHAR(50),
	region_nam VARCHAR(50),
	-- population
	pop_size INTEGER,
	-- livelihood zone code
	lz_code INTEGER,
	-- livelihood zone name
	lz_name VARCHAR(254),
	-- livelihood zone abbrev
	lz_abbrev VARCHAR(5)
	);
-- insert data into this newly created table
INSERT INTO nam.eas_affected_2016 (
	the_geom,
	ea_code,
	region_cod,
	constituen,
	constitue1,
	region_nam,
	pop_size,
	lz_code,
	lz_name,
	lz_abbrev)
	-- data comes from nested query combining SAs, SPI data, rural and urban livelihoods tables
	SELECT
		g.the_geom,
		g.ea_code,
		region_cod,
		constituen,
		constitue1,
		region_nam,
		total,
		lz_code,
		lz_name,
		lz_abbrev
	FROM (
		SELECT
			*
		FROM
			nam.buffer_20160515
		WHERE
			ndvi = 1
		) AS f,
		(
		SELECT
			the_geom,
			ea_code,
			region_cod,
			constituen,
			mn_name,
			constitue1,
			region_nam,
			total,
			nam.demog_eas.lz_code AS lz_code,
			h.lz_name,
			h.lz_abbrev
		FROM
			nam.demog_eas,
			(
				SELECT lz_code, lz_name, lz_abbrev FROM livezones
			) AS h
		WHERE
			nam.demog_eas.lz_code = h.lz_code
		AND (
			nam.demog_eas.lz_code < 56800 OR
			(nam.demog_eas.lz_code >= 56200 AND nam.demog_eas.lz_code < 56250) OR
			(nam.demog_eas.lz_code >= 56300 AND nam.demog_eas.lz_code < 56350))
		)
		AS g
	WHERE
		ST_Intersects (g.the_geom, f.the_geom)
;


SELECT DISTINCT
	ea_code,
	region_cod,
	constituen,
	mn_name,
	constitue1,
	region_nam,
	lz_code || ': ' || lz_abbrev || ' - ' || lz_name AS lz,
	pop_size,
	round(pop_size * 0.4,0) AS pop_affected
FROM
	nam.eas_affected_2016
ORDER BY
	ea_code
;
