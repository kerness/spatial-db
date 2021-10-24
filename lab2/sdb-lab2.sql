------ #4
-- Zlicz budynki położone w odległości mniejszej niż 1000 od głównych rzek i zapisz do nowej tabeli
SELECT buildings.geom as building
INTO qgissampledata.tmp2
FROM qgissampledata.popp as buildings
JOIN qgissampledata.majrivers as rivers
ON st_within(buildings.geom, ST_Buffer(rivers.geom, 1000))
WHERE buildings.f_codedesc = 'Building';

SELECT count(*)
FROM  qgissampledata.tmp2;

------ #5
-- Z airports nazwy lotnisk, geometria, elev do tabeli aiportsNew
SELECT name, elev,geom
INTO qgissampledata.airportsNew
FROM qgissampledata.airports;
-- lotnisko najbardziej najbardziej na wschód
SELECT name, st_x(geom) as e
FROM qgissampledata.airportsNew
ORDER BY e DESC LIMIT 1;
-- lotnisko najbardziej najbardziej na zachód
SELECT name, st_x(geom) as w
FROM qgissampledata.airportsNew
ORDER BY w LIMIT 1;
-- do airportsNew dodaj lotnisko położone w punkcie środkowym drogi między lotniskami z powyższego zapytania
INSERT INTO qgissampledata.airportsNew VALUES (
    'MOUNT EVEREST INTERNATIONAL AIRPORT',
    8849,
    (SELECT st_centroid (
    ST_MakeLine (
        (SELECT geom FROM qgissampledata.airportsNew WHERE name = 'ANNETTE ISLAND'),
        (SELECT geom FROM qgissampledata.airportsNew WHERE name = 'ATKA')
    )))
                                              );
------ #6
-- Pole powierzchni obszaru oddalonego o mniej niż 1000 od najkrótszej lini łączącej dane jezioro z danym lotniskiem
SELECT ST_Area(ST_Buffer(ST_ShortestLine(lakes.geom, airports.geom), 1000))
FROM qgissampledata.lakes, qgissampledata.airports
WHERE lakes.names = 'Iliamna Lake' AND airports.name = 'AMBLER';

------ #7
-- Sumaryczne pole powierzchni poligonów reprezentujących typy drzew na obszarze tundry i bagien
SELECT SUM(ST_Area(te.geom)), te.vegdesc
FROM qgissampledata.trees te, qgissampledata.swamp s, qgissampledata.tundra tu
WHERE ST_Contains(te.geom, s.geom) OR ST_Contains(te.geom, tu.geom)
GROUP BY te.vegdesc;
