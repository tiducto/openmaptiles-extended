-- Store test results

DROP TABLE IF EXISTS omt_test_failures;
CREATE TABLE omt_test_failures(
  test_id integer,
  test_type varchar(6),
  error_message text
);

-- Checks to ensure that test data was imported correctly
DO $$

DECLARE
  cnt integer;

BEGIN

  -- Test 100
  SELECT COUNT(*) INTO cnt FROM osm_park_polygon;
  IF cnt <> 3 THEN
    INSERT INTO omt_test_failures VALUES(100, 'import', 'osm_park_polygon expected 3, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_park_polygon_gen_z5;
  IF cnt <> 3 THEN
    INSERT INTO omt_test_failures VALUES(100, 'import', 'osm_park_polygon_gen_z5 expected 3, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_park_polygon_gen_z5 WHERE leisure='nature_reserve';
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(100, 'import', 'osm_park_polygon_gen_z5 nature_reserve expected 1, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_park_polygon_gen_z5 WHERE boundary='protected_area';
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(100, 'import', 'osm_park_polygon_gen_z5 protected_area expected 1, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_park_polygon_gen_z5 WHERE boundary='national_park';
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(100, 'import', 'osm_park_polygon_gen_z5 national_park expected 1, got ' || cnt);
  END IF;

  -- Test 200
  SELECT COUNT(*) INTO cnt FROM osm_aerodrome_label_point;
  IF cnt <> 3 THEN
    INSERT INTO omt_test_failures VALUES(200, 'import', 'osm_aerodrome_label expected 3, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_aerodrome_label_point WHERE ele='123';
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(200, 'import', 'osm_aerodrome_label ele=123 expected 1, got ' || cnt);
  END IF;

  -- Test 300
  SELECT COUNT(*) INTO cnt FROM osm_landcover_polygon WHERE mapping_key='natural' AND subclass='wood';
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(300, 'import', 'osm_landcover_polygon natural=wood expected 1, got ' || cnt);
  END IF;

  -- Test 400
  SELECT COUNT(DISTINCT relation_id) INTO cnt FROM osm_border_linestring WHERE admin_level=8;
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(400, 'import', 'osm_border_linestring city count expected 1, got ' || cnt);
  END IF;

  SELECT COUNT(DISTINCT relation_id) INTO cnt FROM osm_border_linestring WHERE admin_level=2;
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(400, 'import', 'osm_border_linestring country count expected 1, got ' || cnt);
  END IF;

  -- Test 500

  -- Verify that road classifications show up at the right zoom level
  SELECT COUNT(*) INTO cnt FROM osm_transportation_merge_linestring_gen_z4 WHERE osm_national_network(network);
  IF cnt < 1 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_linestring z4 national network count expected >=1, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_transportation_merge_linestring_gen_z4 WHERE NOT osm_national_network(network);
  IF cnt <> 0 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_linestring z4 not national network count expected 0, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_transportation_merge_linestring_gen_z5 WHERE highway='motorway';
  IF cnt < 1 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_linestring z5 motorway count expected >=1, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_transportation_merge_linestring_gen_z5 WHERE highway='trunk' AND osm_national_network(network);
  IF cnt < 1 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_linestring z5 trunk and national network count expected >=1, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_transportation_merge_linestring_gen_z6 WHERE highway='primary';
  IF cnt <> 0 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_linestring z6 primary count expected 0, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_transportation_merge_linestring_gen_z7 WHERE highway='primary';
  IF cnt < 1 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_linestring z7 primary count expected >=1, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_transportation_merge_linestring_gen_z8 WHERE highway='secondary';
  IF cnt <> 0 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_linestring z8 secondary count expected 0, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_transportation_merge_linestring_gen_z9 WHERE highway='secondary';
  IF cnt < 1 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_linestring z9 secondary count expected >=1, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_transportation_merge_linestring_gen_z10 WHERE highway='tertiary';
  IF cnt <> 0 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_linestring z10 tertiary count expected 0, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_transportation_merge_linestring_gen_z11 WHERE highway='tertiary';
  IF cnt < 1 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_linestring z11 tertiary count expected >=1, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_transportation_merge_linestring_gen_z11 WHERE highway IN ('service', 'track');
  IF cnt <> 0 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_linestring z11 minor road count expected 0, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_transportation_merge_linestring_gen_z9
    WHERE is_bridge = TRUE
      AND toll = TRUE
      AND layer = 1
      AND bicycle = 'no'
      AND foot = 'no'
      AND horse = 'no';
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_linestring z9 import tags expected 1, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_transportation_merge_linestring_gen_z9
    WHERE highway = 'trunk'
      AND expressway = TRUE;
  IF cnt < 1 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_linestring z9 import expressway expected >=1, got ' || cnt);
  END IF;

  -- Same-named road split into 3 parts, because the middle segment is tagged toll=yes
  SELECT COUNT(*) INTO cnt FROM osm_transportation_name_linestring WHERE tags->'name' = 'OpenMapTiles Secondary 3';
  IF cnt <> 2 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_linestring split road count expected 2, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_transportation_name_linestring
    WHERE tags->'name' = 'OpenMapTiles Path z13'
      AND route_rank = 2;
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_name_linestring z13 route_rank expected 1, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_transportation_name_linestring
    WHERE tags->'name' = 'OpenMapTiles Track z12'
      AND route_rank = 1;
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'osm_transportation_name_linestring z12 route_rank expected 1, got ' || cnt);
  END IF;

  -- Duplicate route concurrencies collapsed
  SELECT COUNT(*) INTO cnt FROM transportation_route_member_coalesced
    WHERE network='US:I' AND ref='95';
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(500, 'import', 'transportation_route_member_coalesced 1 route membership expected, got ' || cnt);
  END IF;

  -- Test 560

  -- Paths closed to pedestrians get a point at each end with the direction into the path
  SELECT COUNT(*) INTO cnt FROM layer_transportation(ST_Transform(ST_MakeEnvelope(17.199, 52.209, 17.202, 52.216, 4326), 3857), 14)
    WHERE osm_id = 5600 AND class = 'path' AND subclass = 'steps' AND access = 'no' AND ST_GeometryType(geometry) = 'ST_Point';
  IF cnt <> 2 THEN
    INSERT INTO omt_test_failures VALUES(560, 'import', 'layer_transportation z14 access=no steps end points expected 2, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM layer_transportation(ST_Transform(ST_MakeEnvelope(17.199, 52.209, 17.202, 52.216, 4326), 3857), 14)
    WHERE osm_id = 5600 AND ST_GeometryType(geometry) = 'ST_Point' AND bearing IN (90, 270);
  IF cnt <> 2 THEN
    INSERT INTO omt_test_failures VALUES(560, 'import', 'layer_transportation z14 west-east steps end points with bearing 90 or 270 expected 2, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM layer_transportation(ST_Transform(ST_MakeEnvelope(17.199, 52.209, 17.202, 52.216, 4326), 3857), 14)
    WHERE osm_id = 5601 AND ST_GeometryType(geometry) = 'ST_Point';
  IF cnt <> 0 THEN
    INSERT INTO omt_test_failures VALUES(560, 'import', 'layer_transportation z14 access=private foot=yes end points expected 0, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM layer_transportation(ST_Transform(ST_MakeEnvelope(17.199, 52.209, 17.202, 52.216, 4326), 3857), 14)
    WHERE osm_id IN (5602, 5603) AND ST_GeometryType(geometry) = 'ST_Point';
  IF cnt <> 2 THEN
    INSERT INTO omt_test_failures VALUES(560, 'import', 'layer_transportation z14 end points of two joined closed paths expected 2 (shared end left out), got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM layer_transportation(ST_Transform(ST_MakeEnvelope(17.199, 52.209, 17.202, 52.216, 4326), 3857), 14)
    WHERE osm_id = 5602 AND ST_GeometryType(geometry) = 'ST_Point' AND bearing = 90;
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(560, 'import', 'layer_transportation z14 foot=private footway west end point with bearing 90 expected 1, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM layer_transportation(ST_Transform(ST_MakeEnvelope(17.199, 52.209, 17.202, 52.216, 4326), 3857), 14)
    WHERE osm_id IN (5604, 5605) AND ST_GeometryType(geometry) = 'ST_Point';
  IF cnt <> 0 THEN
    INSERT INTO omt_test_failures VALUES(560, 'import', 'layer_transportation z14 end points of a closed ring or a road expected 0, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM layer_transportation(ST_Transform(ST_MakeEnvelope(17.199, 52.209, 17.202, 52.216, 4326), 3857), 13)
    WHERE ST_GeometryType(geometry) = 'ST_Point';
  IF cnt <> 0 THEN
    INSERT INTO omt_test_failures VALUES(560, 'import', 'layer_transportation z13 path end points expected 0, got ' || cnt);
  END IF;

  -- Test 600

  -- verify that atms are imported with correct name which can come from tags like operator or network
  SELECT COUNT(*) INTO cnt FROM osm_poi_point
    WHERE subclass = 'atm'
      AND tags->'name' = 'OpenMapTiles ATM';
  IF cnt <> 3 THEN
    INSERT INTO omt_test_failures VALUES(600, 'import', 'osm_poi_point atm with name "OpenMapTiles ATM" expected 3, got ' || cnt);
  END IF;

  -- verify that parcel lockers are imported with correct name which can come from tags like brand or operator and can contain ref
  SELECT COUNT(*) INTO cnt FROM osm_poi_point
    WHERE subclass = 'parcel_locker'
      AND tags->'name' like 'OpenMapTiles Parcel Locker%';
  IF cnt <> 3 THEN
    INSERT INTO omt_test_failures VALUES(600, 'import', 'osm_poi_point parcel_locker with name like "OpenMapTiles Parcel Locker%" expected 3, got ' || cnt);
  END IF;
  SELECT COUNT(*) INTO cnt FROM osm_poi_point
    WHERE subclass = 'parcel_locker'
      AND tags->'name' like 'OpenMapTiles Parcel Locker PL00%';
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(600, 'import', 'osm_poi_point parcel_locker with name like "OpenMapTiles Parcel Locker PL00%" expected 1, got ' || cnt);
  END IF;
  
  -- verify that charging stations are imported with correct name which can come from tags like brand or operator and can contain ref
  SELECT COUNT(*) INTO cnt FROM osm_poi_point
    WHERE subclass = 'charging_station'
      AND tags->'name' = 'OpenMapTiles Charging Station';
  IF cnt <> 2 THEN
    INSERT INTO omt_test_failures VALUES(600, 'import', 'osm_poi_point charging_station with name "OpenMapTiles Charging Station" expected 2, got ' || cnt);
  END IF;
  SELECT COUNT(*) INTO cnt FROM osm_poi_polygon
    WHERE subclass = 'charging_station'
      AND tags->'name' = 'OpenMapTiles Charging Station Brand';
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(600, 'import', 'osm_poi_polygon charging_station with name "OpenMapTiles Charging Station Brand" expected 1, got ' || cnt);
  END IF;

  -- verify that farm shops are imported and classified as shops
  SELECT COUNT(*) INTO cnt FROM osm_poi_point
    WHERE subclass = 'farm'
      AND mapping_key = 'shop'
      AND tags->'name' = 'OpenMapTiles Farm Shop';
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(600, 'import', 'osm_poi_point farm shop expected 1, got ' || cnt);
  END IF;
  IF poi_class('farm', 'shop') <> 'shop' THEN
    INSERT INTO omt_test_failures VALUES(600, 'import', 'poi_class expected shop for shop=farm');
  END IF;

END;

$$
LANGUAGE plpgsql;

DO $$

DECLARE
  cnt integer;
BEGIN
  SELECT COUNT(*) INTO cnt FROM omt_test_failures;
  IF cnt > 0 THEN
    RAISE '% unit test(s) failed on imports.  Details can be found in table omt_test_failures.', cnt USING ERRCODE = '0Z000';
  END IF;
END;

$$;
