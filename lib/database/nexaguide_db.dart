import 'package:nexaguide_ipm/database/database_service.dart';
import 'package:sqflite/sqflite.dart';

import 'model/city.dart';
import 'model/poi.dart';

class NexaGuideDB {

  /// CITIES

  final citiesTableName = 'cities';

  Future<void> createCitiesTable(Database database) async {
    await database.execute("""
    CREATE TABLE IF NOT EXISTS $citiesTableName (
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "country" TEXT NOT NULL,
    "population" INTEGER,
    "lat" REAL NOT NULL,
    "lng" REAL NOT NULL,
    PRIMARY KEY ("id" AUTOINCREMENT)
    );""");
  }

  Future<void> initializeCities(List<City> cities) async {
    final database = await DatabaseService().database;
    print("Intializing all cities, may take a few seconds...");
    await database.transaction((txn) async {
      var b = txn.batch();
      for (var city in cities) {
        //print(city); // TODO: don't forget to delete prints
        b.rawInsert(
            '''INSERT INTO $citiesTableName (name, country, population, lat, lng) VALUES (?,?,?,?,?)''',
            [city.name, city.country, city.population, city.lat, city.lng]
        );
      }

      try{
        await b.commit(continueOnError: true);
        print("Cities table successfully initialized." );
      }catch(e){
        print("Error initializing cities ==> ${e.toString()}");
      }
    });

  }

  Future<int> createCity({required String name, required String country, int? population, required double lat, required double lng}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $citiesTableName (name, country, population, lat, lng) VALUES (?,?,?,?,?)''',
      [name, country, population, lat, lng]
    );
  }

  Future<List<City>> fetchAllCities() async {
    final database = await DatabaseService().database;
    final cities = await database.rawQuery(
      '''SELECT * FROM $citiesTableName ORDER BY id ASC'''
    );
    return cities.map( (city) => City.fromSqfliteDatabase(city)).toList();
  }

  Future<City> fetchCityById(int id) async {
    final database = await DatabaseService().database;
    final city = await database.rawQuery(
        '''SELECT * FROM $citiesTableName WHERE id=?''', [id]
    );
    return City.fromSqfliteDatabase(city.first);
  }

  Future<int> updateCity({required int id, String? name, String? country, int? population, double? lat, double? lng}) async {
    final database = await DatabaseService().database;
    return await database.update(
      citiesTableName,
      {
        if (name != null) 'name': name,
        if (country != null) 'country': country,
        if (population != null) 'population': population,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id]
    );
  }

  Future<void> deleteCity(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $citiesTableName WHERE id = ?''', [id]);
  }

  Future<void> deleteAllCities() async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $citiesTableName''');
  }

  Future<List<City>> searchCities(String search) async {
    final database = await DatabaseService().database;

    var result = await database.query(
      citiesTableName,
      where: 'name LIKE ?', // The WHERE clause
      whereArgs: ['%$search%'], // The argument for the WHERE clause
    );

    return result.map( (city) => City.fromSqfliteDatabase(city)).toList();
  }

  /// POIs

  final String poiTableName = "poi";
  final String poiTagsTableName = "poiTags";

  Future<void> createPOITable(Database database) async {
    await database.execute("""
    CREATE TABLE IF NOT EXISTS $poiTableName (
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "lat" REAL NOT NULL,
    "lng" REAL NOT NULL,
    "address" TEXT,
    "website" TEXT,
    "price" INTEGER,
    "cityID" INTEGER,
    PRIMARY KEY ("id" AUTOINCREMENT),
    FOREIGN KEY ("cityID") REFERENCES $citiesTableName ("id") ON UPDATE CASCADE ON DELETE CASCADE
    );""");
  }

  Future<int> createPOI({required String name, required double lat, required double lng, String? address, String? website, int? price, int? cityID}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
        '''INSERT INTO $poiTableName (name, lat, lng, address, website, price, cityID) VALUES (?,?,?,?,?,?,?)''',
        [name, lat, lng, address, website, price, cityID]
    );
  }

  Future<int> updatePOI({required int id, String? name, double? lat, double? lng, String? address, String? website, int? price, int? cityID}) async {
    final database = await DatabaseService().database;
    return await database.update(
        poiTableName,
        {
          if (name != null) 'name': name,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
          if (address != null) 'address': address,
          if (website != null) 'website': website,
          if (price != null) 'price': price,
          if (cityID != null) 'cityID': cityID,
        },
        where: 'id = ?',
        conflictAlgorithm: ConflictAlgorithm.rollback,
        whereArgs: [id]
    );
  }

  Future<void> deletePOI(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $poiTableName WHERE id = ?''', [id]);
  }

  Future<POI> fetchPOIById(int id) async {
    final database = await DatabaseService().database;
    final poi = await database.rawQuery(
        '''SELECT * FROM $poiTableName WHERE id=?''', [id]
    );
    final tags = await fetchPOITags(id);
    return POI.fromSqfliteDatabase(map: poi.first, tags: tags);
  }

  Future<List<POI>> fetchPOIByCity(int cityID) async {
    final database = await DatabaseService().database;
    final poi = await database.rawQuery(
        '''SELECT * FROM $poiTableName WHERE cityID=?''', [cityID]
    );

    List<POI> result = [];
    for (var p in poi) {
      POI poi = await buildPOIWithTags(p);
      result.add(poi);
    }
    return result;

    //return poi.map( (p) => POI.fromSqfliteDatabase(map: p)).toList();
  }

  Future<List<POI>> fetchPOIByCoordinates(double latMin, double latMax, double lngMin, double lngMax) async {
    final database = await DatabaseService().database;
    final poi = await database.rawQuery(
        '''SELECT * FROM $poiTableName 
        WHERE lat between ? and ?
        AND lng between ? and ? ''',
        [latMin, latMax, lngMin, lngMax]
    );

    List<POI> result = [];
    for (var p in poi) {
      POI poi = await buildPOIWithTags(p);
      result.add(poi);
    }
    return result;
  }

  Future<POI> buildPOIWithTags(Map<String, Object?> poi) async {
    int id = poi['id'] as int;
    List<String> tags = await fetchPOITags(id);
    return POI.fromSqfliteDatabase(map: poi, tags: tags);
  }

  // TODO: Search POI based on multiple filters

  Future<void> createPOITagsTable(Database database) async {
    await database.execute("""
    CREATE TABLE IF NOT EXISTS $poiTagsTableName (
    "id" INTEGER NOT NULL,
    "tag" TEXT NOT NULL,
    PRIMARY KEY ("id", "tag"),
    FOREIGN KEY ("id") REFERENCES $poiTableName ("id") ON UPDATE CASCADE ON DELETE CASCADE
    );""");
  }

  Future<int> insertPOITag(int id, String tag) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
        '''INSERT INTO $poiTagsTableName (id, tag) VALUES (?,?)''',
        [id, tag]
    );
  }

  Future<void> deletePOITag(int id, String tag) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $poiTagsTableName WHERE id = ? AND tag = ?''', [id, tag]);
  }

  Future<void> clearPOITags(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $poiTagsTableName WHERE id = ?''', [id]);
  }

  Future<void> deleteTag(String tag) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $poiTagsTableName WHERE tag = ?''', [tag]);
  }

  Future<List<String>> fetchPOITags(int id) async {
    final database = await DatabaseService().database;
    final res = await database.rawQuery(
        '''SELECT * FROM $poiTagsTableName WHERE id=?''', [id]
    );

    return res.map( (row) => row['tag'] as String).toList();
  }

}