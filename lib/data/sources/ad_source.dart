import 'package:avito_parser/constants/constants.dart';
import 'package:avito_parser/data/models/ad_model.dart';
import 'package:sembast/sembast.dart';

class AdDataSource {
  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are Flogs objects converted to Map
  final _adsStore = intMapStoreFactory.store(AD_SOURCE);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
//  Future<Database> get _db async => await AppDatabase.instance.database;

  // database instance
  final Database _db;

  // Constructor
  AdDataSource(this._db);

  // DB functions:--------------------------------------------------------------
  Future<int> insert(Ad ad) async {
    return await _adsStore.add(_db, ad.toMap());
  }

  Future<int> count() async {
    return await _adsStore.count(_db);
  }

  Future<List<Ad>> getAllSortedByFilter({List<Filter> filters}) async {
    //creating finder
    final finder = Finder(filter: Filter.and(filters));

    final recordSnapshots = await _adsStore.find(
      _db,
      finder: finder,
    );

    // Making a List<Ad> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final ad = Ad.fromMap(snapshot.value);
      // An ID is a key of a record from the database.
      ad.id = snapshot.key;
      return ad;
    }).toList();
  }

  Future<List<Ad>> getAdsFromDb() async {
    // ad list
    var adsList;

    // fetching data
    final recordSnapshots = await _adsStore.find(_db);

    // Making a List<Ad> out of List<RecordSnapshot>
    if (recordSnapshots.length > 0) {
      adsList = recordSnapshots.map((snapshot) {
        final ad = Ad.fromMap(snapshot.value);
        // An ID is a key of a record from the database.
        ad.id = snapshot.key;
        return ad;
      }).toList();
    }

    return adsList;
  }

  Future<int> update(Ad ad) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    final finder = Finder(filter: Filter.byKey(ad.id));
    return await _adsStore.update(
      _db,
      ad.toMap(),
      finder: finder,
    );
  }

  Future<int> delete(Ad ad) async {
    final finder = Finder(filter: Filter.byKey(ad.id));
    return await _adsStore.delete(
      _db,
      finder: finder,
    );
  }

  Future deleteAll() async {
    await _adsStore.drop(
      _db,
    );
  }
}
