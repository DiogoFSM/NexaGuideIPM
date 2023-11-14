import 'package:nexaguide_ipm/database/database_service.dart';
import 'package:sqflite/sqflite.dart';

import 'model/city.dart';

class NexaGuideDB {
  final citiesTableName = 'cities';

  Future<void> createTable(Database database) async {
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
    await database.transaction((txn) async {
      var b = txn.batch();
      cities.forEach((city) {
        print(city);
        b.rawInsert(
            '''INSERT INTO $citiesTableName (name, country, population, lat, lng) VALUES (?,?,?,?,?)''',
            [city.name, city.country, city.population, city.lat, city.lng]
        );
      });

      try{
        await b.commit(continueOnError: true);
        print("SUCESS ID : COMMIT " );
      }catch(e){
        print("faied to save to commit BRECASE ==> ${e.toString()}");
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
}