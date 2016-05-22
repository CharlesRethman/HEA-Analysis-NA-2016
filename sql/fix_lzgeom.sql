DROP TABLE IF EXISTS nam.error_points;

CREATE TABLE nam.error_points (
  gid SERIAL PRIMARY KEY,
  the_geom GEOMETRY(POINT, 300000)
  )
;

INSERT INTO nam.error_points (
  the_geom
  )
  VALUES
  (ST_SetSRID(ST_Point(578956.78080098669, 7014040.4714916442), 300000))
--  (ST_SetSRID(ST_Point(665599.43959148764, 6816152.8685039151), 300000))
--  (ST_SetSRID(ST_Point(660302.96635041398, 6822368.6339576859), 300000))
/*  (ST_SetSRID(ST_Point(492667.03601320769, 7631079.4421758065), 300000)),
  (ST_SetSRID(ST_Point(896152.34310817614, 6938659.6973492568), 300000)),
  (ST_SetSRID(ST_Point(749292.34499644861, 8075809.2565551447), 300000)),
  (ST_SetSRID(ST_Point(484226.39471609925, 8076223.8826426538), 300000)),
  (ST_SetSRID(ST_Point(736542.8073140342, 7220592.2077505738), 300000)),
  (ST_SetSRID(ST_Point(342379.61083727831, 7457065.9337610602), 300000))*/
;
