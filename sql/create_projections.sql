CREATE TABLE nam.tbl_pop_proj (
  region_cod INTEGER PRIMARY KEY,
  pop_size INTEGER,
  pop_2016 INTEGER
  )
;


INSERT INTO nam.tbl_pop_proj (
  region_cod,
  pop_size,
  pop_2016
  )
VALUES
  (2, 145812, 182402),
  (3, 76908, 87186),
  (4, 74429, 85759),
  (5, 219413, 237779),
  (6, 332516, 415780),
  (7, 86015, 97665),
  (8, 242451, 255510),
  (9, 69748, 74629),
  (10, 240896, 249885),
  (11, 168418, 189237),
  (12, 179081, 195165),
  (13, 132646, 154342),
  (1, 88945, 98849)
;

SELECT * FROM nam.tbl_pop_proj;
