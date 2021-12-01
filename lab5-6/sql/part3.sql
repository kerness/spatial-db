-- Export

SELECT ST_AsTiff(ST_Union(rast))
FROM bak.porto_ndvi;


SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
FROM bak.porto_ndvi;

-- The Geospatial Data Abstraction Library is a computer software library for reading and writing raster and vector geospatial data formats

SELECT ST_GDALDrivers();

-- save locally

CREATE TABLE tmp_out AS
	SELECT lo_from_bytea(0,
	ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM bak.porto_ndvi;
----------------------------------------------
SELECT lo_export(loid, '/geodata/rasters/output/myraster.tiff') --> Save the file in a place where the user postgres have access. In windows a flash drive usualy works fine.
FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
FROM tmp_out; --> Delete the large object.


gdal_translate -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 PG:"host=localhost port=5432 dbname=rasterdb user=geo password=geo schema=bak table=porto_ndvi mode=2" porto_ndvi.tiff
