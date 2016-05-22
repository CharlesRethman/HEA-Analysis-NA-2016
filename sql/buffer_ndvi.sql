DROP TABLE IF EXISTS nam.buffer_20160515;

CREATE TABLE nam.buffer_20160515 (
  gid SERIAL PRIMARY KEY,
  the_geom GEOMETRY(MULTIPOLYGON, 300000),
  ndvi INTEGER
  )
;

INSERT INTO nam.buffer_20160515 (
  the_geom,
  ndvi
  )
  SELECT
    ST_Multi((ST_Dump(ST_Union(ST_Buffer(g.the_geom, 3600)))).geom),
    SUM(g.ndvi) AS ndvi
  FROM (
    SELECT
      ST_Multi(f.the_geom) AS the_geom,
      f.ndvi
    FROM (
      SELECT
        (ST_Dump(ST_Union(the_geom))).geom AS the_geom,
        1 AS ndvi
      FROM
        nam.grn_20160515
        ) AS f
    WHERE
      ST_Area(f.the_geom) > 26400000
      ) AS g
;
