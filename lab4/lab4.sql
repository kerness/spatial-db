create schema geoobiekty;

create table geoobiekty.obiekty (
    id int primary key,
    geom geometry not null,
    name varchar not null
)


insert into geoobiekty.obiekty values
(1, st_geomFromText('compoundcurve( (0 1, 1 1), circularstring(1 1, 2 0, 3 1), circularstring(3 1, 4 2, 5 1), (5 1, 6 1) )'), 'obiekt1'),
(2, st_geomFromText('CURVEPOLYGON(compoundcurve( (10 6, 14 6), circularstring(14 6, 16 4, 14 2),
			 circularstring(14 2, 12 0, 10 2), (10 2, 10 6)), circularstring(11 2, 12 3, 13 2, 12 1, 11 2))'), 'obiekt2'),
(3, st_geomFromText('multicurve( (7 15, 10 17), (10 17, 12 13), (12 13, 7 15) )' ), 'obiekt3'),
(4, st_geomFromText('multicurve((20 20, 25 25), (25 25, 27 24), (27 24, 25 22), (25 22, 26 21), (26 21, 22 19), (22 19, 20.5 19.5))'), 'obiekt4'),
(5, st_geomFromText('multipoint(30 30 59, 38 32 234)'), 'obiekt5'),
(6, st_geomFromText('geometrycollection(point(4 2), linestring(1 1, 3 2))'), 'obiekt6');

select * from geoobiekty.obiekty;


-- 1:

select st_area(st_buffer(st_shortestline(
    (select o.geom from geoobiekty.obiekty o where o.name = 'obiekt3'),
    (select o.geom from geoobiekty.obiekty o where o.name = 'obiekt4')
), 5));

-- 2: convert 'obiekt4' to polygon - the line endings in 'obiekt4' must be closed!

-- convert to multicurve to linestring
-- Returns a (set of) LineString(s) formed by sewing together the constituent line work of a MULTILINESTRING. 
select st_geometrytype(st_linemerge(st_curvetoline(geom))) from geoobiekty.obiekty where name = 'obiekt4';
-- convert to closed linestring. st_addpoint - adds a point to a LineString so the line cn be closed by makepolygon
select st_addpoint(st_linemerge(st_curvetoline(geom)), st_startpoint(st_linemerge(st_curvetoline(geom)))) into tmpTable
from geoobiekty.obiekty where name = 'obiekt4';



-- convert to polygon
select st_makepolygon(st_addpoint(st_linemerge(st_curvetoline(geom)), st_startpoint(st_linemerge(st_curvetoline(geom))))) 
into tmpTable2
from geoobiekty.obiekty where name = 'obiekt4';


-- 3:
insert into geoobiekty.obiekty values
(7, st_collect(
    (select o.geom from geoobiekty.obiekty o where o.name = 'obiekt3'),
    (select o.geom from geoobiekty.obiekty o where o.name = 'obiekt4')
), 'obiekt7');

-- 4:
select st_area(st_buffer(o.geom, 5)) from geoobiekty.obiekty o
where not st_hasarc(o.geom);




