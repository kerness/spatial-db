CREATE TABLE bak.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';


-- serial primary key
alter table bak.intersects
add column rid serial primary key;

-- spatial index
-- Computes the convex hull of a geometry. 
-- The convex hull is the smallest convex geometry that encloses all geometries in the input.
-- najmniejszy zbi?r wypuk?y zawieraj?cy ten podzbi?r

--  GIST - (Generalized Search Tree)-based index
create index idx_intersects_rast_gist on bak.intersects
using gist (st_convexhull(rast))


-- raster constraints 

SELECT AddRasterConstraints('bak'::name,
'intersects'::name,'rast'::name);


-- ###### ST_CLIP

CREATE TABLE bak.clip AS
SELECT ST_Clip(a.rast, b.geom, true), b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

-- ###### ST_UNION

CREATE TABLE bak.union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);



-- ############ To rasters


-- ###### ST_AsRaster

CREATE TABLE bak.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem
	LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';


-- ###### ST_UNION

DROP TABLE bak.porto_parishes; --> drop table porto_parishes first
CREATE TABLE bak.porto_parishes AS
	WITH r AS (
	SELECT rast FROM rasters.dem
	LIMIT 1
)
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';


-- ###### ST_TILE

DROP TABLE bak.porto_parishes; --> drop table porto_parishes first
CREATE TABLE bak.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem
	LIMIT 1 
)
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';




-- ############ To vectors

-- ###### ST_INTERSECTION

CREATE TABLE bak.intersection AS
SELECT
a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)
).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

-- ###### ST_DUMPASPOLYGONS

CREATE TABLE bak.dumppolygons AS
SELECT
a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);



-- ############ RASTER ANALYSIS

-- ###### ST_BAND

CREATE TABLE bak.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;


-- ###### ST_CLIP

CREATE TABLE bak.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);


-- ###### ST_SLOPE

CREATE TABLE bak.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM bak.paranhos_dem AS a;


-- ST_RECLASS

CREATE TABLE bak.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3',
'32BF',0)
FROM bak.paranhos_slope AS a;

-- ST_SUMMARYSTATS

SELECT st_summarystats(a.rast) AS stats
FROM bak.paranhos_dem AS a;

-- ST_SUMMARYSTATS + UNION	

SELECT st_summarystats(st_union(a.rast)) AS stats
FROM bak.paranhos_dem AS a;

-- ST_SUMMARYSTATS + OUTPUT CONTROL

WITH t AS (
	SELECT st_summarystats(st_union(a.rast)) AS stats
	FROM bak.paranhos_dem AS a
)
SELECT (stats).min, (stats).max, (stats).mean FROM t;

-- ST_SUMMARYSTATS + GROUP BY

WITH t AS (
	SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast,b.geom,true))) AS stats
	FROM rasters.dem AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
	GROUP BY b.parish
)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;


-- ST_VALUE


SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;


-- ############ TPI - TOPOGRAPHIC POSITION INDEX
-- bez indesku 57 sekund
-- z indeksem 57 sekund
-- z indeksem 57 dekund

DROP TABLE bak.tpi30;

create table bak.tpi30 as
select ST_TPI(a.rast,1) as rast
from rasters.dem a;


CREATE INDEX idx_tpi30_rast_gist ON bak.tpi30
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('bak'::name,
'tpi30'::name,'rast'::name);

-- to szalenie szybko (w porównaniu do drugiego rastra)
CREATE TABLE bak.tpi30porto AS
WITH porto AS (
	SELECT a.rast
	FROM rasters.dem AS a, vectors.porto_parishes AS b
	WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ILIKE 'porto' -- ILIKE - caseinsensitive
)
SELECT ST_TPI(porto.rast,1) AS rast FROM porto;


--










