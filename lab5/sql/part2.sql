-- NDVI

CREATE TABLE bak.porto_ndvi AS
WITH r AS (
	SELECT a.rid, ST_Clip(a.rast, b.geom, true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ILIKE 'porto' AND ST_Intersects(b.geom, a.rast)
)
SELECT 
	r.rid, ST_MapAlgebra(
		r.rast, 1,
		r.rast, 4,
		'([rast2.val]) - ([rast1.val]) / ([rast2.val] + [rast1.val])::float', '32BF' 
	) AS rast 
FROM r;

-- index

CREATE INDEX idx_porto_ndvi_rast_gist ON bak.porto_ndvi
USING gist (ST_ConvexHull(rast));

-- constraint

SELECT AddRasterConstraints('bak'::name,'porto_ndvi'::name,'rast'::name);



-- function (variadic - undefined number of arguments)

CREATE OR REPLACE FUNCTION bak.ndvi(
	value double precision [] [] [],
	pos integer [][],
	VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
	--RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes
	RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value [1][1][1]); --> NDVI calculation!
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;


-- function call

CREATE TABLE bak.porto_ndvi2 AS
WITH r AS (
	SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
	r.rid,ST_MapAlgebra(
		  r.rast, ARRAY[1,4]
		, 'bak.ndvi(double precision[]
		, integer[],text[])'::regprocedure --> This is the function!
		, '32BF'::text
) AS rast
FROM r;


-- index
CREATE INDEX idx_porto_ndvi2_rast_gist ON bak.porto_ndvi2
USING gist (ST_ConvexHull(rast));

-- constraints
SELECT AddRasterConstraints('bak'::name,
'porto_ndvi2'::name,'rast'::name);


