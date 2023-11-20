import 'package:nexaguide_ipm/database/database_service.dart';
import 'package:sqflite/sqflite.dart';

import 'model/city.dart';
import 'model/event.dart';
import 'model/poi.dart';
import 'model/collection.dart';
import 'model/review.dart';

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

      try {
        await b.commit(continueOnError: true, noResult: true);
        print("Cities table successfully initialized.");
      } catch (e) {
        print("Error initializing cities ==> ${e.toString()}");
      }
    });
  }

  Future<int> createCity(
      {required String name, required String country, int? population, required double lat, required double lng}) async {
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
    return cities.map((city) => City.fromSqfliteDatabase(city)).toList();
  }

  Future<City> fetchCityById(int id) async {
    final database = await DatabaseService().database;
    final city = await database.rawQuery(
        '''SELECT * FROM $citiesTableName WHERE id=?''', [id]
    );
    return City.fromSqfliteDatabase(city.first);
  }

  Future<int> updateCity(
      {required int id, String? name, String? country, int? population, double? lat, double? lng}) async {
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
    await database.rawDelete(
        '''DELETE FROM $citiesTableName WHERE id = ?''', [id]);
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

    return result.map((city) => City.fromSqfliteDatabase(city)).toList();
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
    "description" TEXT,
    PRIMARY KEY ("id" AUTOINCREMENT),
    FOREIGN KEY ("cityID") REFERENCES $citiesTableName ("id") ON UPDATE CASCADE ON DELETE CASCADE
    );""");
  }

  Future<int> createPOI(
      {required String name, required double lat, required double lng, String? address, String? website, int? price, int? cityID, String? description}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
        '''INSERT INTO $poiTableName (name, lat, lng, address, website, price, cityID, description) VALUES (?,?,?,?,?,?,?,?)''',
        [name, lat, lng, address, website, price, cityID, description]
    );
  }

  Future<int> createPOIWithTags(
      {required String name, required double lat, required double lng, String? address, String? website, int? price, int? cityID, String? description, required List<
          String> tags}) async {
    final database = await DatabaseService().database;
    int id = -1;
    await database.transaction((txn) async {
      var b = txn.batch();
      id = await txn.rawInsert(
          '''INSERT INTO $poiTableName (name, lat, lng, address, website, price, cityID, description) VALUES (?,?,?,?,?,?,?,?)''',
          [name, lat, lng, address, website, price, cityID, description]
      );

      if (id >= 0) {
        for (var t in tags) {
          b.rawInsert(
              '''INSERT INTO $poiTagsTableName (id, tag) VALUES (?,?)''',
              [id, t]);
        }
      }
      else {
        print("Insertion failed!");
      }
      try {
        await b.commit(continueOnError: true, noResult: true);
        print("POI with tags successfully created.");
      } catch (e) {
        print("Error commiting batch ==> ${e.toString()}");
      }
    });

    return id;
  }

  Future<int> updatePOI(
      {required int id, String? name, double? lat, double? lng, String? address, String? website, int? price, int? cityID, String? description}) async {
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
          if (description != null) 'description': description
        },
        where: 'id = ?',
        conflictAlgorithm: ConflictAlgorithm.rollback,
        whereArgs: [id]
    );
  }

  Future<void> deletePOI(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete(
        '''DELETE FROM $poiTableName WHERE id = ?''', [id]);
  }

  Future<POI> fetchPOIById(int id) async {
    final database = await DatabaseService().database;
    final poi = await database.rawQuery(
        '''SELECT $poiTableName.*, $citiesTableName.name as cityName FROM $poiTableName 
        INNER JOIN $citiesTableName ON cityID = $citiesTableName.id
        WHERE $poiTableName.id=?''',
        [id]
    );
    final tags = await fetchPOITags(id);
    List<num> ratingAndCount = await fetchAverageRatingAndCount(id);
    double avgRating = ratingAndCount[0] as double;
    int count = ratingAndCount[1] as int;
    return POI.fromSqfliteDatabase(map: poi.first, tags: tags, rating: avgRating, revCount: count);
  }

  Future<List<POI>> fetchPOIByCity(int cityID) async {
    final database = await DatabaseService().database;
    final poi = await database.rawQuery(
        '''SELECT $poiTableName.*, $citiesTableName.name as cityName FROM $poiTableName 
        INNER JOIN $citiesTableName ON cityID = $citiesTableName.id
        WHERE $citiesTableName.cityID=?''',
        [cityID]
    );

    List<POI> result = [];
    for (var p in poi) {
      POI poi = await buildPOIWithTags(p);
      result.add(poi);
    }
    return result;

    //return poi.map( (p) => POI.fromSqfliteDatabase(map: p)).toList();
  }

  Future<List<POI>> fetchPOIByCoordinates(double latMin, double latMax,
      double lngMin, double lngMax) async {
    final database = await DatabaseService().database;
    final poi = await database.rawQuery(
        '''SELECT $poiTableName.*, $citiesTableName.name as cityName FROM $poiTableName 
        INNER JOIN $citiesTableName ON cityID = $citiesTableName.id
        WHERE $poiTableName.lat between ? and ?
        AND $poiTableName.lng between ? and ? ''',
        [latMin, latMax, lngMin, lngMax]
    );
    List<POI> result = [];
    for (var p in poi) {
      POI poi = await buildPOIWithTags(p);
      result.add(poi);
    }
    return result;
  }

  Future<List<POI>> searchPOI({
    String? nameQuery, int? cityID, int? minPrice, int? maxPrice, int? minRating, int? maxRating,
    double? latMin, double? latMax, double? lngMin, double? lngMax, List<String>? tags,
  }) async {
    final database = await DatabaseService().database;

    String query =  '''SELECT $poiTableName.*, $citiesTableName.name as cityName FROM $poiTableName 
        INNER JOIN $citiesTableName ON cityID = $citiesTableName.id
        WHERE $poiTableName.id NOT NULL ''';

    if (cityID != null) query += "AND $citiesTableName.id = $cityID ";
    if (minPrice != null) query += "AND $poiTableName.price >= $minPrice ";
    if (maxPrice != null) query += "AND ($poiTableName.price <= $maxPrice OR $poiTableName.price IS NULL) ";
    if (latMin != null) query += "AND $poiTableName.lat >= $latMin ";
    if (latMax != null) query += "AND $poiTableName.lat <= $latMax ";
    if (lngMin != null) query += "AND $poiTableName.lng >= $lngMin ";
    if (lngMax != null) query += "AND $poiTableName.lng <= $lngMax ";
    if (nameQuery != null) query += "AND $poiTableName.name LIKE '%$nameQuery%' ";
    //print (query);

    final poi = await database.rawQuery(query);
    List<POI> result = [];
    for (var p in poi) {
      int id = p['id'] as int;
      List<String> poiTags = await fetchPOITags(id);
      List<num> ratingAndCount = await fetchAverageRatingAndCount(id);
      double avgRating = ratingAndCount[0] as double;
      int count = ratingAndCount[1] as int;

      bool containsAllTags = tags != null && tags.every((tag) => poiTags.contains(tag));
      bool tagsFilter = tags == null || tags.isEmpty || containsAllTags;

      bool ratingBiggerThanMin = minRating == null || avgRating >= minRating;
      bool ratingLowerThanMax = maxRating == null || avgRating  <= maxRating;
      bool ratingFilter = ratingBiggerThanMin && ratingLowerThanMax;

      if (tagsFilter && ratingFilter) {
          var poi = POI.fromSqfliteDatabase(map: p, tags: poiTags, rating: avgRating, revCount: count);
          result.add(poi);
      }
    }
    return result;
  }

  Future<POI> buildPOIWithTags(Map<String, Object?> poi) async {
    int id = poi['id'] as int;
    List<String> tags = await fetchPOITags(id);
    List<num> ratingAndCount = await fetchAverageRatingAndCount(id);
    double avgRating = ratingAndCount[0] as double;
    int count = ratingAndCount[1] as int;
    return POI.fromSqfliteDatabase(map: poi, tags: tags, rating: avgRating, revCount: count);
  }

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
    await database.rawDelete(
        '''DELETE FROM $poiTagsTableName WHERE id = ? AND tag = ?''',
        [id, tag]);
  }

  Future<void> clearPOITags(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete(
        '''DELETE FROM $poiTagsTableName WHERE id = ?''', [id]);
  }

  Future<void> deleteTagAllPOI(String tag) async {
    final database = await DatabaseService().database;
    await database.rawDelete(
        '''DELETE FROM $poiTagsTableName WHERE tag = ?''', [tag]);
  }

  Future<List<String>> fetchPOITags(int id) async {
    final database = await DatabaseService().database;
    final res = await database.rawQuery(
        '''SELECT * FROM $poiTagsTableName WHERE id=?''', [id]
    );

    return res.map((row) => row['tag'] as String).toList();
  }

  /// EVENTS

  final String eventsTableName = "events";
  final String eventsTagsTableName = "eventsTags";

  Future<void> createEventsTable(Database database) async {
    await database.execute("""
    CREATE TABLE IF NOT EXISTS $eventsTableName (
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "dateStart" INTEGER NOT NULL,
    "dateEnd" INTEGER NOT NULL,
    "location" TEXT NOT NULL,
    "startTime" TEXT NOT NULL,
    "endTime" TEXT NOT NULL,
    "website" TEXT,
    "price" INTEGER,
    "poiID" INTEGER NOT NULL,
    "description" TEXT,
    PRIMARY KEY ("id" AUTOINCREMENT),
    FOREIGN KEY ("poiID") REFERENCES $poiTableName ("id") ON UPDATE CASCADE ON DELETE CASCADE
    );""");
  }

  // TODO: Search events based on multiple filters

  Future<int> createEvent(
      {required String name, required int poiID, required int dateStart, required int dateEnd, required String location, required String endTime, required startTime, String? website, int? price, String? description}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
        '''INSERT INTO $eventsTableName (name, dateStart, dateEnd, location, startTime, endTime, website, price, poiID, description) VALUES (?,?,?,?,?,?,?,?,?,?)''',
        [
          name,
          dateStart,
          dateEnd,
          location,
          startTime,
          endTime,
          website,
          price,
          poiID,
          description
        ]
    );
  }

  Future<int> createEventWithTags(
      {required String name, required int poiID, required int dateStart, required int dateEnd, required String location, required String endTime, required startTime, String? website, int? price, String? description, required List<
          String> tags}) async {
    final database = await DatabaseService().database;
    int id = -1;
    await database.transaction((txn) async {
      var b = txn.batch();
      id = await txn.rawInsert(
          '''INSERT INTO $eventsTableName (name, dateStart, dateEnd, location, startTime, endTime, website, price, poiID, description) VALUES (?,?,?,?,?,?,?,?,?,?)''',
          [
            name,
            dateStart,
            dateEnd,
            location,
            startTime,
            endTime,
            website,
            price,
            poiID,
            description
          ]
      );

      if (id >= 0) {
        for (var t in tags) {
          b.rawInsert(
              '''INSERT INTO $eventsTagsTableName (id, tag) VALUES (?,?)''',
              [id, t]);
        }
      }
      else {
        print("Insertion failed!");
      }
      try {
        await b.commit(continueOnError: true, noResult: true);
        print("Event with tags successfully created.");
      } catch (e) {
        print("Error commiting batch ==> ${e.toString()}");
      }
    });

    return id;
  }

  Future<int> updateEvent(
      {required int id, String? name, int? dateStart, int? dateEnd, String? website, int? price, int? poiID, String? description}) async {
    final database = await DatabaseService().database;
    return await database.update(
        poiTableName,
        {
          if (name != null) 'name': name,
          if (dateStart != null) 'dateStart': dateStart,
          if (dateEnd != null) 'dateEnd': dateEnd,
          if (website != null) 'website': website,
          if (price != null) 'price': price,
          if (poiID != null) 'poiID': poiID,
          if (description != null) 'description': description
        },
        where: 'id = ?',
        conflictAlgorithm: ConflictAlgorithm.rollback,
        whereArgs: [id]
    );
  }

  Future<void> deleteEvent(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete(
        '''DELETE FROM $eventsTableName WHERE id = ?''', [id]);
  }

  Future<Event> fetchEventById(int id) async {
    final database = await DatabaseService().database;
    final events = await database.rawQuery(
        '''SELECT * FROM $eventsTableName WHERE id=?''', [id]
    );
    return buildEventWithTags(events.first);
  }

  Future<List<Event>> fetchEventsByIds(List<int> ids) async {
    List<Event> events = [];

    for (var id in ids) {
      final event = await fetchEventById(id);
      events.add(event);
    }

    return events;
  }

  Future<List<POI>> fetchPoisByIds(List<int> ids) async {
    List<POI> pois = [];

    for (var id in ids) {
      final poi = await fetchPOIById(id);
      pois.add(poi);
    }

    return pois;
  }
  Future<List<Event>> fetchEventsByPOI(int poiID) async {
    final database = await DatabaseService().database;
    final events = await database.rawQuery(
        '''SELECT * FROM $eventsTableName WHERE poiID=?''', [poiID]
    );

    List<Event> result = [];
    for (var e in events) {
      Event ev = await buildEventWithTags(e);
      result.add(ev);
    }
    return result;
  }

  Future<List<Event>> fetchAllEvents() async {
    final database = await DatabaseService().database;
    final events = await database.rawQuery(
        'SELECT * FROM $eventsTableName'
    );

    List<Event> result = [];
    for (var e in events) {
      Event ev = await buildEventWithTags(e);
      result.add(ev);
    }
    return result;
  }
  Future<void> createCollectionsTable(Database database) async {
    await database.execute("""
    CREATE TABLE IF NOT EXISTS collections (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      creationDate INT
    );
  """);
  }

  Future<void> createCollectionEventsTable(Database database) async {
    await database.execute("""
    CREATE TABLE IF NOT EXISTS collection_events (
      collection_id INTEGER,
      event_id INTEGER,
      FOREIGN KEY (collection_id) REFERENCES collections(id),
      FOREIGN KEY (event_id) REFERENCES events(id),
      PRIMARY KEY (collection_id, event_id)
    );
  """);
  }

  Future<void> createCollectionPOITable(Database database) async {
    await database.execute("""
    CREATE TABLE IF NOT EXISTS collection_poi (
      collection_id INTEGER,
      poi_id INTEGER,
      FOREIGN KEY (collection_id) REFERENCES collections(id),
      FOREIGN KEY (poi_id) REFERENCES poi(id),
      PRIMARY KEY (collection_id, poi_id)
    );
  """);
  }

  Future<int> createCollection(String name, List<int> eventIds, List<int> poiIds, int creationDate) async {
    final database = await DatabaseService().database;
    int collectionId = await database.insert(
      'collections',
      {'name': name,
       'creationDate': creationDate},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (var eventId in eventIds) {
      await database.insert(
        'collection_events',
        {
          'collection_id': collectionId,
          'event_id': eventId,
        },
      );
    }
    for (var poiId in poiIds) {
      await database.insert(
        'collection_poi',
        {
          'collection_id': collectionId,
          'poi_id': poiId,
        },
      );
    }
    return collectionId;
  }

  Future<void> deleteCollection(int collectionId) async {
    final database = await DatabaseService().database;

    // Begin a transaction to ensure all deletions are successful
    await database.transaction((txn) async {
      // Delete all events associated with the collection
      await txn.delete(
        'collection_events',
        where: 'collection_id = ?',
        whereArgs: [collectionId],
      );

      // Delete all POIs associated with the collection
      await txn.delete(
        'collection_poi',
        where: 'collection_id = ?',
        whereArgs: [collectionId],
      );

      // Finally, delete the collection itself
      await txn.delete(
        'collections',
        where: 'id = ?',
        whereArgs: [collectionId],
      );
    });
  }


  Future<void> addEventToCollection(int eventId, int collectionId) async {
    final database = await DatabaseService().database;

    // Check if the event is already in the collection
    final existing = await database.query(
      'collection_events',
      where: 'collection_id = ? AND event_id = ?',
      whereArgs: [collectionId, eventId],
    );

    // If not, add the event to the collection
    if (existing.isEmpty) {
      await database.insert(
        'collection_events',
        {
          'collection_id': collectionId,
          'event_id': eventId,
        },
      );
    }
  }

  Future<void> deleteEventFromCollection(int eventId, int collectionId) async {
    final database = await DatabaseService().database;

    // Delete the POI from the collection
    await database.delete(
      'collection_events',
      where: 'collection_id = ? AND event_id = ?',
      whereArgs: [collectionId, eventId],
    );
  }


  Future<void> addPOIToCollection(int poiId, int collectionId) async {
    final database = await DatabaseService().database;

    // Check if the event is already in the collection
    final existing = await database.query(
      'collection_poi',
      where: 'collection_id = ? AND poi_id = ?',
      whereArgs: [collectionId, poiId],
    );

    // If not, add the event to the collection
    if (existing.isEmpty) {
      await database.insert(
        'collection_poi',
        {
          'collection_id': collectionId,
          'poi_id': poiId,
        },
      );
    }
  }

  Future<void> deletePOIFromCollection(int poiId, int collectionId) async {
    final database = await DatabaseService().database;

    // Delete the POI from the collection
    await database.delete(
      'collection_poi',
      where: 'collection_id = ? AND poi_id = ?',
      whereArgs: [collectionId, poiId],
    );
  }


  Future<List<Collection>> fetchAllCollections() async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> collectionMaps = await database.query('collections');

    List<Collection> collections = [];
    for (var collectionMap in collectionMaps) {
      final List<Map<String, dynamic>> eventMaps = await database.query(
        'collection_events',
        where: 'collection_id = ?',
        whereArgs: [collectionMap['id']],
      );
      final List<Map<String, dynamic>> poiMaps = await database.query(
        'collection_poi',
        where: 'collection_id = ?',
        whereArgs: [collectionMap['id']],
      );
      List<int> eventIds = eventMaps.map((e) => e['event_id'] as int).toList();
      List<int> poiIds = poiMaps.map((e) => e['poi_id'] as int).toList();

      collections.add(Collection(
        id: collectionMap['id'],
        name: collectionMap['name'],
        eventIds: eventIds,
        poiIds: poiIds,
        creationDate: collectionMap['creationDate']
      ));
    }

    return collections;
  }


  /*
  // TODO
  Future<List<Event>> fetchEventsByCoordinates(double latMin, double latMax, double lngMin, double lngMax) async {
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
   */

  Future<Event> buildEventWithTags(Map<String, Object?> event) async {
    int id = event['id'] as int;
    List<String> tags = await fetchEventTags(id);
    return Event.fromSqfliteDatabase(map: event, tags: tags);
  }

  Future<void> createEventsTagsTable(Database database) async {
    await database.execute("""
    CREATE TABLE IF NOT EXISTS $eventsTagsTableName (
    "id" INTEGER NOT NULL,
    "tag" TEXT NOT NULL,
    PRIMARY KEY ("id", "tag"),
    FOREIGN KEY ("id") REFERENCES $eventsTableName ("id") ON UPDATE CASCADE ON DELETE CASCADE
    );""");
  }

  Future<int> insertEventTag(int id, String tag) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
        '''INSERT INTO $eventsTagsTableName (id, tag) VALUES (?,?)''',
        [id, tag]
    );
  }

  Future<void> deleteEventTag(int id, String tag) async {
    final database = await DatabaseService().database;
    await database.rawDelete(
        '''DELETE FROM $eventsTagsTableName WHERE id = ? AND tag = ?''',
        [id, tag]);
  }

  Future<void> clearEventTags(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete(
        '''DELETE FROM $eventsTagsTableName WHERE id = ?''', [id]);
  }

  Future<void> deleteTagAllEvents(String tag) async {
    final database = await DatabaseService().database;
    await database.rawDelete(
        '''DELETE FROM $eventsTagsTableName WHERE tag = ?''', [tag]);
  }

  Future<List<String>> fetchEventTags(int id) async {
    final database = await DatabaseService().database;
    final res = await database.rawQuery(
        '''SELECT * FROM $eventsTagsTableName WHERE id=?''', [id]
    );

    return res.map((row) => row['tag'] as String).toList();
  }

  ///REVIEWS
  final String reviewsTableName = "review";

  Future<void> createReviewsTable(Database database) async {
    await database.execute("""
  CREATE TABLE IF NOT EXISTS $reviewsTableName (
  "username" TEXT NOT NULL,
  "placeName" TEXT NOT NULL,
  "rating" REAL NOT NULL,
  "reviewText" TEXT,
  "images" TEXT, 
  PRIMARY KEY ("username", "placeName")
  );""");
  }

  Future<int> insertReview({required String username, required String placeName,
    required double rating, String? reviewText, List<String>? images}) async {
    final database = await DatabaseService().database;
    if (database == null) {
    print("nullDB");
  }
    String imagePaths = images?.join(',') ?? '';
    return await database.rawInsert(
        '''INSERT INTO $reviewsTableName (username, placeName, rating, reviewText, images) VALUES (?,?,?,?,?)''',
        [username, placeName, rating, reviewText, imagePaths]
    );
  }

  Future<List<Map<String, dynamic>>> fetchReviewsByUserAndPlace(String username, String placeName) async {
    final database = await DatabaseService().database;
    return await database.rawQuery(
        '''SELECT * FROM $reviewsTableName WHERE username=? AND placeName=?''',
        [username, placeName]
    );
  }

  Future<List<Review>> fetchReviewsByPlace(String placeName) async {
    final database = await DatabaseService().database;
    final reviews = await database.rawQuery(
        '''SELECT * FROM $reviewsTableName WHERE placeName=?''',
        [placeName]
    );

    List<Review> result = [];
    for (var r in reviews) {
      Review rev = Review.fromSqfliteDatabase(r);
      result.add(rev);
    }
    return result;
  }

  Future<List<num>> fetchAverageRatingAndCount(int placeID) async {
    final database = await DatabaseService().database;
    final reviews = await database.rawQuery(
        '''SELECT $poiTableName.name, AVG(rating) as avg_rating, COUNT(rating) as review_count
        FROM $poiTableName INNER JOIN $reviewsTableName
        ON $poiTableName.name = $reviewsTableName.placeName
        WHERE $poiTableName.id = ? 
        GROUP BY $poiTableName.name''',
        [placeID]
    );

    double avgRating = 0.0;
    int reviewCount = 0;
    if (reviews.isNotEmpty) {
      avgRating = reviews.first['avg_rating'] as double;
      reviewCount = reviews.first['review_count'] as int;
    }
    return [avgRating, reviewCount];
  }


  Future<int> updateReview({required String username, required String placeName, double? rating, String? reviewText, List<String>? images}) async {
    final database = await DatabaseService().database;
    String imagePaths = images?.join(',') ?? '';
    return await database.update(
        reviewsTableName,
        {
          if (rating != null) 'rating': rating,
          if (reviewText != null) 'reviewText': reviewText,
          if (images != null) 'images': imagePaths
        },
        where: 'username = ? AND placeName = ?',
        whereArgs: [username, placeName]
    );
  }

  Future<void> deleteReview(String username, String placeName) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $reviewsTableName WHERE username = ? AND placeName = ?''', [username, placeName]);
  }


}