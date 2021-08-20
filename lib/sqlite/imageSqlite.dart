import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:testcamera/model/imageModel.dart';

class DbImage {
  Database _database;

  /*
  Flag
  0=> Flag LastRead
  1=> Flag Common Cart
  */
  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }
    _database = await openDB();
    return _database;
  }

  Future openDB() async {
    if (_database != null) return _database;

    _database = await openDatabase(
        join(await getDatabasesPath(), 'imagesnew.db'),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE images(id INTEGER PRIMARY KEY AUTOINCREMENT,photoName TEXT,date TEXT)");
    });
    final tables =
        await _database.rawQuery('SELECT * FROM sqlite_master ORDER BY name;');
    print('ini table' + tables.toString());
  }

  Future<int> insertPhoto(ImageModel imageModel) async {
    await openDB();
    //print('wadaw ${imageModel.photoName}');
    return await _database.insert('images', imageModel.toMap());
  }

  Future<List<ImageModel>> getImageList() async {
    await openDB();
    final List<Map<String, dynamic>> maps = await _database.query('images',
        columns: ['id', 'photoName', 'date'], orderBy: 'id');
    //print(maps);
    return List.generate(maps.length, (index) {
      return ImageModel(
        id: maps[index]['id'],
        photoName: maps[index]['photoName'],
        date: maps[index]['date'],
      );
    });
  }

  Future<ImageModel> getImageSingle(
      String whereString, List<dynamic> whereArguments) async {
    await openDB();
    final List<Map<String, dynamic>> maps = await _database.query('images',
        where: whereString, whereArgs: whereArguments);

    return (maps.isEmpty)
        ? ImageModel()
        : ImageModel(
            id: maps[0]['id'],
            photoName: maps[0]['photoName'],
            date: maps[0]['date']);
  }

  Future<int> updateImage(ImageModel imageModel) async {
    await openDB();
    return await _database.update('images', imageModel.toMap(),
        where: 'id=?', whereArgs: [imageModel.id]);
  }

  Future<void> deleteImage(String id) async {
    await openDB();
    await _database.delete("images", where: "id = ? ", whereArgs: [id]);
  }

  Future<void> deleteAllFlag() async {
    await openDB();
    await _database.delete("images");
  }
}
