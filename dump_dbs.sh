#! /bin/bash

pg_dump -COF c -n nam -T 'nam.admin*' -T zaf.grid -T nam.buffer_20160515 -T nam.demog_eas -T nam.eas_outcome_2016  -T nam.grn_20160515 -T nam.livezones -T nam.ndvi_grn_band -T nam.tbl_outcomes -T nam.tbl_pop_proj t_merc | split -b 49m - db/nam_dump_
