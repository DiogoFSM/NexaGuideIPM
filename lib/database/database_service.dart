import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:nexaguide_ipm/database/initialize_poi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'model/city.dart';
import 'nexaguide_db.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }

  Future<String> get fullPath async {
    const name = 'nexaguide.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<Database> _initialize() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: create,
      singleInstance: true,
    );
    return database;
  }

  Future<void> _loadCitiesFromCSV() async {
    final rawData = await rootBundle.loadString('assets/worldcities.csv');
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
    List<City> citiesToInsert = [];
    listData.removeAt(0);
    for (var city in listData) {
      //print("NAME: ${city[0]}, LAT: ${city[2]}, LNG: ${city[3]}, POP: ${city[9]}");
      var name = city[0];
      var lat = city[2] != "" ? double.parse(city[2]) : 0.0;
      var lng = city[3] != "" ? double.parse(city[3]) : 0.0;
      var country = city[4];
      var population = city[9] != "" ? int.parse(city[9]) : -1;

      //print("$name $lat $lng $country $population");
      citiesToInsert.add(City(id: -1, name: name, lat: lat, lng: lng, country: country, population: population));
    }
    NexaGuideDB().initializeCities(citiesToInsert);
  }

  Future<void> createDB(Database database) async {
    await NexaGuideDB().createCitiesTable(database);
    await NexaGuideDB().createPOITable(database);
    await NexaGuideDB().createPOITagsTable(database);
    await NexaGuideDB().createPOIPhotosTable(database);
    await NexaGuideDB().createEventsTable(database);
    await NexaGuideDB().createEventsTagsTable(database);
    await NexaGuideDB().createReviewsTable(database);
    await NexaGuideDB().createCollectionsTable(database);
    await NexaGuideDB().createCollectionEventsTable(database);
    await NexaGuideDB().createCollectionPOITable(database);
    await _loadCitiesFromCSV();

    /*
    print("Initializing POI and events...");
    await InitializePOIandEvents.initPOI();
    await InitializePOIandEvents.initEvents();
    print("POI and events successfully initialized.");

     */
  }

  Future<void> create(Database database, int version) async => await createDB(database);

  Future<void> deleteDB() async {
    print("Deleting current database, please wait");
    String path = await fullPath;
    deleteDatabase(path);
    print("Deleted database");
    //print("Re-initializing database, can take a few seconds.");
    //await _initialize();
    //print("Database initialized");
  }
}