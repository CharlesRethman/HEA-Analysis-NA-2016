-- Purpose: to attach a Livelihood Zone Code (lz_code) column to the Demography,
-- Enumeration Areas (demog_eas) table that will effectively zone each and every
-- EA.

-- Output: New column in demog_ea table with lz_code, completed according to the
-- largest overlapping livelihood zone. A table with a list of Urban livelihood
-- zone codes.

BEGIN;



DROP TABLE IF EXISTS nam.lzs_eas CASCADE;

DROP INDEX IF EXISTS nam.demog_eas_gidx;

DROP INDEX IF EXISTS nam.livezones_gidx;

CREATE INDEX demog_eas_gidx ON nam.demog_eas USING GIST (the_geom);

CREATE INDEX livezones_gidx ON nam.livezones USING GIST (the_geom);


/*
SELECT 'Fix demog_eas table by adding the lz_code & ea_code_char columns, making ea_code INTEGER type'::text;

ALTER TABLE nam.demog_eas DROP COLUMN IF EXISTS lz_code;

ALTER TABLE nam.demog_eas DROP COLUMN IF EXISTS ea_code_char;

ALTER TABLE nam.demog_eas ADD COLUMN lz_code INTEGER;

ALTER TABLE nam.demog_eas ADD COLUMN ea_code_char VARCHAR(12);

UPDATE nam.demog_eas SET ea_code_char = CAST(ea AS TEXT);

UPDATE nam.demog_eas SET ea = CAST (ea_code AS TEXT);

UPDATE nam.demog_eas SET ea_code = ea_no;

UPDATE nam.demog_eas SET ea_no = CAST (ea AS INTEGER);
*/


SELECT 'Create a temporary lzs_eas intersection table'::text;

CREATE TABLE nam.lzs_eas(
	gid SERIAL PRIMARY KEY,
	the_geom geometry(MULTIPOLYGON,300000),
	ea_code INTEGER,
/*	ea_gtype_c INTEGER,
	ea_gtype VARCHAR(15),
	ea_type_c INTEGER,
	ea_type VARCHAR(50),*/
	lz_code INTEGER,
	area_ha NUMERIC)
;

COMMIT;


BEGIN;

SELECT 'Now add in all the LZ (livestock) EA geometries, where the EAs and LZs boundaries cross each other'::text;

INSERT INTO nam.lzs_eas(
	the_geom,
	ea_code,
/*	ea_gtype_c,
	ea_gtype,
	ea_type_c,
	ea_type,*/
	lz_code,
	area_ha)
	SELECT
		ST_Multi(
			ST_Buffer(
				ST_Intersection(nam.demog_eas.the_geom, nam.livezones.the_geom)
				, 0.0)
			),
		ea_code,
/*		ea_gtype_c,
		ea_gtype,
		ea_type_c,
		ea_type,*/
		nam.livezones.lz_code,
		0
	FROM nam.livezones
	INNER JOIN nam.demog_eas
	ON ST_Intersects(nam.demog_eas.the_geom, nam.livezones.the_geom) AND NOT ST_Within(nam.demog_eas.the_geom, nam.livezones.the_geom)
	WHERE NOT ST_IsEmpty(ST_Buffer(ST_Intersection(nam.demog_eas.the_geom, nam.livezones.the_geom),0.0))
		AND nam.livezones.lz_code < 56200
;

COMMIT;



BEGIN;

SELECT 'Now add in all the LZ (mixed) EA geometries, where the EAs and LZs boundaries cross each other'::text;

INSERT INTO nam.lzs_eas(
	the_geom,
	ea_code,
/*	ea_gtype_c,
	ea_gtype,
	ea_type_c,
	ea_type,*/
	lz_code,
	area_ha)
	SELECT
		ST_Multi(
			ST_Buffer(
				ST_Intersection(nam.demog_eas.the_geom, nam.livezones.the_geom)
				, 0.0)
			),
		ea_code,
/*		ea_gtype_c,
		ea_gtype,
		ea_type_c,
		ea_type,*/
		nam.livezones.lz_code,
		0
	FROM nam.livezones
	INNER JOIN nam.demog_eas
	ON ST_Intersects(nam.demog_eas.the_geom, nam.livezones.the_geom) AND NOT ST_Within(nam.demog_eas.the_geom, nam.livezones.the_geom)
	WHERE NOT ST_IsEmpty(ST_Buffer(ST_Intersection(nam.demog_eas.the_geom, nam.livezones.the_geom),0.0))
	AND (nam.livezones.lz_code >= 56200 AND nam.livezones.lz_code < 56300);

COMMIT;



BEGIN;

SELECT 'Now add in all the LZ (cropping+) EA geometries, where the EAs and LZs boundaries cross each other'::text;

INSERT INTO nam.lzs_eas(
	the_geom,
	ea_code,
/*	ea_gtype_c,
	ea_gtype,
	ea_type_c,
	ea_type,*/
	lz_code,
	area_ha)
	SELECT
		ST_Multi(
			ST_Buffer(
				ST_Intersection(nam.demog_eas.the_geom, nam.livezones.the_geom)
				, 0.0)
			),
		ea_code,
/*		ea_gtype_c,
		ea_gtype,
		ea_type_c,
		ea_type,*/
		nam.livezones.lz_code,
		0
	FROM nam.livezones
	INNER JOIN nam.demog_eas
	ON ST_Intersects(nam.demog_eas.the_geom, nam.livezones.the_geom) AND NOT ST_Within(nam.demog_eas.the_geom, nam.livezones.the_geom)
	WHERE NOT ST_IsEmpty(ST_Buffer(ST_Intersection(nam.demog_eas.the_geom, nam.livezones.the_geom),0.0))
	AND nam.livezones.lz_code >= 56300 AND nam.livezones.lz_code < 56800;
COMMIT;



BEGIN;

SELECT 'Now add in all the remaining LZ (Urban, government +) EA geometries, where the EAs and LZs boundaries cross each other'::text;

INSERT INTO nam.lzs_eas(
	the_geom,
	ea_code,
/*	ea_gtype_c,
	ea_gtype,
	ea_type_c,
	ea_type,*/
	lz_code,
	area_ha)
	SELECT
		ST_Multi(
			ST_Buffer(
				ST_Intersection(nam.demog_eas.the_geom, nam.livezones.the_geom)
				, 0.0)
			),
		ea_code,
/*		ea_gtype_c,
		ea_gtype,
		ea_type_c,
		ea_type,*/
		nam.livezones.lz_code,
		0
	FROM nam.livezones
	INNER JOIN nam.demog_eas
	ON ST_Intersects(nam.demog_eas.the_geom, nam.livezones.the_geom) AND NOT ST_Within(nam.demog_eas.the_geom, nam.livezones.the_geom)
	WHERE NOT ST_IsEmpty(ST_Buffer(ST_Intersection(nam.demog_eas.the_geom, nam.livezones.the_geom),0.0))
	AND nam.livezones.lz_code >= 56800;

COMMIT;


BEGIN;

SELECT 'Now add in all the LZ EA geometries, where the EAs are entirely contained within the LZs boundaries'::text;

INSERT INTO nam.lzs_eas(
	the_geom,
	ea_code,
/*	ea_gtype_c,
	ea_gtype,
	ea_type_c,
	ea_type,*/
	lz_code,
	area_ha)
	SELECT
		nam.demog_eas.the_geom,
		ea_code,
/*		ea_gtype_c,
		ea_gtype,
		ea_type_c,
		ea_type,*/
		nam.livezones.lz_code,
		0
	FROM nam.demog_eas
	INNER JOIN nam.livezones
	ON ST_Within(nam.demog_eas.the_geom, nam.livezones.the_geom);

COMMIT;


BEGIN;

SELECT 'Index the new table for fast querying'::text;

CREATE INDEX lzs_eas_gidx ON nam.lzs_eas USING GIST (the_geom);


SELECT 'Get the area of each geometry'::text;

UPDATE nam.lzs_eas SET area_ha = ST_AREA(the_geom) / 100000;


SELECT 'Use the new lzs_eas table to set the lz_code of the EAs'::text;

UPDATE
	nam.demog_eas
SET
	lz_code = (
		SELECT
			f.lz_code
		FROM
			(SELECT
				lz_code,
				ea_code
			FROM nam.lzs_eas
			WHERE
				area_ha IN (SELECT MAX(area_ha) FROM nam.lzs_eas WHERE ea_code = nam.lzs_eas.ea_code GROUP BY ea_code)
			) AS f
	WHERE nam.demog_eas.ea_code = f.ea_code
	)
;

/*
CREATE TABLE zaf.tbl_urban_codes(
	id SERIAL PRIMARY KEY,
	gtype_c INTEGER,
	type_c INTEGER,
	lz_code INTEGER);

INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (1,1,59881);
INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (1,2,59831);
INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (1,5,59903);
INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (1,6,59852);
INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (1,7,59806);
INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (1,8,59890);
INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (1,9,59802);
INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (1,10,59802);
INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (2,1,59880);
INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (2,2,59830);
INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (2,5,59904);
--INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (2,6,59850);
INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (2,7,59805);
INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (2,10,59801);
INSERT INTO zaf.tbl_urban_codes(gtype_c, type_c, lz_code) VALUES (3,8,59890);
*/

/*
SELECT 'Make sure that any urban EAs overide the previous analysis'::text;
UPDATE
	nam.demog_eas
SET
	lz_code = (
		SELECT
			lz_code
		FROM
			zaf.tbl_urban_codes
		WHERE
			gtype_c = nam.demog_eas.ea_gtype_c AND type_c = nam.demog_eas.ea_type_c)
WHERE
	nam.demog_eas.ea_code IN (
		SELECT ea_code
		FROM nam.demog_eas
		INNER JOIN zaf.tbl_urban_codes
		ON
			nam.demog_eas.ea_gtype_c = zaf.tbl_urban_codes.gtype_c
		AND
			nam.demog_eas.ea_type_c = zaf.tbl_urban_codes.type_c)
;
COMMIT;
*/
BEGIN;

SELECT 'Now get rid of the temporary lzs_eas table'::text;

DROP TABLE IF EXISTS nam.lzs_eas;



SELECT 'Enumeration Areas table output:'::text;

SELECT ea_code, lz_code FROM nam.demog_eas ORDER BY ea_code LIMIT 20;

COMMIT;
